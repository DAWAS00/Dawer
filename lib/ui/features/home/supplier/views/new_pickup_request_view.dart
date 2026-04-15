import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../../data/models/order.dart';
import '../../../../../core/constants/app_colors.dart';
import 'package:dwaar/ui/common/map/location_picker_map.dart';
import '../viewmodels/individual_supplier_viewmodel.dart';

class NewPickupRequestView extends StatefulWidget {
  final WasteType? preselectedWasteType;

  const NewPickupRequestView({super.key, this.preselectedWasteType});

  @override
  State<NewPickupRequestView> createState() => _NewPickupRequestViewState();
}

class _NewPickupRequestViewState extends State<NewPickupRequestView> {
  final _addressCtrl = TextEditingController();
  final _locationPickerKey = GlobalKey<LocationPickerMapState>();
  bool _locatingGps = false;

  @override
  void dispose() {
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _useGpsLocation() async {
    setState(() => _locatingGps = true);
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '\u064a\u0631\u062c\u0649 \u0627\u0644\u0633\u0645\u0627\u062d \u0628\u0627\u0644\u0648\u0635\u0648\u0644 \u0625\u0644\u0649 \u0645\u0648\u0642\u0639\u0643 \u0645\u0646 \u0625\u0639\u062f\u0627\u062f\u0627\u062a \u0627\u0644\u062c\u0647\u0627\u0632',
                style: GoogleFonts.cairo(),
              ),
              backgroundColor: AppColors.primaryDark,
            ),
          );
        }
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high),
      );
      if (mounted) {
        _locationPickerKey.currentState?.moveTo(pos.latitude, pos.longitude);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '\u062a\u0639\u0630\u0651\u0631 \u0627\u0644\u062d\u0635\u0648\u0644 \u0639\u0644\u0649 \u0645\u0648\u0642\u0639\u0643 \u0627\u0644\u062d\u0627\u0644\u064a',
              style: GoogleFonts.cairo(),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _locatingGps = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.read<IndividualSupplierViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        title: Text(
          '\u0637\u0644\u0628 \u0627\u0633\u062a\u0644\u0627\u0645 \u062c\u062f\u064a\u062f',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Section 1 — waste type chip
          if (widget.preselectedWasteType != null) ...[
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.ctaGradientStart,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                widget.preselectedWasteType!.label,
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Section 2 — pickup location
          Text(
            '\u0645\u0648\u0642\u0639 \u0627\u0644\u0627\u0633\u062a\u0644\u0627\u0645',
            style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF002819)),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _addressCtrl,
            textAlign: TextAlign.right,
            decoration: InputDecoration(
              hintText: '\u0623\u062f\u062e\u0644 \u0639\u0646\u0648\u0627\u0646 \u0627\u0644\u0627\u0633\u062a\u0644\u0627\u0645',
              hintStyle: GoogleFonts.cairo(color: AppColors.mutedText),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              suffixIcon: _locatingGps
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    )
                  : IconButton(
                      icon: const Icon(Icons.my_location_rounded,
                          color: AppColors.primaryGreen),
                      onPressed: _useGpsLocation,
                    ),
            ),
          ),
          const SizedBox(height: 12),
          LocationPickerMap(
            key: _locationPickerKey,
            initialLat: vm.pickupLat,
            initialLng: vm.pickupLng,
            height: 200,
            onLocationChanged: (lat, lng) {
              vm.setPickupLocation(lat, lng);
            },
          ),
          const SizedBox(height: 24),

          // Placeholder for remaining form sections
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(Icons.add_box_rounded,
                    size: 48,
                    color: AppColors.primaryGreen.withValues(alpha: 0.3)),
                const SizedBox(height: 12),
                Text(
                  '\u0628\u0627\u0642\u064a \u0627\u0644\u0646\u0645\u0648\u0630\u062c \u0642\u064a\u062f \u0627\u0644\u062a\u0637\u0648\u064a\u0631',
                  style: GoogleFonts.cairo(
                      fontSize: 14, color: const Color(0xFF717973)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
