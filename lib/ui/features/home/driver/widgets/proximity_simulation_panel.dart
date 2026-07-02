import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../../core/constants/app_colors.dart';
import '../viewmodels/rider_proximity_viewmodel.dart';

// ── ProximitySimulationPanel ──────────────────────────────────────────────────
//
// Dev/QA-only panel that lets testers manually trigger proximity states
// without needing to physically move. Remove from production builds with a
// `kDebugMode` guard or a feature flag.
//
// Usage: Add this widget below the active-order card in DriverHomeTab.

class ProximitySimulationPanel extends StatelessWidget {
  const ProximitySimulationPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.read<RiderProximityViewModel>();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            textDirection: TextDirection.rtl,
            children: [
              const Icon(Icons.bug_report_rounded, size: 14, color: Colors.white54),
              const SizedBox(width: 6),
              Text(
                'محاكاة الموقع — للاختبار فقط',
                style: GoogleFonts.dmSans(fontSize: 11, color: Colors.white54),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.end,
            children: [
              _SimButton(
                label: 'قريب من الاستلام',
                color: AppColors.accentAmber,
                onTap: vm.simulateAtPickup,
              ),
              _SimButton(
                label: 'قريب من الزبون',
                color: AppColors.statusActiveText,
                onTap: vm.simulateAtDropoff,
              ),
              _SimButton(
                label: 'بعيد',
                color: Colors.white38,
                onTap: vm.simulateFarAway,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SimButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _SimButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: 0.6)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ),
    );
  }
}
