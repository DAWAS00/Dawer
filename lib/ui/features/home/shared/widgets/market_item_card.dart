import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/app_tokens.dart';
import '../../../../../data/models/order.dart';
import '../../../../../data/models/order_labels.dart';
import '../../../../../l10n/l10n.dart';

class MarketItemCard extends StatelessWidget {
  final Order item;
  final VoidCallback onTap;

  const MarketItemCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context);
    final timeDiff = DateTime.now().difference(item.createdAt);
    final timeLabel = timeDiff.inDays > 0
        ? l10n.timeAgoDays(timeDiff.inDays)
        : timeDiff.inHours > 0
            ? l10n.timeAgoHours(timeDiff.inHours)
            : l10n.timeAgoMinutes(timeDiff.inMinutes);

    final dt = context.dt;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: dt.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: dt.shadow.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: Text(
                      '${item.itemPrice?.toStringAsFixed(1) ?? '0'} د.أ',
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFC8860A),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Flexible(
                    child: Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      alignment: WrapAlignment.end,
                      children: item.wasteTypes.map((type) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF06402B).withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            type.labelFor(locale),
                            style: GoogleFonts.cairo(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF06402B),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    item.supplierName ?? l10n.marketItemUnknownSeller,
                    style: GoogleFonts.cairo(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: dt.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        item.pickupAddress,
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          color: dt.onSurfaceMuted,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.location_on_rounded, size: 14, color: dt.onSurfaceMuted),
                    ],
                  ),
                  if (item.supplierNotes != null && item.supplierNotes!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      item.supplierNotes!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: dt.onSurfaceMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              decoration: BoxDecoration(
                color: dt.surfaceVariant,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Text(
                    timeLabel,
                    style: GoogleFonts.cairo(fontSize: 11, color: dt.onSurfaceMuted),
                  ),
                  const Spacer(),
                  if (item.weightCategory != null) ...[
                    Icon(Icons.fitness_center_rounded, size: 13, color: dt.onSurfaceVariant),
                    const SizedBox(width: 3),
                    Text(
                      item.weightCategory!.shortLabelFor(locale),
                      style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.bold, color: dt.onSurfaceVariant),
                    ),
                    const SizedBox(width: 12),
                  ],
                  if (item.wasteForm != null) ...[
                    Icon(Icons.category_rounded, size: 13, color: dt.onSurfaceVariant),
                    const SizedBox(width: 3),
                    Text(
                      item.wasteForm!.labelFor(locale),
                      style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.bold, color: dt.onSurfaceVariant),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
