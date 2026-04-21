import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/date_formatter.dart';
import '../../../../../data/models/order.dart';
import '../../../../../data/models/order_labels.dart';
import '../../../../../l10n/l10n.dart';

class OrderInfoSection extends StatelessWidget {
  final Order order;
  final OrderDetailsViewerRole viewerRole;

  const OrderInfoSection({
    super.key,
    required this.order,
    this.viewerRole = OrderDetailsViewerRole.supplier,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context);
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.orderDetailsTitle,
            style: GoogleFonts.cairo(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF002819),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: order.wasteTypes
                .map(
                  (w) => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color:
                          const Color(0xFF06402B).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      w.labelFor(locale),
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF06402B),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          _InfoRow(
            icon: Icons.radio_button_checked,
            iconColor: const Color(0xFF06402B),
            label: l10n.orderFromLabel,
            value: order.pickupAddress,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 7, top: 2, bottom: 2),
            child: Container(
                width: 1, height: 14, color: const Color(0xFFC0C9C1)),
          ),
          _InfoRow(
            icon: Icons.location_on_rounded,
            iconColor: Colors.red.shade400,
            label: l10n.orderToLabel,
            value: order.dropoffAddress,
          ),
          const SizedBox(height: 16),
          // ── meta chips ───────────────────────────────────────────────────
          Row(
            children: [
              if (order.distanceKm != null) ...[
                _MetaChip(
                  icon: Icons.straighten_rounded,
                  value: l10n.orderDistKm(order.distanceKm!.toStringAsFixed(1)),
                ),
                const SizedBox(width: 8),
              ],
              if (order.weightKg != null) ...[
                _MetaChip(
                  icon: Icons.scale_rounded,
                  value: l10n.orderWeightKgLabel(order.weightKg!.toStringAsFixed(0)),
                ),
                const SizedBox(width: 8),
              ],
              if (order.reward > 0)
                _MetaChip(
                  icon: Icons.monetization_on_outlined,
                  value: l10n.orderRewardJD(order.reward.toStringAsFixed(1)),
                  highlight: true,
                ),
            ],
          ),
          // ── extended details ─────────────────────────────────────────────
          if (_hasExtended) ..._buildExtended(),
        ],
      ),
    );
  }

  bool get _hasExtended =>
      (viewerRole != OrderDetailsViewerRole.supplier && order.supplierName != null) ||
      order.wasteForm != null ||
      order.weightCategory != null ||
      (order.estimatedWeightKg != null && order.weightKg == null) ||
      order.scheduledAt != null ||
      order.pricePerKg != null ||
      order.itemPrice != null ||
      order.minQuantityKg != null ||
      order.pickupTarget != null ||
      (order.supplierNotes != null && order.supplierNotes!.isNotEmpty) ||
      (order.jobDescription != null && order.jobDescription!.isNotEmpty);

  List<Widget> _buildExtended() {
    return [
      const Divider(height: 28, color: Color(0xFFE6E9E7)),
      if (viewerRole != OrderDetailsViewerRole.supplier && order.supplierName != null)
        _detailRow(
          Icons.person_outline_rounded,
          viewerRole == OrderDetailsViewerRole.driver ? 'مقدم الطلب' : 'المورد',
          order.supplierName!,
        ),
      if (order.wasteForm != null)
        _detailRow(Icons.layers_outlined, 'شكل المواد', order.wasteForm!.label),
      if (order.weightCategory != null)
        _detailRow(Icons.scale_outlined, 'تصنيف الوزن', order.weightCategory!.label),
      if (order.estimatedWeightKg != null && order.weightKg == null)
        _detailRow(Icons.scale_rounded, 'الوزن التقديري',
            '${order.estimatedWeightKg!.toStringAsFixed(1)} كغ'),
      if (order.scheduledAt != null)
        _detailRow(
          Icons.calendar_today_rounded,
          'موعد الاستلام',
          '${DateFormatter.date(order.scheduledAt!)}  ${DateFormatter.time(order.scheduledAt!)}',
        ),
      if (order.pricePerKg != null)
        _detailRow(Icons.payments_outlined, 'السعر لكل كغ',
            '${order.pricePerKg!.toStringAsFixed(2)} د.أ/كغ'),
      if (order.itemPrice != null)
        _detailRow(
          Icons.payments_outlined,
          order.pickupTarget == PickupTarget.riderBuy ? 'سعر الإدراج' : 'الأجر الثابت',
          '${order.itemPrice!.toStringAsFixed(2)} د.أ',
        ),
      if (order.minQuantityKg != null)
        _detailRow(Icons.storage_rounded, 'الحد الأدنى للكمية',
            '${order.minQuantityKg!.toStringAsFixed(1)} كغ'),
      if (order.pickupTarget != null)
        _detailRow(Icons.flag_outlined, 'نوع الاستلام', order.pickupTarget!.label),
      if (order.supplierNotes != null && order.supplierNotes!.isNotEmpty)
        _notesBlock(Icons.notes_rounded, 'ملاحظات', order.supplierNotes!),
      if (order.jobDescription != null && order.jobDescription!.isNotEmpty)
        _notesBlock(Icons.work_outline_rounded, 'وصف الوظيفة', order.jobDescription!),
    ];
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 14, color: const Color(0xFF9CA3AF)),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: GoogleFonts.cairo(
              fontSize: 12,
              color: const Color(0xFF717973),
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.cairo(
                fontSize: 13,
                color: const Color(0xFF404943),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _notesBlock(IconData icon, String label, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: const Color(0xFF9CA3AF)),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  color: const Color(0xFF717973),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAF8),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE6E9E7)),
            ),
            child: Text(
              text,
              textAlign: TextAlign.right,
              style: GoogleFonts.cairo(
                fontSize: 12,
                color: const Color(0xFF404943),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Info Row ──────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: iconColor),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: GoogleFonts.cairo(
            fontSize: 12,
            color: const Color(0xFF717973),
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.cairo(
              fontSize: 13,
              color: const Color(0xFF404943),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Meta Chip ─────────────────────────────────────────────────────────────────

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final bool highlight;

  const _MetaChip({
    required this.icon,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        highlight ? AppColors.statusActiveText : const Color(0xFF717973);
    final bg =
        highlight ? AppColors.statusActiveBg : const Color(0xFFF2F4F2);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
