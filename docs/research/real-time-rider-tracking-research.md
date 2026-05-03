# Real-Time Rider Tracking — Research & Implementation Plan

**Audience:** Engineering + Product stakeholders for the `dwaar` (Dowwer) Flutter app
**Version:** v1.0 — research phase
**Status:** Proposal for review — no code changes implied

---

## 1. Executive Summary

The app currently has **no backend and no real-time transport** — all order state lives in an in-memory Provider (`AppOrderStore`) seeded from mock data. Adding "live rider tracking" visible to suppliers, recycling companies, and other drivers therefore requires building three layers that do not yet exist:

1. A **cloud backend** with authenticated order + driver APIs
2. A **location-stream transport** (the driver publishes GPS at 3–10 s intervals; subscribers stream the same)
3. An **authorization model** scoping who can see which driver on which order

We recommend a **Firebase-based stack (Firestore + Cloud Functions + FCM)** for the MVP because it delivers authenticated real-time streaming out of the box with the lowest engineering cost, strong Flutter support, and mature security rules. A **Supabase/Postgres + WebSocket** alternative is viable if the team prefers self-hosting and SQL.

**Target performance:** < 3 s end-to-end latency (driver GPS → viewer screen), ±20 m horizontal accuracy, ≥ 95 % uptime for in-transit orders, battery impact < 4 % / hour for the driver.

**Phased rollout:** 4 milestones over ~8 weeks, starting with backend + auth (M1), then driver publish (M2), supplier live view (M3), and cross-role hardening + compliance (M4).

---

## 2. Scope & user roles

### 2.1 What "real-time rider tracking" means here

- Driver's current **lat/lng + heading + speed** published while an order's status is `inTransit`
- Updated at least every **3–10 seconds** (adaptive — see §7.1)
- Consumed by a **live map view** (deep-link to Google Maps for navigation, in-app placeholder badge showing ETA + last-seen-ago)
- Automatically **stopped** when status leaves `inTransit`, driver goes offline, or privacy revoked

### 2.2 Who can see a driver's location

| Viewer role | Can see driver location for | Justification |
|---|---|---|
| **Driver** (self) | Own orders | Self-view |
| **Supplier** (individual + business) | Orders they created, while `inTransit` + during active pickup window | Operational need — when is their waste being picked up |
| **Recycling company** | Orders dropping off at their facility while `inTransit` | Operational need — arrival planning |
| **Other drivers** | ❌ None | Privacy + no business need |
| **Admins / support** | All, via back-office audit view | Dispute resolution |

> **Conflict rule (from prompt):** When privacy and precision conflict, privacy wins. We **do not** broadcast driver location outside the `inTransit` window, and subscription is tied to the specific order participants listed above.

### 2.3 Out of scope (v1)

- Historical breadcrumb playback > 24 h
- Multi-driver simultaneous view on a single map (fleet dispatcher view)
- Geofencing-triggered status transitions (stretch goal — §13)

---

## 3. Proposed architecture

### 3.1 High-level diagram (textual)

```
 ┌─────────────────────┐     ┌──────────────────────────┐     ┌──────────────────────┐
 │   Driver App        │     │        Backend            │     │  Supplier / Company  │
 │  (Flutter)          │     │  (Firebase recommended)   │     │  App (Flutter)       │
 ├─────────────────────┤     ├──────────────────────────┤     ├──────────────────────┤
 │ geolocator stream   │──►──│ Cloud Function:           │     │ Firestore listener:  │
 │  @ 5 s cadence      │ WSS │  /trackingPings/write     │     │  orders/{id}/        │
 │ buffers offline     │     │   validates + writes to   │──►──│   driverLocation     │
 │ uploads on reconn.  │     │   orders/{id}/            │ WSS │  (realtime stream)   │
 │                     │     │    driverLocation         │     │                      │
 │ status: inTransit   │     │                           │     │ "last seen 3 s ago"  │
 │ publishing: true    │     │ Security Rules enforce    │     │ ETA recompute every  │
 └─────────────────────┘     │  who may read/write       │     │  30 s                │
                             │                           │     └──────────────────────┘
                             │ Scheduled cleanup:        │
                             │  purge pings > 24 h old   │
                             │ Audit log: /trackingAudit │
                             └──────────────────────────┘
```

