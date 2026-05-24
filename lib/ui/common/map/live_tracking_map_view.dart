import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:dwaar/core/constants/app_colors.dart';

/// Full-map live tracking view with two markers:
///   • Green pin  — static pickup point
///   • Blue marker — rider position, updated via [driverStream]
///
/// [initialDriverLat]/[initialDriverLng] seed the driver marker immediately.
/// When null (real-backend mode), the driver marker is hidden until the first
/// stream event arrives. Camera fits both markers once both are known.
class LiveTrackingMapView extends StatefulWidget {
  final double pickupLat;
  final double pickupLng;
  final double? initialDriverLat;
  final double? initialDriverLng;
  final Stream<LatLng> driverStream;
  final int? etaMinutes;
  final double height;

  const LiveTrackingMapView({
    super.key,
    required this.pickupLat,
    required this.pickupLng,
    this.initialDriverLat,
    this.initialDriverLng,
    required this.driverStream,
    this.etaMinutes,
    this.height = 240,
  });

  @override
  State<LiveTrackingMapView> createState() => _LiveTrackingMapViewState();
}

class _LiveTrackingMapViewState extends State<LiveTrackingMapView> {
  GoogleMapController? _controller;
  LatLng? _driverPos;
  StreamSubscription<LatLng>? _sub;
  bool _didFitBounds = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialDriverLat != null && widget.initialDriverLng != null) {
      _driverPos = LatLng(widget.initialDriverLat!, widget.initialDriverLng!);
    }
    _sub = widget.driverStream.listen(_onDriverMoved);
  }

  @override
  void dispose() {
    _sub?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  void _onDriverMoved(LatLng pos) {
    if (!mounted) return;
    setState(() => _driverPos = pos);
    if (!_didFitBounds) {
      // First position received — fit both markers in view.
      _fitBounds(pos);
      _didFitBounds = true;
    } else {
      _controller?.animateCamera(CameraUpdate.newLatLng(pos));
    }
  }

  void _fitBounds(LatLng driver) {
    final pickup = LatLng(widget.pickupLat, widget.pickupLng);
    final bounds = LatLngBounds(
      southwest: LatLng(
        min(pickup.latitude, driver.latitude),
        min(pickup.longitude, driver.longitude),
      ),
      northeast: LatLng(
        max(pickup.latitude, driver.latitude),
        max(pickup.longitude, driver.longitude),
      ),
    );
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) _controller?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 64));
    });
  }

  @override
  Widget build(BuildContext context) {
    final pickup = LatLng(widget.pickupLat, widget.pickupLng);
    final driver = _driverPos;

    final markers = <Marker>{
      Marker(
        markerId: const MarkerId('pickup'),
        position: pickup,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
      if (driver != null)
        Marker(
          markerId: const MarkerId('driver'),
          position: driver,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ),
    };

    return SizedBox(
      height: widget.height,
      child: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: driver ?? pickup,
              zoom: driver != null ? 14 : 15,
            ),
            markers: markers,
            zoomControlsEnabled: false,
            myLocationButtonEnabled: false,
            onMapCreated: (ctrl) {
              _controller = ctrl;
              // If we already have both positions (mock mode), fit immediately.
              if (driver != null && !_didFitBounds) {
                _fitBounds(driver);
                _didFitBounds = true;
              }
            },
          ),
          // ETA chip or locating indicator
          PositionedDirectional(
            top: 12,
            start: 12,
            child: driver == null
                ? const _LocatingChip()
                : widget.etaMinutes != null
                    ? _EtaChip(minutes: widget.etaMinutes!)
                    : const SizedBox.shrink(),
          ),
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _StatusBanner(),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _LocatingChip extends StatelessWidget {
  const _LocatingChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              color: AppColors.primaryGreen,
            ),
          ),
          const SizedBox(width: 7),
          Text(
            'جاري تحديد موقع السائق...',
            style: GoogleFonts.cairo(
              color: AppColors.primaryDark,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _EtaChip extends StatelessWidget {
  final int minutes;
  const _EtaChip({required this.minutes});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.schedule_rounded, color: Colors.white, size: 14),
          const SizedBox(width: 5),
          Text(
            'يصل خلال $minutes دقيقة',
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.statusInTransitBg,
        border: Border(
          top: BorderSide(color: AppColors.statusInTransitText, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.statusInTransitText,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'السائق في الطريق إليك',
            style: GoogleFonts.cairo(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.statusInTransitText,
            ),
          ),
          const Spacer(),
          const Icon(
            Icons.local_shipping_rounded,
            color: AppColors.statusInTransitText,
            size: 18,
          ),
        ],
      ),
    );
  }
}
