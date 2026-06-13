import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:dwaar/core/constants/app_colors.dart';
import 'package:dwaar/data/models/order/order.dart';
import 'package:dwaar/data/services/driver_location_stream.dart';
import 'package:dwaar/l10n/l10n.dart';
import 'package:dwaar/ui/common/map/live_tracking_map_view.dart';
import 'package:dwaar/ui/common/map/pickup_map_view.dart';
import 'package:dwaar/ui/common/map/route_map_placeholder.dart';

class OrderMapSection extends StatelessWidget {
  final Order order;
  final bool hasDriver;

  const OrderMapSection({
    super.key,
    required this.order,
    required this.hasDriver,
  });

  // UUIDs are exactly 36 characters (8-4-4-4-12 with dashes).
  static bool _isUuid(String id) => id.length == 36;

  @override
  Widget build(BuildContext context) {
    final pLat = order.pickupLat;
    final pLng = order.pickupLng;
    final dLat = order.dropoffLat;
    final dLng = order.dropoffLng;

    Widget mapContent;

    // Live tracking: driver accepted and is en-route — show moving driver marker.
    if (hasDriver &&
        order.status == OrderStatus.inTransit &&
        pLat != null &&
        pLng != null) {
      mapContent = _isUuid(order.id)
          ? _RealTrackingWrapper(
              orderId: order.id,
              pickupLat: pLat,
              pickupLng: pLng,
              etaMinutes: order.etaMinutes,
              height: 240,
            )
          : _MockTrackingWrapper(
              pickupLat: pLat,
              pickupLng: pLng,
              etaMinutes: order.etaMinutes,
              height: 240,
            );
    } else if (pLat != null && dLat != null) {
      mapContent = RouteMapPlaceholder(
        pickupLat: pLat,
        pickupLng: pLng!,
        dropoffLat: dLat,
        dropoffLng: dLng!,
        height: 240,
      );
    } else if (pLat != null) {
      mapContent = PickupMapView(lat: pLat, lng: pLng!, height: 240);
    } else {
      mapContent = const _MapPlaceholder();
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: mapContent,
      ),
    );
  }
}

// ── Real tracking — Supabase Realtime (Phase 3) ───────────────────────────────

class _RealTrackingWrapper extends StatefulWidget {
  final String orderId;
  final double pickupLat;
  final double pickupLng;
  final int? etaMinutes;
  final double height;

  const _RealTrackingWrapper({
    required this.orderId,
    required this.pickupLat,
    required this.pickupLng,
    this.etaMinutes,
    required this.height,
  });

  @override
  State<_RealTrackingWrapper> createState() => _RealTrackingWrapperState();
}

class _RealTrackingWrapperState extends State<_RealTrackingWrapper> {
  late final Stream<LatLng> _stream;

  @override
  void initState() {
    super.initState();
    _stream = DriverLocationStream.forOrder(widget.orderId);
  }

  @override
  Widget build(BuildContext context) {
    return LiveTrackingMapView(
      pickupLat: widget.pickupLat,
      pickupLng: widget.pickupLng,
      // No initial position — LiveTrackingMapView shows "جاري تحديد الموقع"
      // until the stream emits the first event from Supabase.
      driverStream: _stream,
      etaMinutes: widget.etaMinutes,
      height: widget.height,
    );
  }
}

// ── Phase-1 mock driver stream (used for local / non-Supabase orders) ─────────

class _MockTrackingWrapper extends StatefulWidget {
  final double pickupLat;
  final double pickupLng;
  final int? etaMinutes;
  final double height;

  const _MockTrackingWrapper({
    required this.pickupLat,
    required this.pickupLng,
    this.etaMinutes,
    required this.height,
  });

  @override
  State<_MockTrackingWrapper> createState() => _MockTrackingWrapperState();
}

class _MockTrackingWrapperState extends State<_MockTrackingWrapper> {
  late final StreamController<LatLng> _ctrl;
  late Timer _timer;

  // Driver starts ~1.3 km north-west of pickup and converges each tick.
  late double _dLat = widget.pickupLat + 0.013;
  late double _dLng = widget.pickupLng - 0.010;

  @override
  void initState() {
    super.initState();
    _ctrl = StreamController<LatLng>();
    // Move 20 % closer to pickup every 5 s.
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      _dLat += (widget.pickupLat - _dLat) * 0.20;
      _dLng += (widget.pickupLng - _dLng) * 0.20;
      if (!_ctrl.isClosed) _ctrl.add(LatLng(_dLat, _dLng));
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _ctrl.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LiveTrackingMapView(
      pickupLat: widget.pickupLat,
      pickupLng: widget.pickupLng,
      initialDriverLat: _dLat,
      initialDriverLng: _dLng,
      driverStream: _ctrl.stream,
      etaMinutes: widget.etaMinutes,
      height: widget.height,
    );
  }
}

// ── Fallback placeholder (used when coords are null) ─────────────────────────

class _MapPlaceholder extends StatelessWidget {
  const _MapPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 240,
      color: AppColors.mapSurface,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.map_outlined,
                size: 32, color: AppColors.primaryGreen),
            const SizedBox(height: 8),
            Text(
              context.l10n.mapUnavailable,
              style: GoogleFonts.cairo(
                fontSize: 13,
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
