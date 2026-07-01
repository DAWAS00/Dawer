import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:dwaar/core/constants/app_colors.dart';
import 'package:dwaar/core/services/map_launcher.dart';
import 'package:dwaar/l10n/l10n.dart';

/// Real Google Map route preview: pickup + drop-off markers with a geodesic
/// route line, camera fitted to both points. Non-interactive inside scroll
/// views — tapping anywhere (or the FAB) opens Google Maps driving directions.
class RouteMapView extends StatefulWidget {
  final double pickupLat;
  final double pickupLng;
  final double dropoffLat;
  final double dropoffLng;
  final double height;

  const RouteMapView({
    super.key,
    required this.pickupLat,
    required this.pickupLng,
    required this.dropoffLat,
    required this.dropoffLng,
    this.height = 240,
  });

  @override
  State<RouteMapView> createState() => _RouteMapViewState();
}

class _RouteMapViewState extends State<RouteMapView> {
  LatLng get _pickup => LatLng(widget.pickupLat, widget.pickupLng);
  LatLng get _dropoff => LatLng(widget.dropoffLat, widget.dropoffLng);

  LatLngBounds get _bounds => LatLngBounds(
        southwest: LatLng(
          widget.pickupLat < widget.dropoffLat ? widget.pickupLat : widget.dropoffLat,
          widget.pickupLng < widget.dropoffLng ? widget.pickupLng : widget.dropoffLng,
        ),
        northeast: LatLng(
          widget.pickupLat > widget.dropoffLat ? widget.pickupLat : widget.dropoffLat,
          widget.pickupLng > widget.dropoffLng ? widget.pickupLng : widget.dropoffLng,
        ),
      );

  void _openDirections(BuildContext context) {
    final l10n = context.l10n;
    MapLauncher.openDirections(
      context: context,
      originLat: widget.pickupLat,
      originLng: widget.pickupLng,
      destLat: widget.dropoffLat,
      destLng: widget.dropoffLng,
      storeDialogTitle: l10n.mapsNotInstalledTitle,
      storeDialogBody: l10n.mapsNotInstalledBody,
      storeDialogOpenLabel: l10n.openStore,
      storeDialogCancelLabel: l10n.cancel,
    );
  }

  @override
  Widget build(BuildContext context) {
    final midpoint = LatLng(
      (widget.pickupLat + widget.dropoffLat) / 2,
      (widget.pickupLng + widget.dropoffLng) / 2,
    );

    return SizedBox(
      height: widget.height,
      child: Stack(
        children: [
          Positioned.fill(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(target: midpoint, zoom: 12),
              onMapCreated: (controller) {
                // Fit both endpoints once tiles are ready.
                Future.delayed(const Duration(milliseconds: 300), () {
                  controller.animateCamera(
                    CameraUpdate.newLatLngBounds(_bounds, 56),
                  );
                });
              },
              markers: {
                Marker(
                  markerId: const MarkerId('pickup'),
                  position: _pickup,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueGreen),
                  onTap: () => _openDirections(context),
                ),
                Marker(
                  markerId: const MarkerId('dropoff'),
                  position: _dropoff,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueRed),
                  onTap: () => _openDirections(context),
                ),
              },
              polylines: {
                Polyline(
                  polylineId: const PolylineId('route'),
                  points: [_pickup, _dropoff],
                  geodesic: true,
                  color: AppColors.primaryGreen,
                  width: 4,
                  patterns: [PatternItem.dash(24), PatternItem.gap(12)],
                ),
              },
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
              mapToolbarEnabled: false,
              compassEnabled: false,
              // Static preview: no gestures so it doesn't fight the page scroll.
              scrollGesturesEnabled: false,
              zoomGesturesEnabled: false,
              rotateGesturesEnabled: false,
              tiltGesturesEnabled: false,
              onTap: (_) => _openDirections(context),
            ),
          ),
          PositionedDirectional(
            end: 12,
            bottom: 12,
            child: FloatingActionButton.extended(
              heroTag:
                  'route-map-fab-${widget.pickupLat}-${widget.dropoffLat}',
              onPressed: () => _openDirections(context),
              icon: const Icon(Icons.directions_rounded, size: 20),
              label: Text(
                context.l10n.openInGoogleMaps,
                style: GoogleFonts.cairo(
                    fontSize: 12, fontWeight: FontWeight.w700),
              ),
              backgroundColor: AppColors.primaryDark,
              foregroundColor: Colors.white,
              elevation: 3,
            ),
          ),
        ],
      ),
    );
  }
}
