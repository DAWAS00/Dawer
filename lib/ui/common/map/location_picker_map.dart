import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dwaar/core/constants/app_colors.dart';
import 'package:dwaar/ui/common/map/map_constants.dart';

class LocationPickerMap extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;
  final double height;
  final void Function(double lat, double lng) onLocationChanged;

  const LocationPickerMap({
    super.key,
    this.initialLat,
    this.initialLng,
    this.height = 200,
    required this.onLocationChanged,
  });

  @override
  State<LocationPickerMap> createState() => LocationPickerMapState();
}

class LocationPickerMapState extends State<LocationPickerMap> {
  late LatLng _pinPosition;
  late final MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _pinPosition = LatLng(
      widget.initialLat ?? MapConstants.ammanCenter.latitude,
      widget.initialLng ?? MapConstants.ammanCenter.longitude,
    );
  }

  void moveTo(double lat, double lng) {
    setState(() => _pinPosition = LatLng(lat, lng));
    _mapController.move(LatLng(lat, lng), MapConstants.pickupZoom);
    widget.onLocationChanged(lat, lng);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _pinPosition,
            initialZoom: MapConstants.pickupZoom,
            onTap: (tapPosition, point) {
              setState(() => _pinPosition = point);
              widget.onLocationChanged(point.latitude, point.longitude);
            },
          ),
          children: [
            TileLayer(
              urlTemplate: MapConstants.tileUrl,
              userAgentPackageName: 'com.dawer.app',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: _pinPosition,
                  width: 48,
                  height: 48,
                  child: Icon(Icons.location_on_rounded,
                      color: AppColors.mapPickupPin, size: 48),
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Text(
                    '\u0627\u0636\u063a\u0637 \u0639\u0644\u0649 \u0627\u0644\u062e\u0631\u064a\u0637\u0629 \u0644\u062a\u062d\u062f\u064a\u062f \u0627\u0644\u0645\u0648\u0642\u0639',
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const RichAttributionWidget(
              attributions: [
                TextSourceAttribution(MapConstants.tileAttribution),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
