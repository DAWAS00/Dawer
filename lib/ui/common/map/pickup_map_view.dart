import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dwaar/core/services/map_launcher.dart';
import 'package:dwaar/l10n/l10n.dart';

/// Non-interactive map showing a single pickup-location pin.
/// Tapping the map or the marker opens Google Maps externally.
class PickupMapView extends StatelessWidget {
  final double lat;
  final double lng;
  final double height;

  const PickupMapView({
    super.key,
    required this.lat,
    required this.lng,
    this.height = 240,
  });

  void _openInMaps(BuildContext context) {
    final l10n = context.l10n;
    MapLauncher.openPlace(
      context: context,
      lat: lat,
      lng: lng,
      storeDialogTitle: l10n.mapsNotInstalledTitle,
      storeDialogBody: l10n.mapsNotInstalledBody,
      storeDialogOpenLabel: l10n.openStore,
      storeDialogCancelLabel: l10n.cancel,
    );
  }

  @override
  Widget build(BuildContext context) {
    final position = LatLng(lat, lng);
    return SizedBox(
      height: height,
      child: GoogleMap(
        initialCameraPosition: CameraPosition(target: position, zoom: 15),
        markers: {
          Marker(
            markerId: const MarkerId('pickup'),
            position: position,
            onTap: () => _openInMaps(context),
          ),
        },
        zoomControlsEnabled: false,
        myLocationButtonEnabled: false,
        liteModeEnabled: true,
        onTap: (_) => _openInMaps(context),
      ),
    );
  }
}
