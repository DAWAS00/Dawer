import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/waste_type_icons.dart';
import '../../../../../core/theme/app_tokens.dart';
import '../../../../../data/models/order/order.dart';
import '../../../../../data/models/order_labels.dart';
import '../../../../../l10n/l10n.dart';

class MarketItemCard extends StatelessWidget {
  final Order item;
  final VoidCallback onTap;

  const MarketItemCard({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context);
    final dt = context.dt;

    final timeDiff = DateTime.now().difference(item.createdAt);
    final timeLabel = timeDiff.inDays > 0
        ? l10n.timeAgoDays(timeDiff.inDays)
        : timeDiff.inHours > 0
        ? l10n.timeAgoHours(timeDiff.inHours)
        : l10n.timeAgoMinutes(timeDiff.inMinutes);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: dt.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Top: seller + time ──
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
              child: Row(
                children: [
                  // Seller avatar circle
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.store_outlined,
                      size: 18,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.supplierName ?? l10n.marketItemUnknownSeller,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: dt.onSurface,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 12,
                              color: AppColors.primaryGreen,
                            ),
                            const SizedBox(width: 2),
                            Flexible(
                              child: Text(
                                item.pickupAddress,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.cairo(
                                  fontSize: 11,
                                  color: dt.onSurfaceMuted,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Price (promoted here so it's scannable without reading
                  // the whole card) + time ago beneath it.
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (item.itemPrice != null)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              item.itemPrice!.toStringAsFixed(1),
                              style: GoogleFonts.dmSans(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.accentAmber,
                              ),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              'د.أ',
                              style: GoogleFonts.cairo(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AppColors.accentAmber,
                              ),
                            ),
                          ],
                        ),
                      Text(
                        timeLabel,
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          color: dt.onSurfaceMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Reservation badge ──
            if (item.reservationStatus != null) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFFCD34D)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item.reservationStatus!.label,
                            style: GoogleFonts.cairo(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF92400E),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.lock_clock_rounded,
                            color: Color(0xFFD97706),
                            size: 11,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // ── Waste type chips ──
            if (item.wasteTypes.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: item.wasteTypes.map((type) {
                    final iconData = WasteTypeIcons.all
                        .where((e) => e.$1 == type)
                        .map((e) => e.$2)
                        .firstOrNull;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceAlt,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (iconData != null) ...[
                            Icon(
                              iconData,
                              size: 12,
                              color: AppColors.primaryGreen,
                            ),
                            const SizedBox(width: 4),
                          ],
                          Text(
                            type.labelFor(locale),
                            style: GoogleFonts.cairo(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

            // ── Optional notes ──
            if (item.supplierNotes != null && item.supplierNotes!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                child: Text(
                  item.supplierNotes!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: dt.onSurfaceMuted,
                    height: 1.4,
                  ),
                ),
              ),

            // ── Footer: weight/form tags ──
            if (item.weightCategory != null || item.wasteForm != null)
              Container(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt.withValues(alpha: 0.5),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    if (item.weightCategory != null)
                      _MetaTag(
                        icon: Icons.fitness_center_rounded,
                        label: item.weightCategory!.shortLabelFor(locale),
                        color: dt.onSurfaceMuted,
                      ),
                    if (item.weightCategory != null && item.wasteForm != null)
                      const SizedBox(width: 8),
                    if (item.wasteForm != null)
                      _MetaTag(
                        icon: Icons.category_outlined,
                        label: item.wasteForm!.labelFor(locale),
                        color: dt.onSurfaceMuted,
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MetaTag extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MetaTag({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 3),
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