### 3.2 Recommended stack (Option A — primary)

| Layer | Technology | Why |
|---|---|---|
| Auth | **Firebase Authentication** (phone OTP) | Matches existing OTP signup flow in the app |
| Data store | **Cloud Firestore** | Built-in real-time listeners, offline cache, security rules |
| Real-time channel | Firestore **snapshot listener** on `/orders/{id}/driverLocation` | No separate WebSocket infra |
| Serverless compute | **Cloud Functions (Node.js)** | Write validation, role-based access, cleanup jobs |
| Push notifications | **FCM** | "Your rider is on the way" + geofence alerts |
| CDN | **Firebase Hosting** (for admin dashboard if built) | Free tier suffices |
| Observability | **Firebase Crashlytics + Performance** + Google Cloud Logging | Built-in |

**Trade-off:** Firestore per-read pricing can surprise on high-cadence streams. Mitigation: write-rate capped to one ping per 5 s server-side; viewers auto-unsubscribe after order terminal state.

### 3.3 Alternative stack (Option B)

| Layer | Technology |
|---|---|
| Auth | Supabase Auth (phone / JWT) |
| Data | Postgres + PostGIS for coordinates |
| Real-time | Supabase Realtime (WAL → WebSocket) |
| Compute | Supabase Edge Functions (Deno) |
| Push | OneSignal or FCM via Supabase |

Pick B if team has SQL preference, needs PostGIS geometry ops (geofencing, nearest-neighbor), or wants self-host option.

### 3.4 Non-viable options (documented for completeness)

- **MQTT broker on VPS**: lowest latency but highest ops overhead; rejected for MVP.
- **Polling**: 30 s polling would meet "real-time" loosely but 10× the Firestore cost and UX lag; rejected.
- **WebRTC peer-to-peer**: impossible through NAT without a TURN server; unsuitable.

---

## 4. Data model

### 4.1 New collections / tables (Firestore schema shown; Postgres analogous)

#### `orders/{orderId}` (extends existing `Order` class)
No new top-level fields; the live location lives in a subcollection so it can be secured separately and pruned independently.

#### `orders/{orderId}/driverLocation/current` (singleton doc per order)
```json
{
  "orderId": "ORD-S01",
  "driverId": "DRV-007",
  "lat": 31.95329,
  "lng": 35.91123,
  "heading": 87.4,             // degrees, 0-360
  "speed": 9.2,                // m/s
  "accuracy": 12.0,            // meters (GPS horizontal)
  "capturedAt": 1718000000000, // device timestamp (ms epoch)
  "receivedAt": 1718000001834, // server timestamp
  "battery": 72,               // optional, 0-100
  "source": "gps"              // "gps" | "network" | "fused"
}
```

#### `trackingPings/{orderId}/history/{pingId}` (append-only, pruned after 24 h)
Same schema as `current`, persisted for dispute resolution. Ring-buffered by Cloud Function, retention configurable.

#### `trackingAudit/{auditId}`
```json
{
  "actor": "SUP-042",
  "action": "VIEW",
  "orderId": "ORD-S01",
  "driverId": "DRV-007",
  "at": 1718000000000,
  "ip": "redacted-hash"
}
```
Write-once; read only by admins. Supports GDPR "who saw my data" requests.

### 4.2 Flutter-side model additions (when we build)

```dart
class DriverLocationPing {
  final String orderId;
  final String driverId;
  final double lat;
  final double lng;
  final double? heading;
  final double? speed;
  final double accuracy;
  final DateTime capturedAt;
  final DateTime receivedAt;
}

// Exposed from a new service:
Stream<DriverLocationPing?> driverLocationStream(String orderId);
```

No changes to the existing `Order` class — keeping the real-time data as a sidecar stream avoids bloating the main model and keeps the offline cache lean.

---

## 5. API design

### 5.1 Write path — driver publishes location

Firestore direct writes are rate-limited and validated by security rules + an onWrite Cloud Function. No REST endpoint exposed.

**Client code (driver app)** writes:
```
PATH:    orders/{orderId}/driverLocation/current
METHOD:  set() with merge
AUTH:    Firebase ID token (signed-in driver)
RATE:    client-side throttled to 1 / 5 s
```

