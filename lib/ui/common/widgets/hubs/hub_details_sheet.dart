import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/services/map_launcher.dart';
import '../../../../../core/theme/app_tokens.dart';
import '../../../../../data/models/hub.dart';
import '../../../../../l10n/l10n.dart';
import 'hubs_map_view.dart';

/// Reusable Bottom Sheet displaying detailed logistics, category inventory load,
/// and Google Maps navigation controls for a single Dwaar collection hub.
class HubDetailsBottomSheet extends StatelessWidget {
  const HubDetailsBottomSheet({super.key, required this.hub});
  final Hub hub;

  static void show(BuildContext context, Hub hub) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => HubDetailsBottomSheet(hub: hub),
    );
  }

  void _openInExternalMaps(BuildContext context) {
    final l10n = context.l10n;
    MapLauncher.openPlace(
      context: context,
      lat: hub.lat,
      lng: hub.lng,
      storeDialogTitle: l10n.mapsNotInstalledTitle,
      storeDialogBody: l10n.mapsNotInstalledBody,
      storeDialogOpenLabel: l10n.openStore,
      storeDialogCancelLabel: l10n.cancel,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final dt = context.dt;

    // Calculate total weight stored in the hub's current_load
    double totalWeight = 0;
    hub.currentLoad.forEach((_, val) {
      if (val is num) {
        totalWeight += val.toDouble();
      }
    });

    final double fillPercent = hub.capacityKg > 0
        ? (totalWeight / hub.capacityKg).clamp(0.0, 1.0)
        : 0.0;

    // Evaluate progress bar and status badge colors
    final List<Color> progressGradient = fillPercent >= 0.90
        ? const [Color(0xFFDC2626), Color(0xFFEF4444)] // Danger Red
        : fillPercent >= 0.70
        ? const [Color(0xFFD97706), Color(0xFFF59E0B)] // Warning Amber
        : const [Color(0xFF0A4D2A), Color(0xFF127B45)]; // Safe Green

    final Color statusColor = switch (hub.status) {
      'ready' => AppColors.statusActiveText,
      'collecting' => AppColors.statusInTransitText,
      _ => AppColors.mutedText,
    };

    final Color statusBg = switch (hub.status) {
      'ready' => AppColors.statusActiveBg,
      'collecting' => AppColors.statusInTransitBg,
      _ => dt.surfaceVariant,
    };

    return Container(
      decoration: BoxDecoration(
        color: dt.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: dt.shadow.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: MainLayoutDirection(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: dt.onSurfaceMuted.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),

              // Title and Status Badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hub.name,
                          style: GoogleFonts.cairo(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: dt.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          hub.address,
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            color: dt.onSurfaceMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      hub.status == 'ready'
                          ? l10n.driverStatusReady
                          : hub.status == 'collecting'
                          ? l10n.driverStatusCollecting
                          : hub.status,
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 28),

              // Load Progress Bar Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.hubCapacity,
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: dt.onSurfaceVariant,
                    ),
                  ),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${totalWeight.toInt()} / ${hub.capacityKg.toInt()}',
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: dt.onSurface,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'kg',
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            color: dt.onSurfaceMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Load Progress Bar
              Container(
                height: 12,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: dt.surfaceVariant,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: FractionallySizedBox(
                  alignment: AlignmentDirectional.centerStart,
                  widthFactor: fillPercent,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: progressGradient,
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                      ),
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Material Breakdown Grid Header
              Text(
                l10n.hubBreakdown,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: dt.onSurface,
                ),
              ),
              const SizedBox(height: 12),

              // 2x2 Breakdown Grid
              _buildBreakdownGrid(context, dt),
              const SizedBox(height: 24),

              // Logistics Details (Dates & Schedule)
              _buildLogisticsRow(context, dt, l10n),
              const SizedBox(height: 24),

              // Show on in-app Map Button
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context); // Close details sheet
                  HubsMapView.navigate(context, focusHubId: hub.id);
                },
                icon: const Icon(LucideIcons.map, size: 16),
                label: Text(
                  'عرض على الخريطة التفاعلية',
                  style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryGreen,
                  side: const BorderSide(color: AppColors.primaryGreen),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Open in Google Maps CTA Button
              ElevatedButton.icon(
                onPressed: () => _openInExternalMaps(context),
                icon: const Icon(LucideIcons.mapPin, size: 16),
                label: Text(
                  l10n.openInGoogleMaps,
                  style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBreakdownGrid(BuildContext context, AppTokens dt) {
    final l10n = context.l10n;

    // Setup visual breakdown config mapping json keys to labels, icons and tints
    final config = [
      {
        'key': 'cookingOil',
        'label': l10n.cookingOilLabel,
        'icon': LucideIcons.droplets,
        'fg': const Color(0xFFC2410C),
        'bg': const Color(0xFFFFF7ED),
      },
      {
        'key': 'plastic',
        'label': l10n.plasticLabel,
        'icon': LucideIcons.package,
        'fg': const Color(0xFF047857),
        'bg': const Color(0xFFECFDF5),
      },
      {
        'key': 'paper',
        'label': l10n.paperLabel,
        'icon': LucideIcons.fileText,
        'fg': const Color(0xFF1D4ED8),
        'bg': const Color(0xFFEFF6FF),
      },
      {
        'key': 'electronics',
        'label': l10n.electronicsLabel,
        'icon': LucideIcons.laptop,
        'fg': const Color(0xFF6B21A8),
        'bg': const Color(0xFFFAF5FF),
      },
    ];

    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 2.2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: config.map((c) {
        final double weight =
            (hub.currentLoad[c['key']] as num?)?.toDouble() ?? 0.0;

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: dt.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: dt.border),
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: c['bg'] as Color,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    c['icon'] as IconData,
                    size: 14,
                    color: c['fg'] as Color,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      c['label'] as String,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: dt.onSurfaceVariant,
                      ),
                    ),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${weight.toInt()}',
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: dt.onSurface,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            'kg',
                            style: GoogleFonts.cairo(
                              fontSize: 10,
                              color: dt.onSurfaceMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLogisticsRow(
    BuildContext context,
    AppTokens dt,
    AppLocalizations l10n,
  ) {
    final scheduleLabel = hub.schedule == 'weekly' ? l10n.weekly : l10n.monthly;
    final nextShipment = hub.nextShipmentDate ?? '—';
    final lastShipment = hub.lastShipmentDate ?? '—';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: dt.surfaceVariant,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: dt.border),
      ),
      child: Column(
        children: [
          _logisticsItem(
            dt,
            LucideIcons.calendarClock,
            l10n.reservationDurationLabel,
            scheduleLabel,
          ),
          const SizedBox(height: 10),
          _logisticsItem(
            dt,
            LucideIcons.chevronLeft,
            l10n.nextShipment,
            nextShipment,
          ),
          const SizedBox(height: 10),
          _logisticsItem(
            dt,
            LucideIcons.history,
            l10n.lastShipment,
            lastShipment,
          ),
        ],
      ),
    );
  }

  Widget _logisticsItem(
    AppTokens dt,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(icon, size: 14, color: dt.onSurfaceVariant),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.cairo(fontSize: 12, color: dt.onSurfaceVariant),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.dmSans(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: dt.onSurface,
          ),
        ),
      ],
    );
  }
}

/// Helper layout wrapper that auto-injects base layout direction context based on active locale.
class MainLayoutDirection extends StatelessWidget {
  const MainLayoutDirection({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: child,
    );
  }
}
