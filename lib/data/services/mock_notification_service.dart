import '../../domain/services/i_notification_service.dart';

// ── MockNotificationService ───────────────────────────────────────────────────
//
// Records every notification call in-memory. Useful for:
//   • Unit tests — assert that the VM fires exactly the right notifications.
//   • UI development — no real FCM token needed.
//
// Backend extension: replace with a real FCM + Supabase edge-function call.

class MockNotificationService implements INotificationService {
  final List<({String orderId, ProximityNotificationKind kind})> _log = [];

  /// Read-only log of every notification dispatched so far.
  List<({String orderId, ProximityNotificationKind kind})> get log =>
      List.unmodifiable(_log);

  @override
  Future<void> notifyProximity({
    required String orderId,
    required ProximityNotificationKind kind,
  }) async {
    _log.add((orderId: orderId, kind: kind));
  }

  void clear() => _log.clear();
}