**Security rule (Firestore):**
```javascript
match /orders/{orderId}/driverLocation/current {
  allow write: if request.auth != null
    && request.auth.uid == get(/databases/$(db)/documents/orders/$(orderId)).data.driverId
    && get(/databases/$(db)/documents/orders/$(orderId)).data.status == "inTransit"
    && request.time > resource.data.receivedAt + duration.value(4, "s"); // rate-limit
}
```

### 5.2 Read path — viewer subscribes

```
PATH:    orders/{orderId}/driverLocation/current
METHOD:  snapshots() (Firestore real-time listener)
AUTH:    Firebase ID token
GUARD:   rules enforce viewer ∈ {driver, supplier of the order, recycling company of the order, admin}
```

**Security rule (read):**
```javascript
match /orders/{orderId}/driverLocation/current {
  allow read: if request.auth != null
    && resource != null
    && (
      request.auth.uid == get(/.../orders/$(orderId)).data.driverId ||
      request.auth.uid == get(/.../orders/$(orderId)).data.supplierId ||
      request.auth.uid == get(/.../orders/$(orderId)).data.recyclingCompanyId ||
      request.auth.token.role == "admin"
    )
    && get(/.../orders/$(orderId)).data.status == "inTransit";
}
```

### 5.3 Lifecycle endpoints (Cloud Functions, optional convenience REST)

| Endpoint | Method | Body | Auth | Purpose |
|---|---|---|---|---|
| `/tracking/start` | POST | `{orderId}` | Driver | Mark order `inTransit`, enable publish |
| `/tracking/stop`  | POST | `{orderId, reason}` | Driver | Mark order `completed\|cancelled`, delete `current` doc |
| `/tracking/revoke` | POST | `{orderId}` | Supplier / admin | Force-stop publishing (privacy complaint) |
| `/tracking/history` | GET | `?orderId=` | Order participants | Return recent breadcrumb pings (last 24 h) for audit |

All endpoints return problem+json on errors, include idempotency keys for retries, and enforce the same role rules as Firestore rules.

### 5.4 Payload sizes & throughput

- Ping payload: ~160 bytes (JSON) → ~60 bytes (binary, if we ever move to MQTT/proto)
- 1 ping / 5 s × 1 active delivery × 30 min average = 360 pings/order
- 1000 concurrent deliveries × 360 pings = 360k writes / 30 min → ~12 writes/s sustained (well within Firestore quotas)

---

## 6. Latency & accuracy targets

| Metric | Target | Rationale |
|---|---|---|
| **End-to-end latency** (device → viewer) | p50 < 2 s, p95 < 5 s | Perceived "live" feel |
| **Horizontal accuracy** | ± 20 m urban, ± 50 m peri-urban | Adequate for "rider is close" UX without requiring RTK GPS |
| **Update cadence** | 5 s default, 3 s when < 500 m from destination, 10 s when stationary > 60 s | Battery/cost trade-off |
| **Tile-to-screen animation latency** | < 200 ms on viewer after stream update | Use `AnimatedPositioned` with Firestore snapshot timestamp |
| **Reconnection backoff** | 1 s → 2 s → 4 s → 8 s → 16 s capped at 30 s | Exponential with jitter |
| **Offline buffer** | Up to 5 min of pings retained on-device | Preserves breadcrumbs through tunnels / dead zones |
| **Stale-after** | Viewer shows "last seen N s/min ago" after 15 s with no update | Sets user expectations |

### 6.1 Retry / backpressure logic

1. **Driver side:** `geolocator` emits, client writes to Firestore with `writeWithPendingWritesStream`. Firestore SDK handles offline queueing. If buffer > 5 min, oldest is dropped with audit record.
2. **Server side:** Rate limit via security rule timestamp check rejects >1/4 s bursts.
3. **Viewer side:** Snapshot listener auto-reconnects. If no update for 15 s, UI switches to "last seen" badge. If no update for 120 s, prompt "Refresh driver location?".

---

## 7. Battery & bandwidth considerations

### 7.1 Adaptive cadence (must-have)

| Condition | Cadence | Accuracy setting |
|---|---|---|
| Approaching destination (< 500 m) | 3 s | `high` |
| Moving > 3 m/s | 5 s | `balanced` |
| Stationary > 60 s | 20 s | `balanced` |
| Stationary > 5 min | 60 s + keep-alive ping | `low` |
| Offline | Local buffer, flush on reconnect | unchanged |

