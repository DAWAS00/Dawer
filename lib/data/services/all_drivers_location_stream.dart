import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Subscribes to ALL rows in `driver_locations` (no order-id filter) and
/// emits a map from driver_id → latest [LatLng].
///
/// Use this in the Recycling Company "ops map" to show all active drivers.
/// Distinct from [DriverLocationStream] which scopes to a single order.
///
/// The stream emits on any INSERT/UPDATE to the table. On Realtime disconnect
/// an error event is added to the stream so consumers can show a reconnecting
/// banner (TD6).
class AllDriversLocationStream {
  static Stream<Map<String, LatLng>> watch() {
    // Mutable state that accumulates all known driver positions.
    final positions = <String, LatLng>{};
    final ctrl = StreamController<Map<String, LatLng>>.broadcast();

    // Seed with current snapshot so the map is not blank on first open.
    Supabase.instance.client
        .from('driver_locations')
        .select('driver_id, lat, lng')
        .then((rows) {
      if (ctrl.isClosed) return;
      for (final row in rows) {
        final id = row['driver_id'] as String?;
        final lat = (row['lat'] as num?)?.toDouble();
        final lng = (row['lng'] as num?)?.toDouble();
        if (id != null && lat != null && lng != null) {
          positions[id] = LatLng(lat, lng);
        }
      }
      if (!ctrl.isClosed) ctrl.add(Map.unmodifiable(positions));
    }).catchError((Object e) {
      debugPrint('[AllDriversLocationStream] initial fetch error: $e');
    });

    // Realtime subscription — no filter, watches the entire table.
    final channel = Supabase.instance.client
        .channel('all-drivers-tracking')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'driver_locations',
          callback: (payload) {
            final row = payload.newRecord;
            final id = row['driver_id'] as String?;
            final lat = (row['lat'] as num?)?.toDouble();
            final lng = (row['lng'] as num?)?.toDouble();
            if (id != null && lat != null && lng != null && !ctrl.isClosed) {
              positions[id] = LatLng(lat, lng);
              ctrl.add(Map.unmodifiable(positions));
            }
          },
        )
        .subscribe((status, [error]) {
          if (error != null) {
            debugPrint('[AllDriversLocationStream] subscribe error: $error');
            if (!ctrl.isClosed) ctrl.addError(error);
          }
        });

    ctrl.onCancel = () {
      Supabase.instance.client.removeChannel(channel).catchError(
        (Object e) {
          debugPrint('[AllDriversLocationStream] remove channel: $e');
          return '';
        },
      );
      ctrl.close();
    };

    return ctrl.stream;
  }
}
