// ── INotificationService ──────────────────────────────────────────────────────
//
// Minimal abstraction for push / in-app notifications triggered by proximity
// events. Swap the mock with a real FCM/local-notifications impl at backend
// integration time — [RiderProximityViewModel] never changes.

enum ProximityNotificationKind { riderNearPickup, riderNearDropoff }

abstract interface class INotificationService {
  /// Sends a notification to the relevant party (customer / supplier) that
  /// the rider is near the [kind] location for [orderId].
  Future<void> notifyProximity({
    required String orderId,
    required ProximityNotificationKind kind,
  });
}