### 7.2 Battery targets

- **< 4 %/hour** incremental battery draw on a mid-range Android (e.g., Galaxy A34). Validated on real hardware during M2 QA.
- Platform-specific:
  - **Android**: foreground service with persistent notification ("Dowwer is tracking your delivery"). Required by Play policy for background location on Android 10+.
  - **iOS**: `locationAlwaysAndWhenInUseUsageDescription` with "Always" permission for in-transit orders, reverting to "While Using" otherwise. Obey iOS deferred location updates to coalesce pings.

### 7.3 Bandwidth

- ~32 KB / hour / driver in flight. Negligible on Wi-Fi; one-day delivery of 8 h uses ~250 KB of cellular.

---

## 8. Privacy, security, and compliance

### 8.1 Principles

1. **Minimize** — collect only lat/lng/heading/accuracy + timestamps. No continuous background tracking when no order is `inTransit`.
2. **Purpose-bind** — location is readable *only* for the specific order's lifetime.
3. **Retain briefly** — detailed breadcrumbs purged after 24 h; only aggregate metrics survive longer (see §10).
4. **Audit** — every read by a non-self viewer writes to `trackingAudit`.
5. **Transparent** — driver sees a persistent "live" indicator whenever publishing.

### 8.2 Consent flow (driver)

- **Sign-up**: clear disclosure that accepting orders will share live location with the order participants during `inTransit`.
- **Per-order**: when driver taps "Start delivery" → status becomes `inTransit` → OS location permission re-confirmed if needed → live indicator becomes visible.
- **Revoke**: driver can force-stop publishing (cancels the order).
- **Data rights**: in-app endpoint `/me/tracking-history` returns all pings collected about the user in the last 24 h (GDPR Art. 15).

### 8.3 Access controls

- **Role-based** at the security-rule level (not app-layer).
- **Order-scoped**: viewer must be a declared participant of *that* order.
- **Time-scoped**: status must be `inTransit`.
- **Admin access**: requires explicit admin custom claim; every read audited; support staff see a banner confirming the viewed is a user, not an admin test record.
- **PII separation**: `driverLocation/current` does **not** include driver name/phone; viewers already have those from the `Order` doc they are authorized to read.

### 8.4 Compliance notes (Jordan market + general best practices)

- **PDPL (Jordan Personal Data Protection Law, 2023)** — requires informed consent, purpose limitation, storage limitation. Our design satisfies all three.
- **Google Play / App Store policies** — foreground service + clear notification + privacy policy update covering "precise location during deliveries".
- **GDPR-style rights** — supported even if not strictly required, via audit log + self-serve data export endpoint.

### 8.5 Security hardening checklist

- [ ] All traffic over TLS 1.3
- [ ] Firebase App Check enabled (bot/spoof protection)
- [ ] Security rules unit-tested (Firebase Emulator + CI)
- [ ] Cloud Function request validation via Zod schemas
- [ ] No coordinates in crash logs or analytics events
- [ ] Rate limiting per driver UID on write (defense-in-depth beyond client throttle)
- [ ] Anomaly detection: reject pings > 300 km/h or teleports > 2 km between consecutive reports

---

## 9. UI/UX implications

### 9.1 Driver app (publisher)

- When `inTransit` begins, show a **persistent green bar** at the top: "📡 Live tracking on — tap to stop". Foreground service notification with same message.
- Expose a "Privacy" screen showing who can currently see me (order participants), last shared time, and a "Pause for 60 s" escape valve.
- Ensure the "Open in Google Maps" FAB (recently added) and live-tracking coexist — the FAB takes the driver out for navigation but the background service keeps publishing.

### 9.2 Supplier / Recycling company (viewers)

- On the existing `RouteMapPlaceholder`, when live data is available, add a **pulsing dot** at the driver's latest position with heading indicator.
- Show a compact status chip: "🟢 Live • 3 s ago • ETA 6 min".
- When stale (> 15 s): chip turns amber, text becomes "Last seen 18 s ago".
- When offline (> 120 s): chip red, CTA "Call driver" surfaces.
- The Google Maps deep-link stays — tapping it navigates to the driver's latest lat/lng (not pickup→dropoff), which is more useful for "where are they now".

