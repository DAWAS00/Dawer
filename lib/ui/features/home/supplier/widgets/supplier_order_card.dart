import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/date_formatter.dart';
import '../../../../../data/models/order/order.dart';
import '../../../../../data/models/order_labels.dart';
import '../../../../../data/services/app_order_store.dart';
import '../../../../../l10n/l10n.dart';
import '../../shared/order_details_view.dart';
import 'package:dwaar/ui/common/order_progress_stepper.dart';

class SupplierOrderCard extends StatelessWidget {
  final Order order;
  final bool canCancel;
  final String? Function(String orderId) onCancelOrder;

  const SupplierOrderCard({
    super.key,
    required this.order,
    this.canCancel = false,
    required this.onCancelOrder,
  });

  Color get _accent => switch (order.status) {
    OrderStatus.pending => AppColors.accentAmber,
    OrderStatus.accepted ||
    OrderStatus.arrivedAtPickup => AppColors.statusActiveText,
    OrderStatus.inTransit || OrderStatus.arrivedAtDropoff => AppColors.jobBlue,
    OrderStatus.completed => AppColors.statusCompletedText,
    OrderStatus.cancelled => AppColors.statusCancelledText,
  };

  /// Whether the order is currently being fulfilled (between acceptance and
  /// delivery) — the window where live tracking matters most.
  bool get _isInFlight =>
      order.status == OrderStatus.accepted ||
      order.status == OrderStatus.arrivedAtPickup ||
      order.status == OrderStatus.inTransit ||
      order.status == OrderStatus.arrivedAtDropoff;

  /// Plain-language "what's happening right now" line + matching icon, shown
  /// in the live tracking banner so the customer doesn't have to decode chips.
  (IconData, String) statusLine(AppLocalizations l10n) =>
      switch (order.status) {
        OrderStatus.pending => (
          Icons.hourglass_top_rounded,
          l10n.supplierOrderPendingDriver,
        ),
        OrderStatus.accepted => (
          Icons.directions_car_rounded,
          l10n.supplierOrderAcceptedOnWay,
        ),
        OrderStatus.arrivedAtPickup => (
          Icons.pin_drop_rounded,
          l10n.supplierOrderDriverArrivedPickup,
        ),
        OrderStatus.inTransit => (
          Icons.local_shipping_rounded,
          l10n.supplierOrderInTransitToDest,
        ),
        OrderStatus.arrivedAtDropoff => (
          Icons.flag_rounded,
          l10n.supplierOrderDriverArrivedDropoff,
        ),
        OrderStatus.completed => (
          Icons.check_circle_rounded,
          l10n.supplierOrderDeliveredSuccess,
        ),
        OrderStatus.cancelled => (
          Icons.cancel_rounded,
          l10n.supplierOrderCancelledDone,
        ),
      };

  (Color bg, Color text) get _chip => switch (order.status) {
    OrderStatus.pending => (
      AppColors.statusPendingBg,
      AppColors.statusPendingText,
    ),
    OrderStatus.accepted || OrderStatus.arrivedAtPickup => (
      AppColors.statusActiveBg,
      AppColors.statusActiveText,
    ),
    OrderStatus.inTransit || OrderStatus.arrivedAtDropoff => (
      AppColors.statusInTransitBg,
      AppColors.statusInTransitText,
    ),
    OrderStatus.completed => (
      AppColors.statusCompletedBg,
      AppColors.statusCompletedText,
    ),
    OrderStatus.cancelled => (
      AppColors.statusCancelledBg,
      AppColors.statusCancelledText,
    ),
  };

