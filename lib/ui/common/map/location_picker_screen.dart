import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_tokens.dart';
import 'location_picker_panel.dart';

/// Full-screen route that wraps [LocationPickerPanel].
/// Returns `(double lat, double lng)` via [Navigator.pop] when the user
/// taps "تأكيد الموقع", or null if they close without confirming.
class LocationPickerScreen extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;

  const LocationPickerScreen({super.key, this.initialLat, this.initialLng});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  double _lat = 31.9454;
  double _lng = 35.9284;

  @override
  void initState() {
    super.initState();
    if (widget.initialLat != null) _lat = widget.initialLat!;
    if (widget.initialLng != null) _lng = widget.initialLng!;
  }

  @override
  Widget build(BuildContext context) {
    final dt = context.dt;
    return Scaffold(
      backgroundColor: dt.scaffold,
      appBar: AppBar(
        backgroundColor: dt.surface,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'تحديد الموقع',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: dt.onSurface,
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                color: dt.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close_rounded,
                  size: 20, color: dt.onSurfaceMuted),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, (_lat, _lng)),
            child: Text(
              'تأكيد الموقع',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: const Color(0xFF06402B),
              ),
            ),
          ),
        ],
      ),
      body: LocationPickerPanel(
        initialLat: widget.initialLat,
        initialLng: widget.initialLng,
        onLocationChanged: (lat, lng) {
          _lat = lat;
          _lng = lng;
        },
      ),
    );
  }
}