### 9.3 RTL / localization

- All new strings added to `app_ar.arb` + `app_en.arb` using the existing `context.l10n` pattern.
- Live indicator uses `PositionedDirectional` so it flips correctly in Arabic.
- Timestamps rendered via `Intl.DateFormat.yMd(locale)` to respect numeric conventions.

### 9.4 Accessibility

- Live chip has `Semantics(label: ...)` including freshness.
- Motion-sensitive users can disable the pulse animation (setting: "Reduce motion").

---

## 10. Metrics & success criteria

### 10.1 Product KPIs

| Metric | Target | Measurement |
|---|---|---|
| % in-transit orders with ≥ 80 % session coverage | ≥ 90 % | `(active ping window / inTransit duration) ≥ 0.8` |
| Supplier sessions viewing live tracking per order | ≥ 0.6 avg | Firestore listener-open events |
| Support tickets citing "where is my driver" | −50 % vs. baseline | Ticket tagging |
| Driver uninstall rate post-launch | ≤ baseline + 2 pts | Play/App Store analytics |

### 10.2 Engineering SLOs

| Metric | Target |
|---|---|
| p95 end-to-end latency | < 5 s |
| Tracking uptime during in-transit orders | ≥ 99 % |
| Median battery draw added by tracking | ≤ 4 %/hr |
| Crash-free sessions in tracking code paths | ≥ 99.8 % |
| Cost per active delivery | ≤ $0.02 (Firestore reads + writes) |

### 10.3 Privacy metrics (reviewed monthly)

- Zero out-of-scope reads (non-participant reads audited to 0)
- Zero cases of publishing when status ≠ `inTransit`
- Mean time to purge ping history: ≤ 26 h

---

## 11. Testing strategy

### 11.1 Unit

- Security rules test suite (Firebase rules emulator) — every rule branch tested positive + negative.
- Cadence throttler: simulate fast/slow/stationary scenarios, assert cadence adapts.
- Ping validator: reject malformed, rate-abusive, out-of-range coordinates.

### 11.2 Integration

- Flutter integration test with Firebase Emulator: driver writes, supplier reads, status change severs subscription.
- Simulated offline/online: buffer then flush; assert no lost pings up to 5 min.

### 11.3 End-to-end

- Two-device scripted test (driver emulator + supplier emulator) walking a pre-recorded GPS trace. Assert viewer sees ≥ 95 % of pings within latency target.
- Real-device battery test (Pixel 6a + iPhone 13) on 60-min route; power profiler snapshot.

### 11.4 Load

- Synthetic 1,000 concurrent drivers × 1 ping / 5 s for 60 min. Validate Firestore cost model + quota headroom.

### 11.5 Security

- Abuse test: non-participant user attempts to subscribe → expect permission-denied.
- Replay attack: inject old pings via captured token → rejected by server timestamp check.
- Pen-test scope item for external firm before GA.

---

## 12. Risk register & mitigations

| # | Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|---|
| R1 | Firestore cost spike from high-cadence streams | M | H | Adaptive cadence, server-side rate limit, cost alerting at 80 % budget |
| R2 | Driver privacy complaint / regulator inquiry | L | H | Audit log, clear consent, easy revoke, purge policy |
| R3 | Battery drain pushes driver app off store top-rated | M | M | Battery budget testing in M2, adaptive cadence, foreground service notification clarity |
| R4 | GPS inaccuracy in downtown Amman urban canyons | H | M | Accept ±50 m, display "accuracy circle" in UI, blend network + GPS |
| R5 | Order hand-off (driver swap mid-route) | L | M | Close subscription on `driverId` change; issue new security token |
| R6 | Offline driver disappears from viewer | H | L | 15 s stale chip + 120 s escalation, breadcrumb replay on reconnect |
| R7 | Vendor lock-in (Firebase) | M | M | Abstract behind `TrackingService` interface so Option B (Supabase) is swappable without UI changes |
| R8 | RTL display bugs on live chip | L | L | Covered by snapshot tests in AR and EN |

---

## 13. Phased implementation roadmap

### Milestone 1 — Backend foundation *(2 weeks)*

