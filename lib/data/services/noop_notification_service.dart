import '../../domain/services/i_notification_service.dart';

class NoopNotificationService implements INotificationService {
  const NoopNotificationService();

  @override
  Future<void> notifyProximity({
    required String orderId,
    required ProximityNotificationKind kind,
  }) async {}
}
