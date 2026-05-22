import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/app_tokens.dart';
import '../../../../../l10n/l10n.dart';

class PostMarketStepLocation extends StatelessWidget {
  final double? pickedLat;
  final String locationLabel;
  final TextEditingController notesCtrl;
  final bool submitting;
  final bool attempted;
  final VoidCallback onPickLocation;
  final VoidCallback onSubmit;

  const PostMarketStepLocation({
    super.key,
    required this.pickedLat,
    required this.locationLabel,
    required this.notesCtrl,
    required this.submitting,
    required this.attempted,
    required this.onPickLocation,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final dt = context.dt;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _label(context.l10n.newOrderPickupAddressLabel, dt),
          const SizedBox(height: 8),
          _locationPicker(context, dt),
          const SizedBox(height: 24),
          _label(context.l10n.newOrderNotesLabel, dt),
          const SizedBox(height: 8),
          _notesField(context, dt),
        ],
      ),
    );
  }

  Widget _label(String text, AppTokens dt) => Text(text,
      style: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: dt.onSurfaceVariant));

  Widget _locationPicker(BuildContext context, AppTokens dt) {
    final hasError = attempted && pickedLat == null;
    return GestureDetector(
      onTap: onPickLocation,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: hasError
              ? Colors.red.shade50
              : pickedLat != null
                  ? const Color(0xFF1E40AF).withValues(alpha: 0.06)
                  : dt.surfaceVariant,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hasError
                ? Colors.red.shade400
                : pickedLat != null
                    ? const Color(0xFF1E40AF).withValues(alpha: 0.4)
                    : dt.border,
            width: hasError ? 1.5 : 1,
          ),
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF1E40AF).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(context.l10n.newOrderSelectButton,
                style: GoogleFonts.cairo(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E40AF))),
          ),
          const Spacer(),
          Flexible(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
              Text(locationLabel,
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: pickedLat != null
                          ? const Color(0xFF1E40AF)
                          : dt.onSurface)),
              Text(context.l10n.newOrderTapToSelectLocation,
                  style: GoogleFonts.cairo(
                      fontSize: 11, color: dt.onSurfaceMuted)),
            ]),
          ),
          const SizedBox(width: 12),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF1E40AF).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              pickedLat != null
                  ? Icons.location_on_rounded
                  : Icons.add_location_alt_rounded,
              size: 20,
              color: const Color(0xFF1E40AF),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _notesField(BuildContext context, AppTokens dt) {
    return Container(
      decoration: BoxDecoration(
          color: dt.surfaceVariant,
          borderRadius: BorderRadius.circular(14)),
      child: TextField(
        controller: notesCtrl,
        maxLines: 4,
        textAlign: TextAlign.right,
        style: GoogleFonts.cairo(fontSize: 14, color: dt.onSurface),
        decoration: InputDecoration(
          hintText: context.l10n.newOrderNotesHint,
          hintStyle: GoogleFonts.cairo(
              fontSize: 13,
              color: dt.onSurfaceMuted.withValues(alpha: 0.5)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(14),
        ),
      ),
    );
  }
}