- Stand up Firebase project (dev + staging + prod)
- Migrate `User` and `Order` models to Firestore; write Dart data-access layer behind `AppOrderStore` so UI is unchanged
- Implement phone-OTP auth using existing UX
- Write security rule skeleton (no tracking yet) + CI emulator tests
- **Exit criteria:** existing features work against Firebase, zero regressions in `flutter analyze` / tests

### Milestone 2 — Driver publish pipeline *(2 weeks)*

- Build `TrackingPublisher` service (cadence adapter, buffer, Firebase writer)
- Add foreground service (Android) / always-permission prompt (iOS)
- Add "live" indicator UI + privacy screen in driver app
- Cloud Function: rate-limit, history ring buffer, anomaly rejection
- Battery + network profiling on real devices
- **Exit criteria:** SLO targets met in internal QA; battery ≤ 4 %/hr

### Milestone 3 — Viewer experience *(2 weeks)*

- `TrackingSubscriber` service + Flutter stream-based provider
- Integrate live dot + freshness chip into `RouteMapPlaceholder`
- Update Google Maps deep-link to use latest driver position
- Localize 12–18 new ARB keys (AR + EN)
- Audit-log viewer events
- **Exit criteria:** supplier + recycling company viewers working end-to-end; latency p95 < 5 s

### Milestone 4 — Hardening, compliance, launch *(2 weeks)*

- Security pen-test (external firm) + fixes
- Privacy policy update, in-app consent copy, app-store listing updates
- Load test 1k concurrent, cost validation
- Gradual rollout (5 % → 25 % → 100 %) gated by SLO dashboards
- Retrospective + telemetry review
- **Exit criteria:** GA, KPIs meeting §10 targets

### Stretch (M5+)

- Geofenced auto-status transitions (entering pickup radius → notify supplier)
- Fleet-admin dispatcher view with all active drivers on a map
- ETA predicted via road graph + live traffic
- Predictive delivery time for suppliers via ML on historic data

---

## 14. Resource & dependency assessment

### 14.1 Team

- 1 × senior Flutter engineer (0.8 FTE, 8 weeks)
- 1 × backend / Cloud Functions engineer (0.6 FTE, 8 weeks)
- 0.3 FTE QA with real-device lab access
- 0.2 FTE product + compliance review
- External: pen-test vendor (M4 only)

### 14.2 External dependencies

| Dependency | Owner | Required by |
|---|---|---|
| Firebase project + billing | Ops | M1 |
| Apple Developer team (LSApplicationQueriesSchemes, capabilities) | Ops | M2 |
| Google Play Console (foreground-service declaration, Location Policy) | Ops | M2 |
| Privacy policy legal review | Legal | M4 |
| App Check attestation (Play Integrity + App Attest) | Ops | M4 |

### 14.3 Risks to schedule

- Play Store Location Policy review can take 7–14 days; start M2 submission early.
- Phone OTP rate limits may need quota increase for staging load tests.

---

## 15. Inputs still needed

The following were marked `[FILL: …]` in the prompt and would sharpen this plan:

- **[FILL: target audience]** — confirmed as suppliers + recycling companies + drivers (self). Please confirm whether back-office/admin is in scope for v1.
- **[FILL: platform constraints]** — confirm minimum supported Android (8.0? 10?) and iOS (15?) to scope foreground-service and always-location work.
- **[FILL: data privacy requirements]** — which regulatory regime formally applies (Jordan PDPL, GDPR, both)? Drives retention + data-request SLAs.
- **[FILL: known limitations]** — budget ceiling for infra and pen-test? Preference between Firebase and self-hosted (Supabase / custom) stacks?

Once these are supplied, Milestone 1 can begin with a firm design doc.

---

## 16. Appendix — recommended libraries (Flutter side)

| Purpose | Package | Status |
|---|---|---|
| Location stream | `geolocator: ^13` | Already in pubspec |
| Firebase | `firebase_core`, `cloud_firestore`, `firebase_auth`, `firebase_messaging`, `firebase_app_check` | New |
| Foreground service | `flutter_foreground_task` | New (Android) |
| Background tasks | `workmanager` (optional for deferred flush) | New |
| State | `provider` | Already in pubspec |
| Validation (server side, TS) | `zod`, `firebase-functions`, `firebase-admin` | New |

---

*End of research plan.*
