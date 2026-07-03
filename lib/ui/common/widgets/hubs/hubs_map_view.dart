import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/theme/app_tokens.dart';
import '../../../../../data/models/hub.dart';
import '../../../../../l10n/l10n.dart';
import 'hub_details_sheet.dart';
import 'utils/map_pin_generator.dart';
import 'viewmodels/hubs_viewmodel.dart';

/// Reusable full-screen Map View showing all active collection hubs on a Google Map
/// with dynamic, canvas-drawn occupancy markers and bottom sheet details triggers.
class HubsMapView extends StatefulWidget {
  const HubsMapView({super.key, this.initialFocusHubId});
  final String? initialFocusHubId;

  static void navigate(BuildContext context, {String? focusHubId}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => HubsMapView(initialFocusHubId: focusHubId),
      ),
    );
  }

  @override
  State<HubsMapView> createState() => _HubsMapViewState();
}

class _HubsMapViewState extends State<HubsMapView> {
  GoogleMapController? _mapController;
  final Map<MarkerId, Marker> _markers = {};
  List<Hub>? _lastHubs;

  bool _areHubsEqual(List<Hub> a, List<Hub> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id || a[i].status != b[i].status) {
        return false;
      }
    }
    return true;
  }

  Future<void> _loadCustomMarkers(List<Hub> hubs) async {
    final double density = MediaQuery.of(context).devicePixelRatio;
    final Map<MarkerId, Marker> newMarkers = {};

    for (final hub in hubs) {
      double totalWeight = 0;
      hub.currentLoad.forEach((_, val) {
        if (val is num) {
          totalWeight += val.toDouble();
        }
      });
      final double fillPercent = hub.capacityKg > 0
          ? (totalWeight / hub.capacityKg).clamp(0.0, 1.0)
          : 0.0;

      final markerId = MarkerId(hub.id);
      final icon = await MapPinGenerator.generateHubMarker(
        fillPercent: fillPercent,
        status: hub.status,
        densityScale: density,
      );

      newMarkers[markerId] = Marker(
        markerId: markerId,
        position: LatLng(hub.lat, hub.lng),
        icon: icon,
        onTap: () {
          _centerCamera(LatLng(hub.lat, hub.lng));
          HubDetailsBottomSheet.show(context, hub);
        },
      );
    }

    if (mounted) {
      setState(() {
        _markers.clear();
        _markers.addAll(newMarkers);
      });
    }

    // Center camera on initially focused hub
    if (widget.initialFocusHubId != null) {
      final focusHub = hubs
          .where((h) => h.id == widget.initialFocusHubId)
          .firstOrNull;
      if (focusHub != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _centerCamera(LatLng(focusHub.lat, focusHub.lng));
        });
      }
    }
  }

  void _centerCamera(LatLng position) {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: position, zoom: 14.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final dt = context.dt;
    final hubs = context.watch<HubsViewModel>().hubs;

    if (_lastHubs == null || !_areHubsEqual(_lastHubs!, hubs)) {
      _lastHubs = hubs;
      _loadCustomMarkers(hubs);
    }

    LatLng initialPosition = const LatLng(31.9554, 35.9454); // Amman baseline
    if (widget.initialFocusHubId != null && hubs.isNotEmpty) {
      final match = hubs
          .where((h) => h.id == widget.initialFocusHubId)
          .firstOrNull;
      if (match != null) {
        initialPosition = LatLng(match.lat, match.lng);
      }
    }

    return Scaffold(
      backgroundColor: dt.scaffold,
      appBar: AppBar(
        title: Text(
          l10n.aboutDwaarHubsTitle,
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: initialPosition,
              zoom: 12,
            ),
            markers: _markers.values.toSet(),
            onMapCreated: (controller) {
              _mapController = controller;
            },
            zoomControlsEnabled: false,
            myLocationButtonEnabled: false,
          ),

          // Legend or Header Overlay Card
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: MainLayoutDirection(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: dt.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: dt.shadow.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _legendItem(const Color(0xFF0F5A34), 'جارِ الجمع'),
                    _legendItem(const Color(0xFFD97706), 'ممتلئ جزئياً'),
                    _legendItem(const Color(0xFFEF4444), 'ممتلئ جداً'),
                    _legendItem(const Color(0xFF06331C), 'جاهز للشحن'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.cairo(fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
