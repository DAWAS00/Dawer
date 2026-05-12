import 'dart:async';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/utils/app_logger.dart';

/// Subscribes to the `driver_locations` table for a single order and exposes
/// the driver's position as a [Stream<LatLng>].
///
/// The stream emits the last known position immediately (via an initial SELECT),
/// then continues emitting on every Supabase Realtime change event.
///
/// Dispose the subscription to unsubscribe the Realtime channel.
class DriverLocationStream {
  static Stream<LatLng> forOrder(String orderId) {
    final ctrl = StreamController<LatLng>.broadcast();

    // Fetch the latest known position right away so the map isn't blank.
    Supabase.instance.client
        .from('driver_locations')
        .select('lat, lng')
        .eq('order_id', orderId)
        .maybeSingle()
        .then((row) {
      if (row != null && !ctrl.isClosed) {
        ctrl.add(LatLng(
          (row['lat'] as num).toDouble(),
          (row['lng'] as num).toDouble(),
        ));
      }
    }).catchError((e) {
      AppLogger.error('DriverLocationStream', e);
    });

    // Realtime subscription — fires on INSERT or UPDATE to this order's row.
    final channel = Supabase.instance.client
        .channel('driver-tracking-$orderId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'driver_locations',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'order_id',
            value: orderId,
          ),
          callback: (payload) {
            final row = payload.newRecord;
            final lat = (row['lat'] as num?)?.toDouble();
            final lng = (row['lng'] as num?)?.toDouble();
            if (lat != null && lng != null && !ctrl.isClosed) {
              ctrl.add(LatLng(lat, lng));
            }
          },
        )
        .subscribe();

    ctrl.onCancel = () {
      Supabase.instance.client
          .removeChannel(channel)
          .catchError((Object e) { AppLogger.error('DriverLocationStream', e); return ''; });
      ctrl.close();
    };

    return ctrl.stream;
  }
}
