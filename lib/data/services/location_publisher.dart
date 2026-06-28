import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/services/supabase_service.dart';
import '../../domain/services/i_location_publisher.dart';

/// Tracks driver GPS position and publishes it to the `driver_locations` table
/// (the live-tracking source for customers and for the `verify_arrival` Edge
/// Function).
///
/// Publishing uses Supabase Realtime's backing Postgres row: each movement that
/// clears the [distanceFilter] (≈10 m, set below) upserts the driver's single
/// row keyed by `driver_id` (auth uid). Subscribers — the supplier/recycler on
/// the order — listen via Supabase Realtime on that table. This is the MVP-grade
/// equivalent of the AWS design doc's "fan-out on order:{id}": same UX, far
/// less infra. See `docs/architecture-decisions/backend-strategy.md`.
///
/// When Supabase is not initialized (offline / tests / mock mode), the position
/// is only logged — no network calls. RLS lets a driver write only their own row.
class LocationPublisher implements ILocationPublisher {
  LocationPublisher._();
  static final instance = LocationPublisher._();

  StreamSubscription<Position>? _sub;
  String? _orderId;

  bool get isPublishing => _sub != null;

  @override
  Future<void> start(String orderId) async {
    if (_sub != null) await stop();
    _orderId = orderId;

    final granted = await _ensurePermission();
    if (!granted) {
      debugPrint('[LocationPublisher] location permission denied');
      return;
    }

    // distanceFilter ≈ 10 m gives natural movement-throttle publishing: the
    // doc's 200 m / 15 s target is a *maximum* cadence for ETA cost control;
    // 10 m keeps the map smooth without flooding Postgres/Realtime.
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

    _sub = Geolocator.getPositionStream(locationSettings: settings).listen(
      _onPosition,
      onError: (Object e) => debugPrint('[LocationPublisher] stream error: $e'),
    );
  }

  Future<void> _onPosition(Position pos) async {
    final orderId = _orderId;
    if (orderId == null) return;

    // Publish only when Supabase is available + a driver session exists.
    if (!SupabaseService.isInitialized) {
      debugPrint(
        '[LocationPublisher] pos (offline): ${pos.latitude}, ${pos.longitude}',
      );
      return;
    }

    final driverId = SupabaseService.client.auth.currentUser?.id;
    if (driverId == null) {
      debugPrint('[LocationPublisher] no auth user; skipping publish');
      return;
    }

    try {
      await SupabaseService.client.from('driver_locations').upsert({
        'driver_id': driverId,
        'order_id': orderId,
        'lat': pos.latitude,
        'lng': pos.longitude,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (e) {
      // Best-effort: a dropped ping must not break tracking. The next movement
      // will retry. Live location is inherently lossy.
      debugPrint('[LocationPublisher] publish failed: $e');
    }
  }

  @override
  Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;
    _orderId = null;
  }

  Future<bool> _ensurePermission() async {
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    return perm == LocationPermission.whileInUse ||
        perm == LocationPermission.always;
  }
}
