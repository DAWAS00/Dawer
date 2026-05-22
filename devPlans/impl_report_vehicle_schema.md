# Implementation Report: Vehicle Type Schema and Auth Integration

**Date:** 2026-05-22
**Context:** Dawer Project
**Status:** Implemented

## Overview

This document outlines the changes made to integrate the `VehicleType` system and the new `copperAluminium` waste type into the Supabase database schema and the Dart authentication layer. These changes align the backend structure with the client-side pricing and vehicle-matching logic previously implemented.

## 1. Database Schema Updates (Supabase Migrations)

A new migration script (`20260522_vehicle_type.sql`) was introduced to alter the existing database schema.

### 1.1 `vehicle_type` Enum Definition
Created a new Postgres ENUM type to standardize vehicle classifications:
```sql
CREATE TYPE vehicle_type AS ENUM (
  'motorcycle', 'car', 'pickup', 'van', 'truck', 'heavyTruck'
);
```

### 1.2 User Profile Expansion
Modified the `users` table to track the driver's vehicle and specific licensing constraints:
- Added `vehicle_type` (mapped to the ENUM).
- Added `has_chemical_permit` (boolean, defaults to false).

### 1.3 Order Requirements
Modified the `orders` table to track the prerequisites for a driver to accept the order:
- Added `required_vehicle_type` (the minimum vehicle size needed).
- Added `requires_chemical_permit` (boolean flag).
- Added `admin_approval_status` text constraint for listings requiring manual review (e.g., chemicals).

### 1.4 Waste Type Constraint Update
Updated the `orders_waste_types_check` array constraint on the `orders` table to include the newly defined `copperAluminium` material type.

### 1.5 Indexing
Added an index `orders_required_vehicle_type_idx` on the `orders` table (filtered to `status = 'pending'`) to optimize the localized driver feed logic which filters out orders a driver's vehicle cannot accommodate.

## 2. Authentication Layer Integration (Dart)

The client-side authentication and signup services were updated to pass these new fields to Supabase upon driver registration.

### 2.1 `SignUpRequest` Modification
The data structure defined in `lib/data/services/user_signup_service.dart` was expanded to accept the new attributes during the signup flow:
- `final VehicleType? vehicleType;`
- `final bool hasChemicalPermit;`

### 2.2 `SupabaseAuthService` Mapping
The service responsible for talking to the Supabase API (`lib/data/services/supabase_auth_service.dart`) was updated to map these values:
- During profile creation, it parses `request.vehicleType!.name` into the `vehicle_type` column.
- It passes the `has_chemical_permit` flag into the `has_chemical_permit` column.
- When fetching the current user profile, it safely parses these new fields back into the local user map so the app knows the driver's vehicle type and chemical permit status immediately upon login or app launch.

## Summary

The backend schema now natively supports the strict vehicle matching requirements of the platform. By enforcing these types at the database level via ENUMs and constraints, and capturing them directly during user signup, the system guarantees that orders and drivers are strictly categorized, preventing light vehicles from accepting heavy loads or hazardous materials without permits.