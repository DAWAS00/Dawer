import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/waste_type_icons.dart';
import '../../../../../data/models/order/order.dart';
import '../../../../../data/models/order_labels.dart';

class OrderContentsSection extends StatelessWidget {
  const OrderContentsSection({super.key, required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final hasExtra = order.weightKg != null ||
        order.weightCategory != null ||
        order.wasteForm != null;
    final hasNotes =
        order.supplierNotes != null && order.supplierNotes!.isNotEmpty;

    if (order.wasteTypes.isEmpty && !hasExtra && !hasNotes) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // ── Title ──
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'محتوى الطلب',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF002819),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(LucideIcons.package, size: 14, color: AppColors.primaryGreen),
                ),
              ],
            ),

            // ── Waste type chips ──
            if (order.wasteTypes.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.end,
                children: order.wasteTypes
                    .map((t) => _WasteChip(type: t, locale: locale))
                    .toList(),
              ),
            ],

            // ── Weight / form meta ──
            if (hasExtra) ...[
              const SizedBox(height: 12),
              const Divider(height: 1, color: Color(0xFFEEF2EE)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                alignment: WrapAlignment.end,
                children: [
                  if (order.weightKg != null)
                    _MetaBadge(
                      icon: Icons.scale_rounded,
                      label: '${order.weightKg!.toStringAsFixed(0)} كغ',
                    ),
                  if (order.weightCategory != null)
                    _MetaBadge(
                      icon: Icons.bar_chart_rounded,
                      label: order.weightCategory!.shortLabelFor(locale),
                    ),
                  if (order.wasteForm != null)
                    _MetaBadge(
                      icon: Icons.water_drop_outlined,
                      label: order.wasteForm!.labelFor(locale),
                    ),
                ],
              ),
            ],

            // ── Notes ──
            if (hasNotes) ...[
              const SizedBox(height: 12),
              const Divider(height: 1, color: Color(0xFFEEF2EE)),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      order.supplierNotes!,
                      textAlign: TextAlign.end,
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        color: const Color(0xFF404943),
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(LucideIcons.fileText, size: 15, color: AppColors.mutedText),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _WasteChip extends StatelessWidget {
  const _WasteChip({required this.type, required this.locale});
  final WasteType type;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            WasteTypeIcons.iconFor(type),
            size: 14,
            color: AppColors.primaryGreen,
          ),
          const SizedBox(width: 5),
          Text(
            type.labelFor(locale),
            style: GoogleFonts.cairo(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaBadge extends StatelessWidget {
  const _MetaBadge({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.mutedText),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF404943),
            ),
          ),
        ],
      ),
    );
  }
}
