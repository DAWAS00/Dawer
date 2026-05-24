import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dwaar/core/constants/app_colors.dart';
import 'package:dwaar/core/services/map_launcher.dart';
import 'package:dwaar/l10n/l10n.dart';

/// Non-interactive route preview — replaces the former FlutterMap/Mapbox
/// [OrderRouteMap]. Renders a stylized card with pickup → drop-off labels and
/// an "Open in Google Maps" FAB that deep-links to Google Maps driving
/// directions.
class RouteMapPlaceholder extends StatelessWidget {
  final double pickupLat;
  final double pickupLng;
  final double dropoffLat;
  final double dropoffLng;
  final double height;

  /// Optional human-readable labels shown next to the pickup/drop-off pins.
  /// When null, uses the localized defaults ([AppLocalizations.mapLabelPickup]
  /// / [AppLocalizations.mapLabelDropoff]).
  final String? pickupLabel;
  final String? dropoffLabel;

  /// When false, hides the labels column and renders only the CTA (compact
  /// mode used in driver cards where vertical space is tight).
  final bool showLabels;

  const RouteMapPlaceholder({
    super.key,
    required this.pickupLat,
    required this.pickupLng,
    required this.dropoffLat,
    required this.dropoffLng,
    this.height = 240,
    this.pickupLabel,
    this.dropoffLabel,
    this.showLabels = true,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SizedBox(
      height: height,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.mapSurface, Color(0xFFF4F6F5)],
          ),
        ),
        child: Stack(
          children: [
            _MapGridOverlay(),
            if (showLabels)
              Positioned.fill(child: _LabelsColumn(
                pickupLabel: pickupLabel ?? l10n.mapLabelPickup,
                dropoffLabel: dropoffLabel ?? l10n.mapLabelDropoff,
              )),
            PositionedDirectional(
              end: 12,
              bottom: 12,
              child: _OpenInMapsButton(
                heroTag: 'route-map-fab-$pickupLat-$dropoffLat',
                onPressed: () => MapLauncher.openDirections(
                  context: context,
                  originLat: pickupLat,
                  originLng: pickupLng,
                  destLat: dropoffLat,
                  destLng: dropoffLng,
                  storeDialogTitle: l10n.mapsNotInstalledTitle,
                  storeDialogBody: l10n.mapsNotInstalledBody,
                  storeDialogOpenLabel: l10n.openStore,
                  storeDialogCancelLabel: l10n.cancel,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Internal building blocks ─────────────────────────────────────────────────

class _MapGridOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Opacity(
        opacity: 0.25,
        child: CustomPaint(painter: _GridPainter()),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryGreen.withValues(alpha: 0.35)
      ..strokeWidth = 0.8;
    const step = 28.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) => false;
}

class _LabelsColumn extends StatelessWidget {
  final String pickupLabel;
  final String dropoffLabel;

  const _LabelsColumn({
    required this.pickupLabel,
    required this.dropoffLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 72),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RouteEndpointRow(
            icon: Icons.radio_button_checked,
            color: AppColors.mapPickupPin,
            label: pickupLabel,
          ),
          const SizedBox(height: 4),
          const _DottedConnector(),
          const SizedBox(height: 4),
          _RouteEndpointRow(
            icon: Icons.location_on_rounded,
            color: AppColors.mapDropoffPin,
            label: dropoffLabel,
          ),
        ],
      ),
    );
  }
}

class _RouteEndpointRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const _RouteEndpointRow({
    required this.icon,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _DottedConnector extends StatelessWidget {
  const _DottedConnector();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 15),
      child: SizedBox(
        height: 24,
        width: 2,
        child: CustomPaint(painter: _DotsPainter()),
      ),
    );
  }
}

class _DotsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.mapRouteLine
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    const dotSpacing = 6.0;
    for (double y = 0; y < size.height; y += dotSpacing) {
      canvas.drawLine(Offset(0, y), Offset(0, y + 2), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DotsPainter oldDelegate) => false;
}

class _OpenInMapsButton extends StatelessWidget {
  final String heroTag;
  final VoidCallback onPressed;

  const _OpenInMapsButton({required this.heroTag, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      heroTag: heroTag,
      onPressed: onPressed,
      icon: const Icon(Icons.directions_rounded, size: 20),
      label: Text(
        context.l10n.openInGoogleMaps,
        style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w700),
      ),
      backgroundColor: AppColors.primaryDark,
      foregroundColor: Colors.white,
      elevation: 3,
    );
  }
}
