import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dwaar/core/constants/app_colors.dart';
import 'package:dwaar/core/services/map_launcher.dart';
import 'package:dwaar/l10n/l10n.dart';

/// Stateful location picker that replaces the former FlutterMap/Mapbox
/// [LocationPickerMap]. Instead of letting the user drag a pin on an in-app
/// map, the user picks a location via two routes:
///   1. GPS — tap "Use my current location" to call [Geolocator].
///   2. Google Maps hand-off — tap "Pick on Google Maps" to open the external
///      app, then paste the coordinates back via a bottom sheet.
class LocationPickerPanel extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;
  final void Function(double lat, double lng) onLocationChanged;

  const LocationPickerPanel({
    super.key,
    this.initialLat,
    this.initialLng,
    required this.onLocationChanged,
  });

  @override
  State<LocationPickerPanel> createState() => _LocationPickerPanelState();
}

class _LocationPickerPanelState extends State<LocationPickerPanel> {
  double? _lat;
  double? _lng;
  bool _loadingGps = false;

  @override
  void initState() {
    super.initState();
    _lat = widget.initialLat;
    _lng = widget.initialLng;
  }

  // ── GPS flow ───────────────────────────────────────────────────────────────

  Future<void> _useCurrentLocation() async {
    if (_loadingGps) return;
    // Cache localized strings now so we don't reach for `context` after awaits.
    final l10n = context.l10n;
    final unavailableMsg = l10n.gpsUnavailable;
    final deniedMsg = l10n.gpsPermissionDenied;
    setState(() => _loadingGps = true);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        _showSnack(unavailableMsg);
        return;
      }
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        _showSnack(deniedMsg);
        return;
      }
      final pos = await Geolocator.getCurrentPosition();
      _applyCoords(pos.latitude, pos.longitude);
    } catch (_) {
      if (!mounted) return;
      _showSnack(unavailableMsg);
    } finally {
      if (mounted) setState(() => _loadingGps = false);
    }
  }

  // ── Google Maps deep-link flow ─────────────────────────────────────────────

  Future<void> _pickOnGoogleMaps() async {
    final l10n = context.l10n;
    // If the user already has coordinates, centre Google Maps there; otherwise
    // open the landing page so they can search.
    if (_lat != null && _lng != null) {
      await MapLauncher.openPlace(
        context: context,
        lat: _lat!,
        lng: _lng!,
        storeDialogTitle: l10n.mapsNotInstalledTitle,
        storeDialogBody: l10n.mapsNotInstalledBody,
        storeDialogOpenLabel: l10n.openStore,
        storeDialogCancelLabel: l10n.cancel,
      );
    } else {
      await MapLauncher.openMapsForPicking(
        context: context,
        storeDialogTitle: l10n.mapsNotInstalledTitle,
        storeDialogBody: l10n.mapsNotInstalledBody,
        storeDialogOpenLabel: l10n.openStore,
        storeDialogCancelLabel: l10n.cancel,
      );
    }
    if (!mounted) return;
    final entered = await _showPasteCoordinatesSheet();
    if (entered != null) _applyCoords(entered.$1, entered.$2);
  }

  Future<(double, double)?> _showPasteCoordinatesSheet() async {
    return await showModalBottomSheet<(double, double)?>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetCtx).viewInsets.bottom,
        ),
        child: _PasteCoordinatesForm(
          initialLat: _lat,
          initialLng: _lng,
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  void _applyCoords(double lat, double lng) {
    setState(() {
      _lat = lat;
      _lng = lng;
    });
    widget.onLocationChanged(lat, lng);
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            _IconHeader(),
            const SizedBox(height: 16),
            _CoordinatesBadge(lat: _lat, lng: _lng, emptyLabel: l10n.locationNotSet),
            const SizedBox(height: 24),
            _PrimaryActionButton(
              icon: Icons.my_location_rounded,
              label: l10n.useCurrentLocation,
              loading: _loadingGps,
              onPressed: _useCurrentLocation,
            ),
            const SizedBox(height: 12),
            _SecondaryActionButton(
              icon: Icons.map_rounded,
              label: l10n.pickOnGoogleMaps,
              onPressed: _pickOnGoogleMaps,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Subcomponents ────────────────────────────────────────────────────────────

class _IconHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(
            color: AppColors.mapSurface,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.location_on_rounded,
            size: 32,
            color: AppColors.primaryDark,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          context.l10n.pickLocationTitle,
          style: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryDark,
          ),
        ),
      ],
    );
  }
}

class _CoordinatesBadge extends StatelessWidget {
  final double? lat;
  final double? lng;
  final String emptyLabel;

  const _CoordinatesBadge({
    required this.lat,
    required this.lng,
    required this.emptyLabel,
  });