  void _showCancelDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          ctx.l10n.cancelOrderTitle,
          textAlign: TextAlign.right,
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        content: Text(
          ctx.l10n.cancelOrderConfirm,
          textAlign: TextAlign.right,
          style: GoogleFonts.cairo(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              ctx.l10n.no,
              style: GoogleFonts.cairo(color: AppColors.mutedText),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              final error = onCancelOrder(order.id);
              if (error != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(error, style: GoogleFonts.cairo()),
                    backgroundColor: Colors.orange.shade700,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: Text(
              ctx.l10n.yesCancelOrder,
              style: GoogleFonts.cairo(
                color: AppColors.statusCancelledText,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openTracking(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OrderDetailsView(
          order: order,
          onSupplierConfirmArrival: (available) {
            final store = context.read<AppOrderStore>();
            if (available) {
              store.handleSupplierAvailable(order.id);
            } else {
              store.handleSupplierUnavailable(order.id);
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final accent = _accent;
    final (chipBg, chipText) = _chip;

    return GestureDetector(
      onTap: () => _openTracking(context),
      child: Container(
        decoration: BoxDecoration(
          color: accent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.10),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Container(
          margin: const EdgeInsetsDirectional.only(start: 4),
          padding: const EdgeInsets.all(14),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadiusDirectional.only(
              topStart: Radius.circular(13),
              bottomStart: Radius.circular(13),
              topEnd: Radius.circular(16),
              bottomEnd: Radius.circular(16),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header row ──
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.recycling_rounded,
                      size: 17,
                      color: accent,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: chipBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      order.status.labelFor(locale),
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: chipText,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '#${order.id.length > 6 ? order.id.substring(0, 6) : order.id}',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMain,
                        ),
                      ),
                      Text(
                        DateFormatter.relative(order.createdAt),
                        style: GoogleFonts.cairo(
                          fontSize: 10,
                          color: AppColors.mutedText,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(height: 1, color: Color(0xFFF1F5F3)),
              const SizedBox(height: 10),

              // ── Waste chips ──
              Wrap(
                spacing: 6,
                runSpacing: 4,
                alignment: WrapAlignment.end,
                children: order.wasteTypes
                    .map(
                      (t) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceAlt,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.surfaceAltBorder),
                        ),
                        child: Text(
                          t.labelFor(locale),
                          style: GoogleFonts.cairo(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMain,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),

              // ── Scheduled time ──
              if (order.scheduledAt != null) ...[
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${context.l10n.orderScheduledAt}: ${DateFormatter.date(order.scheduledAt!)} ${DateFormatter.time(order.scheduledAt!)}',
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        color: AppColors.jobBlue,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.schedule_rounded,
                      size: 13,
                      color: AppColors.jobBlue,
                    ),
                  ],
                ),
              ],

              // ── Driver info pill ──
              if (order.driverName != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Row(
                    children: [
                      if (order.eta != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.statusInTransitBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            order.eta!,
                            style: GoogleFonts.cairo(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.jobBlue,
                            ),
                          ),
                        ),
                      ],
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            order.driverName!,
                            style: GoogleFonts.cairo(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textMain,
                            ),
                          ),
                          if (order.driverRating != null)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  order.driverRating!.toStringAsFixed(1),
                                  style: GoogleFonts.dmSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.mutedText,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                const Icon(
                                  Icons.star_rounded,
                                  color: Color(0xFFFFC107),
                                  size: 13,
                                ),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(width: 10),
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.primaryGreen.withValues(
                          alpha: 0.12,
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          color: AppColors.primaryGreen,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // ── Live status banner ──
              if (order.status != OrderStatus.completed &&
                  order.status != OrderStatus.cancelled) ...[
                const SizedBox(height: 12),
                _LiveStatusBanner(
                  icon: statusLine(context.l10n).$1,
                  text: statusLine(context.l10n).$2,
                  eta: _isInFlight ? order.eta : null,
                  accent: accent,
                ),
              ],

              // ── Progress Stepper ──
              if (order.status != OrderStatus.completed &&
                  order.status != OrderStatus.cancelled) ...[
                const SizedBox(height: 14),
                OrderProgressStepper(status: order.status),
              ],

              // ── Track button (in-flight orders) ──
              if (_isInFlight) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: () => _openTracking(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(
                      Icons.location_searching_rounded,
                      size: 17,
                    ),
                    label: Text(
                      context.l10n.orderTrackButton,
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],

              // ── Cancel button ──
              if (canCancel) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: OutlinedButton.icon(
                    onPressed: () => _showCancelDialog(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.statusCancelledText,
                      side: BorderSide(
                        color: AppColors.statusCancelledText.withValues(
                          alpha: 0.4,
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.cancel_outlined, size: 16),
                    label: Text(
                      context.l10n.cancelOrderTitle,
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Plain-language status line with an accent icon and an optional ETA pill.
/// Gives the customer an immediate read on their order without decoding the
/// status chip or the stepper.
class _LiveStatusBanner extends StatelessWidget {
  final IconData icon;
  final String text;
  final String? eta;
  final Color accent;

  const _LiveStatusBanner({
    required this.icon,
    required this.text,
    required this.eta,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 16, color: accent),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              textAlign: TextAlign.right,
              style: GoogleFonts.cairo(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textMain,
              ),
            ),
          ),
          if (eta != null && eta!.isNotEmpty) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.schedule_rounded,
                    size: 11,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    eta!,
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
