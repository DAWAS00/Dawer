import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../domain/services/i_notification_service.dart';

/// Top-level handler for background/terminated FCM messages.
/// Must be a top-level function (not a class method) — FCM requirement.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase is already initialized by the time this runs.
  debugPrint('[FCM] Background message: ${message.messageId}');
}

class FcmNotificationService implements INotificationService {
  FcmNotificationService._();
  static final instance = FcmNotificationService._();

  final _fcm = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  static const _androidChannel = AndroidNotificationChannel(
    'dawer_high_importance',
    'Dawer Notifications',
    description: 'Order status, driver proximity, and platform alerts',
    importance: Importance.high,
  );

  Future<void> init() async {
    // Register background handler before anything else.
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Request permission (Android 13+ / iOS).
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Create the Android notification channel.
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);

    // Initialize flutter_local_notifications for foreground display.
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await _localNotifications.initialize(initSettings);

    // Show a local notification when the app is in the foreground.
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Log token for testing.
    final token = await _fcm.getToken();
    debugPrint('[FCM] Device token: $token');

    // Refresh token listener.
    _fcm.onTokenRefresh.listen((newToken) {
      debugPrint('[FCM] Token refreshed: $newToken');
      // TODO: save newToken to Supabase profiles.fcm_token for this user
    });
  }

  /// Returns the current FCM registration token, or null if unavailable.
  Future<String?> getToken() => _fcm.getToken();

  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }

  @override
  Future<void> notifyProximity({
    required String orderId,
    required ProximityNotificationKind kind,
  }) async {
    final title = kind == ProximityNotificationKind.riderNearPickup
        ? 'السائق على وشك الوصول'
        : 'السائق وصل لنقطة التسليم';
    final body = kind == ProximityNotificationKind.riderNearPickup
        ? 'السائق على بعد دقائق من موقع الاستلام'
        : 'تم الوصول إلى نقطة التسليم للطلب $orderId';

    await _localNotifications.show(
      orderId.hashCode,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }
}
