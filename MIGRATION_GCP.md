# Dawer — Supabase → Google Cloud Migration Plan
> Covers: backend migration, Maps integration, auth, data, cutover, rollback, testing

---

## Table of Contents
1. [Executive Summary](#1-executive-summary)
2. [Service Mapping: Supabase → Google Cloud](#2-service-mapping)
3. [Target Architecture](#3-target-architecture)
4. [Phase 0 — Discovery & Prerequisites](#4-phase-0--discovery--prerequisites)
5. [Phase 1 — Firebase Auth Migration](#5-phase-1--firebase-auth-migration)
6. [Phase 2 — Firestore Database Migration](#6-phase-2--firestore-database-migration)
7. [Phase 3 — Cloud Storage Migration](#7-phase-3--cloud-storage-migration)
8. [Phase 4 — Realtime & Driver Location](#8-phase-4--realtime--driver-location)
9. [Phase 5 — Edge Functions → Cloud Run](#9-phase-5--edge-functions--cloud-run)
10. [Phase 6 — Google Maps Full Integration](#10-phase-6--google-maps-full-integration)
11. [Phase 7 — Flutter Frontend Rewire](#11-phase-7--flutter-frontend-rewire)
12. [Phase 8 — Cutover & Verification](#12-phase-8--cutover--verification)
13. [Security Model](#13-security-model)
14. [Risk Register & Rollback](#14-risk-register--rollback)
15. [Testing Strategy](#15-testing-strategy)
16. [Appendix: Code Skeletons](#16-appendix-code-skeletons)

---

## 1. Executive Summary

The migration replaces every Supabase service with a Google Cloud equivalent while
preserving the existing Clean Architecture (domain interfaces → data implementations).
Because the Flutter codebase uses `IAuthRepository`, `IOrderRepository`, and
`IFileStorageRepository` as hard boundaries, the migration is **additive**:
new GCP-backed implementations are written alongside the existing Supabase ones and
swapped in `main.dart` at cutover. Zero domain or UI layer code needs to change.

### Core Technology Choices

| Need | Chosen GCP Service | Reason |
|---|---|---|
| Authentication | **Firebase Auth** (Google Identity Platform) | OTP, email link, custom claims, Flutter SDK |
| Order database + real-time | **Cloud Firestore** | Built-in `snapshots()` replaces Supabase Realtime; role-scoped `where()` queries |
| Driver GPS tracking | **Firebase Realtime Database** | Sub-100ms write latency for continuous upserts |
| File storage | **Cloud Storage (GCS)** via Firebase Storage SDK | Direct Flutter SDK, signed URLs |
| Server-side logic / RPC | **Cloud Run** (or **Cloud Functions gen 2**) | Replaces Supabase Edge Functions; stateless HTTP |
| Push notifications | **Firebase Cloud Messaging (FCM)** | Already planned; now native to Firebase project |
| Maps | **Google Maps Platform** (already `google_maps_flutter`) | Enable SDKs, add Directions + Places APIs |
| Observability | **Cloud Logging + Firebase Crashlytics** | Replaces planned Sentry; same DSN model |

---

## 2. Service Mapping

### 2.1 Component-level Mapping

```
Supabase Component                    →  Google Cloud Equivalent
─────────────────────────────────────────────────────────────────
Supabase Auth (email+password, OTP)   →  Firebase Auth + Cloud Function OTP helper
PostgreSQL `orders` table             →  Cloud Firestore /orders collection
PostgreSQL `users` table              →  Cloud Firestore /users/{uid} document
Supabase Realtime (.stream())         →  Firestore .snapshots() (Collection stream)
`driver_locations` table + upsert     →  Firebase Realtime Database /driver_locations
Supabase Storage (profile-photos)     →  Firebase Storage gs://bucket/profile-photos/
Supabase Storage (user-documents)     →  Firebase Storage gs://bucket/user-documents/
Signed URL generation                 →  Firebase Storage getDownloadURL() / GCS V4 signed URL
Edge Function `calculate_reward`      →  Cloud Run service POST /reward/calculate
RPC `get_email_by_phone`              →  Cloud Function (HTTP) GET /user/emailByPhone
Row-Level Security (RLS)              →  Firestore Security Rules + Firebase Auth custom claims
Supabase PostgreSQL triggers          →  Firestore Cloud Function triggers
`supabase_flutter` Dart SDK           →  `firebase_core` + `firebase_auth` + `cloud_firestore`
                                          + `firebase_storage` + `firebase_database`
```

### 2.2 Flutter Dart API Equivalences

| Current (Supabase) | Target (Firebase/GCP) |
|---|---|
| `Supabase.instance.client.auth.signUp(email, password)` | `FirebaseAuth.instance.createUserWithEmailAndPassword(email, password)` |
| `_client.auth.signInWithPassword(email, password)` | `FirebaseAuth.instance.signInWithEmailAndPassword(email, password)` |
| `_client.auth.signInWithOtp(email: e)` | Cloud Function → 6-digit code → email; `signInWithCustomToken` |
| `_client.auth.onAuthStateChange` | `FirebaseAuth.instance.authStateChanges()` |
| `_client.auth.currentUser` | `FirebaseAuth.instance.currentUser` |
| `_client.auth.updateUser(UserAttributes(password: p))` | `currentUser.updatePassword(p)` |
| `_client.from('orders').stream(…).eq('supplier_id', uid)` | `firestore.collection('orders').where('supplierId', isEqualTo: uid).snapshots()` |
| `_client.from('orders').insert(payload)` | `firestore.collection('orders').add(payload)` |
| `_client.from('orders').update(payload).eq('id', id)` | `firestore.collection('orders').doc(id).update(payload)` |
| `_client.from('orders').delete().eq('id', id)` | `firestore.collection('orders').doc(id).delete()` |
| `_client.from('driver_locations').upsert({…})` | `database.ref('driver_locations/$orderId').set({…})` |
| Supabase Realtime channel for driver location | `database.ref('driver_locations/$orderId').onValue` |
| `_client.storage.from(bucket).upload(path, file)` | `FirebaseStorage.instance.ref(path).putFile(file)` |
| `_client.storage.from(bucket).getPublicUrl(path)` | `ref.getDownloadURL()` |
| `_client.storage.from(bucket).createSignedUrl(path, secs)` | GCS Admin SDK V4 signed URL via Cloud Function |
| `_client.rpc('get_email_by_phone', params: {…})` | `GET https://api.dawer.app/user/emailByPhone?phone=xxx` (Cloud Run) |

---

## 3. Target Architecture

### 3.1 System Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│  Flutter App (iOS + Android)                                        │
│  ┌──────────────┐  ┌──────────────────────┐  ┌───────────────────┐ │
│  │  Auth Views  │  │  Home Views (3 roles) │  │  Maps + Chatbot   │ │
│  └──────┬───────┘  └──────────┬────────────┘  └────────┬──────────┘ │
│         │  ChangeNotifier / Provider + IRepository      │           │
│  ┌──────▼─────────────────────────────────────────────▼──────────┐ │
│  │  Domain Interfaces (UNCHANGED):                                │ │
│  │  IAuthRepository · IOrderRepository · IFileStorageRepository  │ │
│  └──────────────────────────┬─────────────────────────────────────┘ │
│                             │ new implementations                   │
│  ┌──────────────────────────▼─────────────────────────────────────┐ │
│  │  GCP Data Layer (new, replaces Supabase layer):                │ │
│  │  FirebaseAuthRepository  ·  FirestoreOrderRepository          │ │
│  │  FirebaseStorageRepository · FirebaseAuthService               │ │
│  │  FirebaseLocationPublisher · FirebaseDriverLocationStream      │ │
│  └────────┬────────────────────────────────────┬──────────────────┘ │
└───────────┼────────────────────────────────────┼────────────────────┘
            │  Firebase SDK (HTTPS/WSS)           │  Maps SDK
            ▼                                     ▼
┌───────────────────────┐              ┌──────────────────────────┐
│  Firebase Project     │              │  Google Maps Platform    │
│  ├─ Firebase Auth     │              │  ├─ Maps SDK Android/iOS │
│  ├─ Cloud Firestore   │              │  ├─ Directions API       │
│  ├─ Realtime Database │              │  ├─ Distance Matrix API  │
│  ├─ Firebase Storage  │              │  └─ Places API           │
│  └─ FCM               │              └──────────────────────────┘
└──────────┬────────────┘
           │  Cloud Firestore triggers
           ▼
┌──────────────────────────────────────┐
│  Cloud Run Services                  │
│  ├─ POST /reward/calculate           │
│  ├─ POST /ai/marketplace             │
│  ├─ GET  /user/emailByPhone          │
│  └─ POST /auth/setCustomClaims       │
└──────────────────────────────────────┘
```

### 3.2 Firestore Data Model

```
/orders/{orderId}
  id, type, status, wasteTypes[], supplierId, driverId, companyId
  pickupLat, pickupLng, dropoffLat, dropoffLng, estimatedWeightKg
  rewardJd, notes, isMarketplaceShared, requiresRider, linkedJobId
  collectionDeliveryMethod, collectionTransactionType, jobDescription
  paymentModel, pricePerKg, itemPrice, minQuantityKg, actualWeightKg
  wasteForm, weightCategory, pickupTarget, isEdited, editNote, editedAt
  createdAt, acceptedAt, inTransitAt, completedAt, scheduledAt
  isVisibleToDrivers   ← new field; set true on pending, false on accept

/users/{firebaseUid}
  name, phone, email, role, supplierType, vehiclePlate, vehicleModel
  vehicleColor, address, rating, totalOrders, isVerified, points
  profilePhotoUrl, identityDocPath, categories[], createdAt

/otp_verifications/{email}       ← TTL 10 min, for email OTP flow
  code, createdAt, used

Firebase Realtime Database:
  /driver_locations/{orderId}/lat
  /driver_locations/{orderId}/lng
  /driver_locations/{orderId}/updatedAt
```

### 3.3 Firestore Composite Indexes Required

```
Collection  Fields                      Query served
──────────  ──────────────────────────  ──────────────────────────────────────────
orders      supplierId ASC, createdAt DESC    Supplier home feed
orders      companyId ASC, createdAt DESC     RecyclingCo home feed
orders      driverId ASC, createdAt DESC      Driver's own orders
orders      status ASC, createdAt DESC        Driver public feed (pending)
orders      isVisibleToDrivers, createdAt DESC  Driver pending feed (filtered)
```

---

## 4. Phase 0 — Discovery & Prerequisites

**Duration**: 2–3 days  
**Owner**: Backend Engineer + Tech Lead

### Steps

1. **Create Firebase project**
   - Go to [console.firebase.google.com](https://console.firebase.google.com) → New project → "dawer-prod"
   - Enable Google Analytics during creation
   - Create a second project "dawer-staging" for pre-production testing

2. **Enable Firebase services**
   - Authentication → Sign-in methods: Email/Password ✓, Email Link ✓
   - Firestore → Create database → Production mode → Region: `europe-west1` (closest to Jordan)
   - Realtime Database → Create → Region: `europe-west1`
   - Storage → Get started → Region: `europe-west1`
   - FCM → enabled by default

3. **Enable Google Maps Platform APIs** in [console.cloud.google.com](https://console.cloud.google.com)
   - Maps SDK for Android
   - Maps SDK for iOS
   - Directions API
   - Distance Matrix API
   - Places API
   - Geocoding API (for `pickupAddress` / `dropoffAddress` reverse geocoding — currently hardcoded as placeholder in `orderFromSupabaseJson`)
   - Create a restricted API key per platform (Android: package name + SHA-1; iOS: bundle ID)

4. **Register Flutter app with Firebase**
   - `flutterfire configure` → select `dawer-prod` → select Android + iOS
   - Generates `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Generates `lib/firebase_options.dart`

5. **Audit existing Supabase schema** — export full schema DDL and row counts:
   - Tables: `orders`, `users`, `driver_locations`
   - Storage buckets: `profile-photos`, `user-documents`
   - Edge Functions: `calculate_reward`
   - RPC functions: `get_email_by_phone`
   - Row count: [FILL: actual row counts from Supabase dashboard]

6. **Set up Cloud Run project** [FILL: target GCP project ID]
   - Enable Cloud Run API, Cloud Build API, Artifact Registry API

7. **Milestone**: Firebase project active, all APIs enabled, Flutter app registered, Supabase schema documented.

---

## 5. Phase 1 — Firebase Auth Migration

**Duration**: 1 week  
**Owner**: Backend Engineer (Cloud Functions) + Flutter Developer

### 5.1 Auth Strategy: Preserve Email OTP UX

Supabase provides native 6-digit email OTP. Firebase Auth does **not** natively support
6-digit email codes; it uses email link (magic link) instead. To preserve the exact UX:

**Approach**: Custom OTP via Cloud Function + Firebase custom token sign-in.

```
requestEmailOtp(email):
  1. Cloud Function generates cryptographically random 6-digit code
  2. Stores in Firestore /otp_verifications/{email} with 10-min TTL
  3. Sends email via [FILL: email provider — Firebase Email Extension / SendGrid / Mailgun]
  4. Returns { success: true }

verifyEmailOtpAndGetProfile(email, code):
  1. Cloud Function reads /otp_verifications/{email}
  2. Validates code matches, not expired, not used
  3. If user doesn't exist in Firebase Auth → create with createUser(email)
  4. Set custom claims: { role, supplierType } via setCustomUserClaims(uid, claims)
  5. Mark otp_verifications entry as used
  6. Return Firebase custom token
  7. Flutter: FirebaseAuth.instance.signInWithCustomToken(token) → User

Password reset (already implemented via 6-digit code in IAuthRepository):
  - Same OTP flow with a separate /password_reset_otps/{email} collection
  - After verification, return short-lived custom token scoped to password update only
```

**Alternative** (simpler, breaks OTP UX): Use Firebase Auth email link
(`sendSignInLinkToEmail`). The user taps a link in email instead of entering a code.
Choose based on target user literacy. For the Jordanian market, the 6-digit code UX is
recommended as it is more familiar.

### 5.2 Write `FirebaseAuthService`

Create `lib/data/services/firebase_auth_service.dart` — mirrors `SupabaseAuthService`:

```dart
class FirebaseAuthService {
  FirebaseAuthService({required LocalStore store, IFileStorageRepository? fileStorage})
      : _store = store, _fileStorage = fileStorage;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  // ... sign-up, sign-in, getCurrentUser, logout
  // Part files: firebase_auth_service/auth_helpers.dart
  //             firebase_auth_service/signup_helpers.dart
}
```

Key implementation notes:
- After `createUserWithEmailAndPassword`, immediately call Cloud Run `POST /auth/setCustomClaims` with `{ uid, role, supplierType }` — this sets Firebase Auth custom claims server-side.
- Custom claims propagate to Firestore Security Rules as `request.auth.token.role`.
- The `fetchCurrentProfile()` equivalent reads `firestore.collection('users').doc(auth.currentUser!.uid).get()`.
- `normalizeProfile()` stays identical — it just maps a `Map<String, dynamic>` regardless of source.
- `mapAuthError()` maps `FirebaseAuthException` codes instead of `AuthException` messages.

### 5.3 Write `FirebaseAuthRepository`

`lib/data/repositories/firebase_auth_repository.dart` — implements `IAuthRepository`.
The contract is identical; only the import and service change:

```dart
final class FirebaseAuthRepository implements IAuthRepository {
  FirebaseAuthRepository(this._authService, this._localStore);
  final FirebaseAuthService _authService;
  final LocalStore _localStore;
  // All methods delegate to _authService, same as SupabaseAuthRepository
}
```

### 5.4 Migrate Existing Users

Users exist in Supabase Auth (`auth.users`) + `public.users` profile table.

```
Migration script (run once, server-side Node.js using Firebase Admin SDK):

1. Export all rows from Supabase `public.users` (CSV or JSON)
2. For each user:
   a. Call Firebase Admin: createUser({ email, displayName: name })
   b. Set custom claims: setCustomUserClaims(uid, { role, supplierType })
   c. Write Firestore /users/{newFirebaseUid} with profile fields
   d. Store mapping: supabaseUserId → firebaseUid (for order data migration in Phase 2)
3. Send password-reset email to all migrated users so they set a new Firebase password
   [FILL: decide whether to notify users before migration or use silent migration]
```

**Pitfall**: Supabase Auth UIDs are UUIDs; Firebase UIDs are shorter strings. All
foreign-key references in orders (`supplier_id`, `driver_id`, `company_id`) must be
remapped to Firebase UIDs during order migration (Phase 2).

### 5.5 Milestone
- Firebase Auth project receiving new sign-ups
- Existing users migrated with UID mapping table ready
- All `IAuthRepository` methods covered by unit tests using `FirebaseAuthRepository`

---

## 6. Phase 2 — Firestore Database Migration

**Duration**: 1–1.5 weeks  
**Owner**: Backend Engineer + Flutter Developer

### 6.1 Write `FirestoreOrderRepository`

`lib/data/repositories/firestore_order_repository.dart` implements `IOrderRepository`.

**Key design decisions**:

**Driver stream problem fixed**: The current `SupabaseOrderRepository` falls back to the
full `orders` table for drivers (gap G2 in ARCHITECTURE.md). Firestore fixes this:

```dart
@override
Stream<List<Order>> watchOrdersForUser(String userId, UserRole role) {
  switch (role) {
    case UserRole.supplier:
      return _db.collection('orders')
          .where('supplierId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map(_mapSnapshot);

    case UserRole.recyclingCo:
      return _db.collection('orders')
          .where('companyId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map(_mapSnapshot);

    case UserRole.driver:
      // Two queries merged: public pending feed + driver's own orders
      final feed = _db.collection('orders')
          .where('isVisibleToDrivers', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map(_mapSnapshot);
      final own = _db.collection('orders')
          .where('driverId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map(_mapSnapshot);
      return StreamZip([feed, own])
          .map((lists) => {...lists[0], ...lists[1]}.toList()
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt)));
  }
}
```

**`isVisibleToDrivers` lifecycle** (managed by Firestore Cloud Function trigger):
```javascript
// Cloud Function: onOrderWrite
exports.syncDriverVisibility = onDocumentWritten('orders/{id}', (event) => {
  const after = event.data.after.data();
  if (!after) return null;
  const visible = after.status === 'pending' && !after.driverId;
  return event.data.after.ref.update({ isVisibleToDrivers: visible });
});
```

### 6.2 Write `orderFromFirestoreJson` + `orderToFirestoreMap`

Create `lib/data/models/order_firestore_ext.dart` to replace `order_supabase_ext.dart`:

```dart
extension OrderFirestoreExt on Order {
  Map<String, dynamic> toFirestoreMap() {
    return {
      'type': type.name,
      'status': status.name,
      'wasteTypes': wasteTypes.map((e) => e.name).toList(),
      if (pickupLat != null) 'pickupLat': pickupLat,
      if (pickupLng != null) 'pickupLng': pickupLng,
      // ... all other fields, no PostGIS POINT() conversion needed
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}

Order orderFromFirestoreDoc(DocumentSnapshot doc) {
  final json = doc.data() as Map<String, dynamic>;
  return Order(
    id: doc.id,
    // ... same field parsing as orderFromSupabaseJson but:
    // - no 'POINT()' geometry; use json['pickupLat'], json['pickupLng'] directly
    // - Timestamps come as Timestamp objects: (json['createdAt'] as Timestamp).toDate()
    // - pickupAddress / dropoffAddress: reverse-geocode from lat/lng via Geocoding API
    //   or accept that addresses are resolved client-side at display time
  );
}
```

**Note on addresses**: `orderFromSupabaseJson` currently hardcodes
`pickupAddress: 'موقع السحب المختار'` because PostGIS returns geometry, not text.
In Firestore, store `pickupLat`/`pickupLng` and resolve the display address via
**Geocoding API** at view render time, or store the resolved string at order creation.
Recommended: store `pickupAddress` as a string field written when the order is created
(the supplier has already entered or confirmed it).

### 6.3 Data Migration Script

```
Migration procedure (Node.js, run against Supabase REST + Firebase Admin SDK):

1. Export orders from Supabase:
   GET https://<project>.supabase.co/rest/v1/orders?select=*
   Authorization: Bearer <SERVICE_ROLE_KEY>

2. For each order:
   a. Remap supplier_id/driver_id/company_id using Phase 1 UID mapping table
   b. Convert PostGIS POINT to pickupLat/pickupLng (parse 'POINT(lng lat)')
   c. Convert snake_case to camelCase field names
   d. Set isVisibleToDrivers based on current status
   e. Write to Firestore: db.collection('orders').doc(order.id).set(orderDoc)

3. Verify row count matches: Supabase count == Firestore count

4. Run integrity check: spot-check 10 random orders across roles

[FILL: estimated row count and expected migration duration]
[FILL: data migration method — streaming script vs. bulk import via Firestore import API]
```

### 6.4 Milestone
- `FirestoreOrderRepository` passes all existing `app_order_store_test.dart` tests
  (injected as `IOrderRepository` mock)
- Order data migrated to Firestore in staging environment
- Firestore Security Rules deployed and validated

---

## 7. Phase 3 — Cloud Storage Migration

**Duration**: 3–4 days  
**Owner**: Backend Engineer + Flutter Developer

### 7.1 Write `FirebaseFileStorageRepository`

`lib/data/repositories/firebase_file_storage_repository.dart` implements `IFileStorageRepository`:

```dart
final class FirebaseFileStorageRepository implements IFileStorageRepository {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  Future<AppResult<String>> uploadProfilePhoto({
    required String userId, required File file,
  }) => _upload(path: 'profile-photos/$userId/profile${p.extension(file.path)}',
                 file: file, returnPublicUrl: true);

  @override
  Future<AppResult<String>> uploadIdentityDocument({
    required String userId, required File file,
  }) => _upload(path: 'user-documents/$userId/identity${p.extension(file.path)}',
                 file: file, returnPublicUrl: false);

  @override
  Future<AppResult<String>> signedIdentityUrl({
    required String objectPath,
    Duration validity = const Duration(minutes: 5),
  }) async {
    // Option A: Firebase Storage download URL (no expiry, but token-based)
    final ref = _storage.ref(objectPath);
    final url = await ref.getDownloadURL();
    return Success(url);
    // Option B: GCS V4 signed URL via Cloud Run for true time-limited URLs
    // POST /storage/signedUrl { path, expiresInSeconds: validity.inSeconds }
  }
}
```

**Firebase Storage Security Rules** (equivalent to Supabase bucket policies):
```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /profile-photos/{userId}/{file} {
      allow read: if true;                          // public profiles
      allow write: if request.auth.uid == userId;   // own profile only
    }
    match /user-documents/{userId}/{file} {
      allow read: if request.auth.uid == userId;    // private
      allow write: if request.auth.uid == userId;
    }
  }
}
```

### 7.2 File Migration

```
Migration script:
1. List all objects in Supabase Storage bucket via Management API
2. For each object:
   a. Download via Supabase signed URL
   b. Upload to Firebase Storage at matching path
   c. Verify upload (size match)
3. Update Firestore /users/{uid}.profilePhotoUrl to new Firebase Storage URL
   (Firebase Storage download URLs differ from Supabase public URLs)

[FILL: bucket sizes — Supabase dashboard → Storage → Usage]
```

### 7.3 Milestone
- `FirebaseFileStorageRepository` passes unit tests with mock `FirebaseStorage`
- All production files accessible via Firebase Storage URLs
- `profilePhotoUrl` in Firestore /users updated to Firebase Storage URLs

---

## 8. Phase 4 — Realtime & Driver Location

**Duration**: 3–4 days  
**Owner**: Flutter Developer

### 8.1 `FirebaseLocationPublisher`

Replaces `lib/data/services/location_publisher.dart`:

```dart
class FirebaseLocationPublisher implements ILocationPublisher {
  FirebaseLocationPublisher._();
  static final instance = FirebaseLocationPublisher._();

  final _db = FirebaseDatabase.instance;
  StreamSubscription<Position>? _sub;
  String? _orderId;

  @override
  Future<void> start(String orderId) async {
    if (_sub != null) await stop();
    final granted = await _ensurePermission();
    if (!granted) return;
    _orderId = orderId;
    _sub = Geolocator.getPositionStream(
      locationSettings: _settings,
    ).listen((pos) => _write(pos, orderId));
  }

  @override
  Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;
    if (_orderId != null) {
      await _db.ref('driver_locations/$_orderId').remove();
      _orderId = null;
    }
  }

  Future<void> _write(Position pos, String orderId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await _db.ref('driver_locations/$orderId').set({
      'driverId': uid,
      'lat': pos.latitude,
      'lng': pos.longitude,
      'updatedAt': ServerValue.timestamp,
    });
  }
}
```

**Advantages over current `LocationPublisher`**:
- `FirebaseDatabase` is injected (testable) instead of `Supabase.instance.client` global
- Firebase Realtime Database is purpose-built for high-frequency writes (lower latency than PostgreSQL upsert)
- No singleton global instance needed — can be Provider-injected

### 8.2 `FirebaseDriverLocationStream`

Replaces `lib/data/services/driver_location_stream.dart`:

```dart
class FirebaseDriverLocationStream {
  static Stream<LatLng> forOrder(String orderId) {
    return FirebaseDatabase.instance
        .ref('driver_locations/$orderId')
        .onValue
        .map((event) {
          final data = event.snapshot.value as Map<dynamic, dynamic>?;
          if (data == null) return null;
          final lat = (data['lat'] as num).toDouble();
          final lng = (data['lng'] as num).toDouble();
          return LatLng(lat, lng);
        })
        .where((pos) => pos != null)
        .cast<LatLng>();
  }
}
```

### 8.3 Firebase Realtime Database Security Rules

```json
{
  "rules": {
    "driver_locations": {
      "$orderId": {
        ".read": "auth != null",
        ".write": "auth != null && data.child('driverId').val() === auth.uid || !data.exists()"
      }
    }
  }
}
```

### 8.4 Milestone
- Driver GPS tracking working end-to-end in staging
- Supplier map view receives `Stream<LatLng>` from Firebase Realtime DB
- Latency measured: target < 200ms from position emit to map marker update

---

## 9. Phase 5 — Edge Functions → Cloud Run

**Duration**: 4–5 days  
**Owner**: Backend Engineer

### 9.1 Services to Migrate

| Supabase Edge Function | Cloud Run Service | Endpoint |
|---|---|---|
| `calculate_reward` | `dawer-reward-service` | `POST /reward/calculate` |
| _(new)_ `setCustomClaims` | `dawer-auth-service` | `POST /auth/setCustomClaims` |
| _(new)_ `emailByPhone` | `dawer-auth-service` | `GET /user/emailByPhone` |
| _(new)_ `requestEmailOtp` | `dawer-auth-service` | `POST /auth/requestOtp` |
| _(new)_ `verifyEmailOtp` | `dawer-auth-service` | `POST /auth/verifyOtp` |
| _(future)_ AI marketplace | `dawer-ai-service` | `POST /ai/marketplace` |

### 9.2 Cloud Run `dawer-reward-service`

Mirrors current `RewardService` logic. Expose as stateless HTTP using Cloud Run:

```
Container: Node.js 20 or Dart (shelf)
Region: [FILL: europe-west1 for latency]
Memory: 256 MB
Min instances: 0 (cold start acceptable for non-critical calc)
Auth: Firebase ID token verification via firebase-admin middleware
```

Request/Response (identical to current edge function contract):
```json
POST /reward/calculate
{
  "wasteTypes": ["oil", "plastic"],
  "estimatedWeightKg": 10.5,
  "distanceKm": 8.2,
  "isUrgent": false
}
→ 200 { "baseFee": 1.50, "distanceFee": 4.92, "materialFee": 0.525, ... }
→ 400 { "error": "يجب تحديد نوع النفايات" }
```

**Important**: Keep `RewardService.calculate()` in Flutter as the offline fallback.
The Cloud Run endpoint is the authoritative calculation; the local service is the
network-failure fallback. This resolves Gap G8 from ARCHITECTURE.md.

### 9.3 `dawer-auth-service` — Custom OTP + Claims

```
POST /auth/requestOtp  { email: string }
  → Generate 6-digit code
  → Store in Firestore /otp_verifications/{email} with TTL
  → Send email [FILL: email provider]
  → 200 { success: true }

POST /auth/verifyOtp  { email: string, code: string }
  → Validate OTP
  → Create/get Firebase Auth user
  → Set custom claims (role from Firestore /users or request body on first sign-up)
  → Return { customToken: string }
  → Flutter: FirebaseAuth.instance.signInWithCustomToken(customToken)

POST /auth/setCustomClaims  { uid: string, role: string, supplierType?: string }
  → Called server-to-server after sign-up (not from client)
  → Admin SDK: auth.setCustomUserClaims(uid, { role, supplierType })
  → 200 { success: true }

GET /user/emailByPhone  ?phone={phone}
  → Query Firestore /users where phone == phone
  → Return { email: string } or 404
```

### 9.4 Deployment

```bash
# Build and deploy to Cloud Run
gcloud run deploy dawer-auth-service \
  --source ./cloud-run/auth-service \
  --region europe-west1 \
  --allow-unauthenticated \   # OTP endpoints are public; protect with rate limiting
  --set-env-vars FIREBASE_PROJECT_ID=[FILL]

gcloud run deploy dawer-reward-service \
  --source ./cloud-run/reward-service \
  --region europe-west1 \
  --no-allow-unauthenticated  # Requires Firebase ID token
```

### 9.5 Milestone
- `POST /reward/calculate` returns correct breakdown matching Flutter unit tests
- OTP flow end-to-end tested in staging
- Custom claims set correctly and visible in `FirebaseAuth.instance.currentUser?.getIdTokenResult()`

---

## 10. Phase 6 — Google Maps Full Integration

**Duration**: 3–4 days  
**Owner**: Flutter Developer

The app already has `google_maps_flutter: ^2.10.0` and uses `GoogleMap` widgets.
This phase properly wires the SDK and enables missing capabilities.

### 10.1 API Key Configuration

**Android** — `android/app/src/main/AndroidManifest.xml`:
```xml
<meta-data
  android:name="com.google.android.geo.API_KEY"
  android:value="${MAPS_API_KEY}" />
```
Pass at build time: `flutter build apk --dart-define=MAPS_API_KEY=AIza...`

**iOS** — `ios/Runner/AppDelegate.swift`:
```swift
GMSServices.provideAPIKey(ProcessInfo.processInfo.environment["MAPS_API_KEY"] ?? "")
```

**API Key restrictions** in Google Cloud Console:
- Android: restrict to `app.dawer.android` + SHA-1 fingerprint
- iOS: restrict to bundle ID `app.dawer.ios`
- Enable: Maps SDK for Android, Maps SDK for iOS, Directions API, Distance Matrix API, Places API, Geocoding API

### 10.2 Address Resolution (fixes `orderFromSupabaseJson` placeholder)

Currently `orderFromSupabaseJson` sets `pickupAddress: 'موقع السحب المختار'` as a
placeholder because PostGIS geometry doesn't contain a text address. Fix this in two ways:

**At order creation** (supplier picks location):
- Use `places_flutter` or direct Places API HTTP call for address autocomplete
- Store the resolved `pickupAddress` string in Firestore at creation time

**At order display** (if address is missing):
```dart
// Geocoding API call (one-time per order card)
Future<String> reverseGeocode(double lat, double lng) async {
  final url = 'https://maps.googleapis.com/maps/api/geocode/json'
      '?latlng=$lat,$lng&key=$mapsApiKey&language=ar';
  // Parse response → formatted_address
}
```

### 10.3 Live Tracking Map (already partially implemented)

`DriverLocationStream` (→ `FirebaseDriverLocationStream` after Phase 4) feeds
`Stream<LatLng>` into the existing `order_tracking_card.dart` map widget.

**Enhancements to add in this phase**:
- Add Directions API polyline: draw route from driver current position to pickup/dropoff
- Add ETA calculation using Distance Matrix API:
  ```
  GET /maps/api/distancematrix/json
    ?origins={driverLat},{driverLng}
    &destinations={pickupLat},{pickupLng}
    &mode=driving&language=ar
    &key=MAPS_API_KEY
  ```
- Replace `order.eta` (currently a hardcoded string) with live calculated ETA minutes
- Store `etaMinutes` in `AppOrderStore` for display in `order_tracking_card.dart`

### 10.4 Pickup Location Picker (Supplier Sign-up / Order Creation)

```dart
// New widget: PickupLocationPickerView
// Uses GoogleMap + long-press to drop pin, reverse geocode to address string
// Updates CreatePickupRequest.pickupLat, pickupLng, pickupAddress
```

### 10.5 Milestone
- Maps render on both Android and iOS with no API key warnings
- Live driver tracking polyline displayed on order card
- Supplier can pin-drop pickup location during order creation
- ETA minutes computed and displayed in Arabic

---

## 11. Phase 7 — Flutter Frontend Rewire

**Duration**: 3–4 days  
**Owner**: Flutter Developer

### 11.1 New Dependencies

Add to `pubspec.yaml` (add, do not remove Supabase until cutover):
```yaml
firebase_core: ^3.0.0
firebase_auth: ^5.0.0
cloud_firestore: ^5.0.0
firebase_storage: ^12.0.0
firebase_database: ^11.0.0
firebase_messaging: ^15.0.0
```

### 11.2 `lib/firebase_options.dart`
Generated by `flutterfire configure`. Import in `main.dart`:
```dart
await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
```

### 11.3 `main.dart` Swap (Feature-flag pattern)

Add a compile-time toggle so Supabase and Firebase can coexist during migration:

```dart
const useFirebase = bool.fromEnvironment('USE_FIREBASE', defaultValue: false);

Provider<IAuthRepository>(
  create: (ctx) => useFirebase
      ? FirebaseAuthRepository(ctx.read<FirebaseAuthService>(), localStore)
      : (SupabaseService.isInitialized
          ? SupabaseAuthRepository(...)
          : MockAuthRepository()),
),
Provider<IOrderRepository>(
  create: (_) => useFirebase
      ? FirestoreOrderRepository()
      : SupabaseOrderRepository(SupabaseService.client),
),
Provider<IFileStorageRepository>(
  create: (_) => useFirebase
      ? FirebaseFileStorageRepository()
      : SupabaseFileStorageRepository(),
),
```

Build with Firebase: `flutter run --dart-define=USE_FIREBASE=true`
Build with Supabase (existing): `flutter run` (no flag)

### 11.4 Files to Create

```
lib/data/
  services/
    firebase_auth_service.dart
    firebase_auth_service/
      auth_helpers.dart
      signup_helpers.dart
    firebase_location_publisher.dart
    firebase_driver_location_stream.dart
  repositories/
    firebase_auth_repository.dart
    firestore_order_repository.dart
    firebase_file_storage_repository.dart
  models/
    order_firestore_ext.dart          ← replaces order_supabase_ext.dart
```

### 11.5 Files to Deprecate (after cutover)

```
lib/data/services/supabase_auth_service.dart  (+ part files)
lib/data/repositories/supabase_auth_repository.dart  (+ helpers.dart)
lib/data/repositories/supabase_order_repository.dart
lib/data/repositories/supabase_file_storage_repository.dart
lib/data/services/location_publisher.dart
lib/data/services/driver_location_stream.dart
lib/data/models/order_supabase_ext.dart
lib/core/services/supabase_service.dart
```

### 11.6 `LocalStore` Changes

`LocalStore` uses `SharedPreferences` — no change needed. However, session cache keys
stored under `dwaar_current_user_id` now hold **Firebase UIDs** (different format
from Supabase UUIDs). Clear `LocalStore` on first launch with new build to prevent
stale Supabase UIDs from causing false "session found" rehydration.

```dart
// In SplashView: on first launch with new build version
if (localStore.getBuildVersion() != currentBuildVersion) {
  await localStore.clearAll();
  await localStore.setBuildVersion(currentBuildVersion);
}
```

### 11.7 Milestone
- App runs with `USE_FIREBASE=true` — all features work in staging
- All 22+ existing tests pass with Firebase stubs
- No Supabase SDK calls occur when `USE_FIREBASE=true`

---

## 12. Phase 8 — Cutover & Verification

**Duration**: 1 week (including 48h observation period)  
**Owner**: Tech Lead + Backend Engineer

### 12.1 Pre-Cutover Checklist

- [ ] All Phase 1–7 milestones verified in staging
- [ ] Production Firestore Security Rules audited (no open read/write)
- [ ] Firebase Storage Security Rules audited
- [ ] Realtime Database Security Rules audited
- [ ] Cloud Run services health-checked (`/healthz` endpoints)
- [ ] All GCP API keys restricted to app bundle/package
- [ ] Firebase project billing alerts set: $50, $200 thresholds
- [ ] Supabase → Firestore data migration completed in production (dry-run first)
- [ ] User UID mapping table finalized (Supabase UID → Firebase UID)
- [ ] Roll-forward plan and rollback plan documented and reviewed

### 12.2 Cutover Procedure

```
T-48h: Final data sync (incremental — only rows updated since initial migration)
T-24h: Deploy Cloud Run services to production
T-12h: Enable Firebase auth for new sign-ups (parallel to Supabase; both accept new users)
T-0:   [FILL: cutover date/time — target: low-traffic window, recommend 2am Amman time]
  1. Flip DNS / build flag to USE_FIREBASE=true for production build
  2. Publish app update to Play Store (Android) + App Store (iOS) with Firebase
  3. Old Supabase-backed builds continue to work (Supabase kept read-only for 30 days)
T+2h:  Monitor Firebase Crashlytics, Cloud Logging for errors
T+48h: Decision point — confirm cutover or rollback
T+30d: Decommission Supabase project
```

### 12.3 Rollback Plan

| Trigger | Action |
|---|---|
| > 5% crash rate in Crashlytics | Revert to Supabase build within 15 minutes (keep old APK/IPA staged) |
| Cloud Run latency > 5s p95 | Scale up Cloud Run min instances; fallback to local `RewardService` |
| Firestore Security Rule breach (unauthorized read detected) | Emergency: set rules to deny all; investigate; redeploy |
| Firebase Auth OTP delivery failure | Fall back to email link sign-in as temporary alternate |

**Rollback procedure** (app level):
```
1. Keep Supabase project active (read-only, not decommissioned) for 30 days
2. Maintain signed APK/IPA with USE_FIREBASE=false as rollback artifact
3. If rollback needed: push rollback build to stores via expedited review track
4. Re-enable Supabase writes (remove read-only restriction)
5. Sync any Firestore writes back to Supabase (write a sync script using audit log)
```

### 12.4 Milestone / Success Criteria

- New sign-ups authenticate via Firebase Auth successfully
- Orders created, accepted, completed without errors
- Driver GPS tracking functional in production
- All existing users able to log in (migrated password reset flow)
- Zero data loss verified (order counts match)
- p95 API latency < 1s for Cloud Run endpoints
- Crashlytics error rate < 0.1%

---

## 13. Security Model

### 13.1 Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // ── Orders ──────────────────────────────────────────────────────────────
    match /orders/{orderId} {
      allow read: if request.auth != null && (
        resource.data.supplierId == request.auth.uid ||
        resource.data.driverId   == request.auth.uid ||
        resource.data.companyId  == request.auth.uid ||
        request.auth.token.role  == 'driver'          // drivers see pending feed
      );
      allow create: if request.auth != null
        && request.resource.data.status == 'pending'; // only pending on create
      allow update: if request.auth != null && (
        // Supplier cancels own order
        (resource.data.supplierId == request.auth.uid
          && request.resource.data.diff(resource.data).affectedKeys()
              .hasOnly(['status', 'isEdited', 'editedAt', 'editNote'])) ||
        // Driver accepts / updates status
        (request.auth.token.role == 'driver'
          && request.resource.data.driverId == request.auth.uid) ||
        // RecyclingCo edits own collection job
        (resource.data.companyId == request.auth.uid)
      );
      allow delete: if request.auth != null
        && resource.data.supplierId == request.auth.uid
        && resource.data.status == 'pending';
    }

    // ── User profiles ────────────────────────────────────────────────────────
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // ── OTP verifications (server-write only via Cloud Run service account) ──
    match /otp_verifications/{email} {
      allow read, write: if false; // Cloud Run uses Admin SDK (bypasses rules)
    }
  }
}
```

### 13.2 Firebase Auth Custom Claims

Set server-side after sign-up via `dawer-auth-service` (Admin SDK):
```json
{
  "role": "driver | supplier | recyclingCo",
  "supplierType": "individual | storeBusiness"
}
```

Claims are embedded in the JWT and available in Firestore rules as
`request.auth.token.role`. **Never set claims from the client** — this must be
server-side only.

### 13.3 Secrets Management

| Secret | Storage |
|---|---|
| Firebase project credentials | `google-services.json` / `GoogleService-Info.plist` (not committed; injected at CI/CD) |
| Maps API keys | `--dart-define=MAPS_API_KEY=...` at build time; restricted in Cloud Console |
| Cloud Run service account key | GCP Secret Manager; mounted as env var |
| Firebase Admin SDK key | GCP Secret Manager; Cloud Run env var |

**Remove** the hardcoded Supabase anon key fallback from `main.dart:42–43` before
any production build (identified as SEC-1 in ARCHITECTURE.md).

---

## 14. Risk Register & Rollback

| # | Risk | Likelihood | Impact | Mitigation | Rollback |
|---|---|---|---|---|---|
| R1 | Firebase Auth email OTP delivery failure | Medium | High | Use established email provider (SendGrid/Mailgun); test delivery rate before cutover | Fall back to email link sign-in temporarily |
| R2 | User migration: lost accounts (Supabase UID ≠ Firebase UID mismatch) | Medium | Critical | Maintain bidirectional UID mapping table; verify 100% of migrated users before cutover | Halt cutover; fix mapping; re-migrate |
| R3 | Firestore Security Rules too permissive | Medium | Critical | Automated rules testing (`firebase emulators:exec`); staged rollout | Deploy deny-all emergency rules immediately |
| R4 | Driver stream merge (two Firestore queries) causes duplicate orders in UI | Medium | Medium | Deduplicate by order.id in `FirestoreOrderRepository`; add unit test | Revert to single query with client-side filter |
| R5 | Google Maps API key not restricted → billing spike | High | High | Restrict to app bundle before launch; set billing alerts at $50/$200 | Disable key; rotate to restricted key |
| R6 | Firebase Realtime Database latency spike for GPS tracking | Low | Medium | Realtime DB is purpose-built; set alert on p99 > 500ms | Fall back to Firestore polling every 5s |
| R7 | Cloud Run cold start latency on reward calculation | Low | Low | Set `min-instances: 1` on `dawer-reward-service`; use local fallback | App uses `RewardService.calculate()` locally |
| R8 | Existing users can't log in after migration (password reset flow) | High | High | Send proactive "verify your account" email before cutover; password reset flow tested | Keep Supabase auth active in parallel for 30 days |
| R9 | `LocalStore` stale Supabase UIDs cause auth confusion | Medium | Medium | Version-gate `LocalStore` clear on first new-build launch | Force sign-out on UID format mismatch |
| R10 | App Store / Play Store review delays new Firebase build | Medium | Medium | Submit Firebase build 1 week before cutover date | Keep Supabase build as fallback if review delayed |

---

## 15. Testing Strategy

### 15.1 Unit Tests (no change to existing tests)

All existing tests in `test/data/` and `test/ui/` use `IOrderRepository`, `IAuthRepository`
interfaces — they pass unchanged. Add new test files:

```
test/data/
  firebase_auth_repository_test.dart    -- mock FirebaseAuth
  firestore_order_repository_test.dart  -- mock FirebaseFirestore (fake_cloud_firestore)
  firebase_storage_repository_test.dart -- mock FirebaseStorage

test/data/services/
  firebase_location_publisher_test.dart
  firebase_driver_location_stream_test.dart
```

Use `fake_cloud_firestore` package for Firestore unit tests:
```yaml
dev_dependencies:
  fake_cloud_firestore: ^3.0.0
  firebase_auth_mocks: ^0.14.0
```

### 15.2 Firestore Security Rules Tests

Use Firebase Emulator Suite:
```bash
firebase emulators:exec --only firestore "dart test test/security_rules/"
```

Test matrix:
- Supplier can only read/write own orders
- Driver can read pending feed; can only update own accepted orders
- RecyclingCo can only read/write own collection jobs
- Unauthenticated user receives PERMISSION_DENIED on all writes

### 15.3 Integration Tests (currently empty `test/integration/`)

```
test/integration/
  auth_flow_test.dart          -- sign-up OTP → profile created → session cached
  order_lifecycle_test.dart    -- create → accept → in-transit → complete (Firebase Emulator)
  location_tracking_test.dart  -- publisher write → stream read (RTDB Emulator)
  storage_upload_test.dart     -- profile photo upload → download URL
```

Run against Firebase Local Emulator Suite:
```bash
firebase emulators:start --only auth,firestore,database,storage
flutter test test/integration/ --dart-define=USE_FIREBASE=true --dart-define=FIREBASE_EMULATOR=true
```

### 15.4 Performance Tests

- Driver location stream latency: assert `Stream<LatLng>` emits within 300ms of RTDB write
- Firestore order write-to-read roundtrip: assert < 500ms on staging

### 15.5 Regression Test Gate

Before cutover, run the full test suite with both flags:
```bash
flutter test  # Supabase path — must still pass (0 failures)
flutter test --dart-define=USE_FIREBASE=true  # Firebase path — must pass (0 failures)
flutter analyze  # 0 issues
```

---

## 16. Appendix: Code Skeletons

### 16.1 New `pubspec.yaml` Dependencies

```yaml
dependencies:
  # existing...
  firebase_core: ^3.0.0
  firebase_auth: ^5.0.0
  cloud_firestore: ^5.0.0
  firebase_storage: ^12.0.0
  firebase_database: ^11.0.0
  firebase_messaging: ^15.0.0
  # keep supabase_flutter until Phase 8 cutover

dev_dependencies:
  # existing...
  fake_cloud_firestore: ^3.0.0
  firebase_auth_mocks: ^0.14.0
```

### 16.2 `firebase_auth_service.dart` Shell

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/result/result.dart';
import '../../domain/failures/app_failure.dart';
import '../../domain/repositories/i_file_storage_repository.dart';
import '../local/local_store.dart';
import '../models/user_role.dart';
import 'user_signup_service.dart' show SignUpRequest;

part 'firebase_auth_service/auth_helpers.dart';
part 'firebase_auth_service/signup_helpers.dart';

class FirebaseAuthService {
  FirebaseAuthService({required LocalStore store, IFileStorageRepository? fileStorage})
      : _store = store, _fileStorage = fileStorage;

  final LocalStore _store;
  final IFileStorageRepository? _fileStorage;
  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  Future<AppResult<Map<String, dynamic>>> signUp(
    SignUpRequest request, {File? profilePhoto, File? identityDocument}) =>
      performSignUp(request, profilePhoto: profilePhoto, identityDocument: identityDocument);

  Future<AppResult<Map<String, dynamic>>> signIn({
    required String identifier, required String password}) async {
    // ... FirebaseAuth.instance.signInWithEmailAndPassword
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return fetchCurrentProfile();
  }

  Future<void> logout() async {
    await _auth.signOut();
    await _store.clearCurrentUserId();
  }
}
```

### 16.3 `order_firestore_ext.dart` Shell

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'order.dart';

extension OrderFirestoreExt on Order {
  Map<String, dynamic> toFirestoreMap() => {
    'type': type.name,
    'status': status.name,
    'wasteTypes': wasteTypes.map((e) => e.name).toList(),
    if (pickupLat != null) 'pickupLat': pickupLat,
    if (pickupLng != null) 'pickupLng': pickupLng,
    if (dropoffLat != null) 'dropoffLat': dropoffLat,
    if (dropoffLng != null) 'dropoffLng': dropoffLng,
    'rewardJd': reward,
    'isMarketplaceShared': isMarketplaceShared,
    'requiresRider': requiresRider,
    'createdAt': FieldValue.serverTimestamp(),
    if (supplierId != null) 'supplierId': supplierId,
    // ... all other fields
  };
}

Order orderFromFirestoreDoc(DocumentSnapshot doc) {
  final json = doc.data() as Map<String, dynamic>;
  DateTime? ts(String key) =>
      (json[key] as Timestamp?)?.toDate();
  return Order(
    id: doc.id,
    type: parseEnum(json['type'] as String?, OrderType.values, OrderType.pickup),
    // ... complete field mapping
    createdAt: ts('createdAt') ?? DateTime.now(),
  );
}
```

---

## Summary: Phase Timeline

```
Week 1:   Phase 0 (setup) + Phase 1 (Firebase Auth)
Week 2:   Phase 2 (Firestore) + data migration scripts
Week 3:   Phase 3 (Storage) + Phase 4 (Realtime / GPS)
Week 4:   Phase 5 (Cloud Run) + Phase 6 (Maps)
Week 5:   Phase 7 (Flutter rewire + feature flag)
Week 6:   Integration testing + staging verification
Week 7:   [FILL: cutover date] → Phase 8 + 48h observation
Week 8+:  Monitoring, decommission Supabase (T+30d)
```

---

*Migration plan version 1.0 — Dawer v0.1.0 → Google Cloud*  
*Aligned with ARCHITECTURE.md §10 Migration Roadmap*
