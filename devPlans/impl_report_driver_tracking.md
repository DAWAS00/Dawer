# Implementation Report: Driver Live Location Tracking & Proximity Geofencing

**Date:** 2026-05-22
**Context:** Dawer Project
**Status:** Implemented

## Overview

This document details the implementation of real-time driver tracking and proximity geofencing. This feature ensures that drivers can only progress an order state (e.g., confirming arrival) when they are physically within a defined distance from the target coordinates. It leverages Supabase Realtime for live tracking and a combination of local Dart logic and Edge Functions for validation.

## 1. Database Layer (Supabase)

A new real-time enabled table was created to store transient driver locations. 

**Table: `driver_locations`**
- `driver_id` (uuid, PK, references `auth.users`)
- `order_id` (text)
- `lat` (double precision)
- `lng` (double precision)
- `updated_at` (timestamptz)

**Security & Replication:**
- Row Level Security (RLS) is enabled. Drivers can only upsert their own rows.
- Authenticated users (suppliers/recycling companies) can `SELECT` the data for live map tracking.
- The table was added to the `supabase_realtime` publication to broadcast updates to subscribed clients.

## 2. Proximity & Geofencing Logic

The `ProximityService` (`lib/data/services/proximity_service.dart`) handles the mathematical calculation of distances using the Haversine formula.

**Constants Implemented:**
- `pickupRadiusMeters`: 200.0 meters
- `dropoffRadiusMeters`: 200.0 meters
- `arrivalResponseMinutes`: 5.0 (timeout for supplier response)
- `ghostTimeoutMinutes`: 15.0

**Validation Logic:**
- `isWithinPickupGeofence` / `isWithinDropoffGeofence`: Validates if a coordinate set is within 200 meters of the target.
- `minimumTravelSeconds`: Calculates the minimum possible travel time based on a 30 km/h average to flag potentially fraudulent "teleportation" or simulated GPS usage.

## 3. UI and State Updates

The `OrderArrivalSection` widget (`lib/ui/features/home/shared/order_details/order_arrival_section.dart`) was built to contextualize the proximity validation within the UI.

It dynamically updates based on the user's role and the order state:
1. **Driver View (Approaching Pickup):** Shows the "أنا هنا — الاستلام" (I'm Here - Pickup) button. Tapping this triggers the location validation against the 200m radius.
2. **Driver View (Awaiting Supplier):** Once arrived, the driver sees a banner indicating they are waiting for the supplier to confirm presence. It specifies the 5-minute timeout window for automatic compensation.
3. **Driver View (Approaching Dropoff):** Shows the "أنا هنا — التسليم" (I'm Here - Dropoff) button for final validation.
4. **Supplier View:** If the driver has arrived, the supplier sees a confirmation card allowing them to state whether they are "أنا متاح" (Available) or "غير متاح" (Unavailable), which resolves the driver's wait block.

## Summary

The live location and proximity feature effectively ties the physical world to the app's state machine. Drivers are prevented from prematurely marking arrival without being physically near the location, and real-time database capabilities allow suppliers to track the driver's approach seamlessly.