  @override
  Widget build(BuildContext context) {
    final hasCoords = lat != null && lng != null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryGreen.withValues(alpha: 0.15),
        ),
      ),
      child: hasCoords
          ? _CoordinatesLine(lat: lat!, lng: lng!)
          : Text(
              emptyLabel,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 13,
                color: AppColors.mutedText,
                fontWeight: FontWeight.w500,
              ),
            ),
    );
  }
}

class _CoordinatesLine extends StatelessWidget {
  final double lat;
  final double lng;

  const _CoordinatesLine({required this.lat, required this.lng});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _CoordCell(label: l10n.latitude, value: lat.toStringAsFixed(5)),
        Container(width: 1, height: 24, color: AppColors.primaryGreen.withValues(alpha: 0.15)),
        _CoordCell(label: l10n.longitude, value: lng.toStringAsFixed(5)),
      ],
    );
  }
}

class _CoordCell extends StatelessWidget {
  final String label;
  final String value;

  const _CoordCell({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 11,
            color: AppColors.mutedText,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.dmSans(
            fontSize: 14,
            color: AppColors.primaryDark,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool loading;
  final VoidCallback onPressed;

  const _PrimaryActionButton({
    required this.icon,
    required this.label,
    required this.loading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: loading ? null : onPressed,
      icon: loading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Icon(icon),
      label: Text(
        label,
        style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w700),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
    );
  }
}

class _SecondaryActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _SecondaryActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(
        label,
        style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w700),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryDark,
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: BorderSide(
          color: AppColors.primaryGreen.withValues(alpha: 0.3),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// ── Paste-coordinates bottom sheet ───────────────────────────────────────────

class _PasteCoordinatesForm extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;

  const _PasteCoordinatesForm({this.initialLat, this.initialLng});

  @override
  State<_PasteCoordinatesForm> createState() => _PasteCoordinatesFormState();
}

class _PasteCoordinatesFormState extends State<_PasteCoordinatesForm> {
  late final TextEditingController _latCtrl;
  late final TextEditingController _lngCtrl;
  late final TextEditingController _pasteCtrl;
  String? _error;

  @override
  void initState() {
    super.initState();
    _latCtrl = TextEditingController(
      text: widget.initialLat?.toStringAsFixed(6) ?? '',
    );
    _lngCtrl = TextEditingController(
      text: widget.initialLng?.toStringAsFixed(6) ?? '',
    );
    _pasteCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _latCtrl.dispose();
    _lngCtrl.dispose();
    _pasteCtrl.dispose();
    super.dispose();
  }

  /// Accepts "31.9539, 35.9106" or "31.9539,35.9106" or with any whitespace.
  (double, double)? _parsePair(String raw) {
    final cleaned = raw.trim().replaceAll(RegExp(r'\s+'), '');
    final parts = cleaned.split(',');
    if (parts.length != 2) return null;
    final lat = double.tryParse(parts[0]);
    final lng = double.tryParse(parts[1]);
    if (lat == null || lng == null) return null;
    if (lat < -90 || lat > 90 || lng < -180 || lng > 180) return null;
    return (lat, lng);
  }

  void _onPasteChanged(String value) {
    final parsed = _parsePair(value);
    if (parsed != null) {
      _latCtrl.text = parsed.$1.toStringAsFixed(6);
      _lngCtrl.text = parsed.$2.toStringAsFixed(6);
      setState(() => _error = null);
    }
  }

  void _onSave() {
    final lat = double.tryParse(_latCtrl.text.trim());
    final lng = double.tryParse(_lngCtrl.text.trim());
    if (lat == null ||
        lng == null ||
        lat < -90 ||
        lat > 90 ||
        lng < -180 ||
        lng > 180) {
      setState(() => _error = context.l10n.invalidCoordinates);
      return;
    }
    Navigator.pop(context, (lat, lng));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.mutedText.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.pasteCoordinates,
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _pasteCtrl,
            onChanged: _onPasteChanged,
            keyboardType: const TextInputType.numberWithOptions(
              signed: true,
              decimal: true,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,\-\s]')),
            ],
            decoration: InputDecoration(
              hintText: l10n.pasteCoordinatesHint,
              prefixIcon: const Icon(Icons.content_paste_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _CoordField(
                  controller: _latCtrl,
                  label: l10n.latitude,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _CoordField(
                  controller: _lngCtrl,
                  label: l10n.longitude,
                ),
              ),
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              style: GoogleFonts.cairo(
                fontSize: 12,
                color: AppColors.statusCancelledText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.cancel),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _onSave,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                  ),
                  child: Text(l10n.save),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CoordField extends StatelessWidget {
  final TextEditingController controller;
  final String label;

  const _CoordField({required this.controller, required this.label});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(
        signed: true,
        decimal: true,
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.\-]')),
      ],
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
