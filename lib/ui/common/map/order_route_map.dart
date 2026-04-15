import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:dwaar/core/constants/app_colors.dart';
import 'package:dwaar/ui/common/map/map_constants.dart';

class OrderRouteMap extends StatefulWidget {
  final double pickupLat;
  final double pickupLng;
  final double dropoffLat;
  final double dropoffLng;
  final double? driverLat;
  final double? driverLng;
  final double height;
  final bool interactive;
  final bool showLabels;

  const OrderRouteMap({
    super.key,
    required this.pickupLat,
    required this.pickupLng,
    required this.dropoffLat,
    required this.dropoffLng,
    this.driverLat,
    this.driverLng,
    this.height = 240,
    this.interactive = true,
    this.showLabels = true,
  });

  @override
  State<OrderRouteMap> createState() => _OrderRouteMapState();
}

class _OrderRouteMapState extends State<OrderRouteMap> {
  List<LatLng>? _roadRoute;
  bool _loadingRoute = true;
  late final MapController _mapController;

  LatLng get _pickup => LatLng(widget.pickupLat, widget.pickupLng);
  LatLng get _dropoff => LatLng(widget.dropoffLat, widget.dropoffLng);

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: LatLngBounds(_pickup, _dropoff),
          padding: const EdgeInsets.all(60),
        ),
      );
      _fetchRoute();
    });
  }

  Future<void> _fetchRoute() async {
    try {
      final url = MapConstants.directionsUrl(
          widget.pickupLat, widget.pickupLng, widget.dropoffLat, widget.dropoffLng);
      final res =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final routes = data['routes'] as List?;
        if (routes != null && routes.isNotEmpty) {
          final coords =
              (routes[0]['geometry']['coordinates'] as List)
                  .map((c) => LatLng(
                      (c[1] as num).toDouble(), (c[0] as num).toDouble()))
                  .toList();
          if (mounted) {
            setState(() {
              _roadRoute = coords;
              _loadingRoute = false;
            });
          }
          return;
        }
      }
      if (mounted) {
        setState(() {
          _roadRoute = [];
          _loadingRoute = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _roadRoute = [];
          _loadingRoute = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final midLat = (widget.pickupLat + widget.dropoffLat) / 2;
    final midLng = (widget.pickupLng + widget.dropoffLng) / 2;

    return SizedBox(
      height: widget.height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(0),
        child: GestureDetector(
          onTap: widget.interactive
              ? null
              : () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => _FullScreenRouteMap(
                        pickupLat: widget.pickupLat,
                        pickupLng: widget.pickupLng,
                        dropoffLat: widget.dropoffLat,
                        dropoffLng: widget.dropoffLng,
                        driverLat: widget.driverLat,
                        driverLng: widget.driverLng,
                      ),
                    ),
                  ),
          child: AbsorbPointer(
            absorbing: !widget.interactive,
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: LatLng(midLat, midLng),
                initialZoom: MapConstants.routeZoom,
                interactionOptions: InteractionOptions(
                  flags: widget.interactive
                      ? InteractiveFlag.all
                      : InteractiveFlag.none,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: MapConstants.tileUrl,
                  userAgentPackageName: 'com.dawer.app',
                ),
                PolylineLayer(polylines: [_buildPolyline()]),
                MarkerLayer(markers: _buildMarkers()),
                const RichAttributionWidget(
                  attributions: [
                    TextSourceAttribution(MapConstants.tileAttribution),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Polyline _buildPolyline() {
    if (_loadingRoute || _roadRoute == null || _roadRoute!.isEmpty) {
      return Polyline(
        points: [_pickup, _dropoff],
        strokeWidth: 3,
        color: AppColors.mapRouteLine,
        pattern: const StrokePattern.dotted(),
      );
    }
    return Polyline(
      points: _roadRoute!,
      strokeWidth: 4,
      color: AppColors.mapRouteLine,
    );
  }

  List<Marker> _buildMarkers() {
    final markers = <Marker>[
      // Pickup marker
      Marker(
        point: _pickup,
        width: widget.showLabels ? 64 : 36,
        height: widget.showLabels ? 64 : 36,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.mapPickupPin,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.mapPickupPin.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(Icons.radio_button_checked,
                  color: Colors.white, size: 16),
            ),
            if (widget.showLabels) ...[
              const SizedBox(height: 2),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '\u0627\u0644\u0627\u0633\u062a\u0644\u0627\u0645',
                  style: GoogleFonts.cairo(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      // Dropoff marker
      Marker(
        point: _dropoff,
        width: widget.showLabels ? 64 : 36,
        height: widget.showLabels ? 64 : 36,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.mapDropoffPin,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.mapDropoffPin.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(Icons.location_on_rounded,
                  color: Colors.white, size: 16),
            ),
            if (widget.showLabels) ...[
              const SizedBox(height: 2),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '\u0627\u0644\u062a\u0633\u0644\u064a\u0645',
                  style: GoogleFonts.cairo(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AppColors.mapDropoffPin,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    ];

    // Driver marker
    if (widget.driverLat != null && widget.driverLng != null) {
      markers.add(
        Marker(
          point: LatLng(widget.driverLat!, widget.driverLng!),
          width: 44,
          height: 44,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryDark,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryDark.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.local_shipping_rounded,
                color: Colors.white, size: 20),
          ),
        ),
      );
    }

    return markers;
  }
}

// -- Full-screen route map shown on tap -----------------------------------------

class _FullScreenRouteMap extends StatelessWidget {
  final double pickupLat;
  final double pickupLng;
  final double dropoffLat;
  final double dropoffLng;
  final double? driverLat;
  final double? driverLng;

  const _FullScreenRouteMap({
    required this.pickupLat,
    required this.pickupLng,
    required this.dropoffLat,
    required this.dropoffLng,
    this.driverLat,
    this.driverLng,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('\u062e\u0637 \u0627\u0644\u0633\u064a\u0631',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
      ),
      body: OrderRouteMap(
        pickupLat: pickupLat,
        pickupLng: pickupLng,
        dropoffLat: dropoffLat,
        dropoffLng: dropoffLng,
        driverLat: driverLat,
        driverLng: driverLng,
        height: MediaQuery.of(context).size.height,
        interactive: true,
      ),
    );
  }
}
