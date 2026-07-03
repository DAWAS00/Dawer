import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/theme/app_tokens.dart';
import '../../../../../data/models/hub.dart';
import '../../../../../l10n/l10n.dart';
import '../../../core/components/dwaar_skeleton.dart';
import '../../../features/home/shared/widgets/home/section_header.dart';
import 'hub_details_sheet.dart';
import 'viewmodels/hubs_viewmodel.dart';

/// Reusable horizontal scroll panel displaying all active collection hubs.
/// Clicking a hub displays the detailed inventory load sheet inside a bottom modal.
class HubsSection extends StatelessWidget {
  const HubsSection({super.key, this.onHubFocused});

  /// Callback triggered when a hub is selected (e.g. to animate map camera)
  final ValueChanged<Hub>? onHubFocused;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final dt = context.dt;
    final vm = context.watch<HubsViewModel>();

    if (vm.error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: _HubsErrorBanner(message: vm.error!),
      );
    }

    if (!vm.isLoading && vm.hubs.isEmpty) {
      return const SizedBox.shrink();
    }

    return MainLayoutDirection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HomeSectionHeader(
            title: l10n.driverDeliveryHubs,
            count: vm.isLoading ? 0 : vm.hubs.length,
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 90,
            child: DwaarSkeleton(
              enabled: vm.isLoading,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: vm.isLoading ? 3 : vm.hubs.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (ctx, i) {
                  if (vm.isLoading) {
                    return _buildSkeletonChip(dt);
                  }

                  final hub = vm.hubs[i];
                  return _HubChip(
                    hub: hub,
                    onTap: () {
                      onHubFocused?.call(hub);
                      vm.selectHub(hub);
                      HubDetailsBottomSheet.show(context, hub);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonChip(AppTokens dt) {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: dt.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: dt.border),
      ),
    );
  }
}

class _HubChip extends StatelessWidget {
  const _HubChip({required this.hub, required this.onTap});
  final Hub hub;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final dt = context.dt;

    final statusColor = switch (hub.status) {
      'ready' => AppColors.statusActiveText,
      'collecting' => AppColors.statusInTransitText,
      _ => AppColors.mutedText,
    };

    final statusBg = switch (hub.status) {
      'ready' => AppColors.statusActiveBg,
      'collecting' => AppColors.statusInTransitBg,
      _ => dt.surfaceVariant,
    };

    return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 160,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: dt.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: dt.border),
              boxShadow: [
                BoxShadow(
                  color: dt.shadow.withValues(alpha: 0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      LucideIcons.warehouse,
                      size: 13,
                      color: AppColors.primaryGreen,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        hub.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: dt.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  hub.address,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(
                    fontSize: 10,
                    color: dt.onSurfaceMuted,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    hub.status == 'ready'
                        ? l10n.driverStatusReady
                        : hub.status == 'collecting'
                        ? l10n.driverStatusCollecting
                        : hub.status,
                    style: GoogleFonts.cairo(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 200.ms)
        .scale(begin: const Offset(0.98, 0.98), end: const Offset(1.0, 1.0));
  }
}

class _HubsErrorBanner extends StatelessWidget {
  const _HubsErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.statusCancelledBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.statusCancelledText.withAlpha(60)),
      ),
      child: Row(
        children: [
          const Icon(
            LucideIcons.triangleAlert,
            size: 16,
            color: AppColors.statusCancelledText,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              context.l10n.driverHubsUnavailable,
              style: GoogleFonts.cairo(
                fontSize: 12,
                color: AppColors.statusCancelledText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
