import 'dart:async';
import 'dart:io';

import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/utils/app_logger.dart';
import '../../domain/services/i_location_publisher.dart';

/// Publishes the driver's GPS position to the `driver_locations` table in
/// Supabase via a single-row upsert (primary key = driver_id).
///
/// Usage:
///   await LocationPublisher.instance.start(orderId);   // on order accept
///   await LocationPublisher.instance.stop();            // on complete / cancel
class LocationPublisher implements ILocationPublisher {
  LocationPublisher._();
  static final instance = LocationPublisher._();

  StreamSubscription<Position>? _sub;
  String? _orderId;

  bool get isPublishing => _sub != null;

  // ── Public API ────────────────────────────────────────────────────────────

  @override
  Future<void> start(String orderId) async {
    if (_sub != null) await stop();

    final granted = await _ensurePermission();
    if (!granted) {
      AppLogger.warn('LocationPublisher', 'location permission denied');
      return;
    }

    _orderId = orderId;

    final settings = Platform.isAndroid
        ? AndroidSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10,
            foregroundNotificationConfig: const ForegroundNotificationConfig(
              notificationTitle: 'دوّر — تتبع الموقع',
              notificationText: 'جاري تتبع موقعك لإتمام الطلب',
              enableWakeLock: true,
            ),
          )
        : const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10,
          );

    _sub = Geolocator.getPositionStream(locationSettings: settings)
        .listen((pos) => _upsert(pos, orderId));
  }

  @override
  Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;
    if (_orderId != null) {
      await _deleteRow(_orderId!);
      _orderId = null;
    }
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  Future<bool> _ensurePermission() async {
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    return perm == LocationPermission.whileInUse ||
        perm == LocationPermission.always;
  }

  Future<void> _upsert(Position pos, String orderId) async {
    try {
      final uid = Supabase.instance.client.auth.currentUser?.id;
      if (uid == null) return;
      await Supabase.instance.client.from('driver_locations').upsert({
        'driver_id': uid,
        'order_id': orderId,
        'lat': pos.latitude,
        'lng': pos.longitude,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (e) {
      AppLogger.error('LocationPublisher', e);
    }
  }

  Future<void> _deleteRow(String orderId) async {
    try {
      final uid = Supabase.instance.client.auth.currentUser?.id;
      if (uid == null) return;
      await Supabase.instance.client
          .from('driver_locations')
          .delete()
          .eq('driver_id', uid)
          .eq('order_id', orderId);
    } catch (e) {
      AppLogger.error('LocationPublisher', e);
    }
  }
}
