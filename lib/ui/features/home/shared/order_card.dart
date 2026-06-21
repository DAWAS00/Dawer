import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/waste_type_icons.dart';
import '../../../../data/models/order/order.dart';
import '../../../../data/models/order_labels.dart';
import '../../../../l10n/l10n.dart';
import 'order_details_view.dart';

enum OrderCardMode {
  driverAvailable,
  driverHistory,
  driverActive,
  supplierActive,
  companyIncoming,
  companyJob,
}

class OrderCard extends StatelessWidget {
  final Order order;
  final OrderCardMode mode;
  final VoidCallback? onAction;

  const OrderCard({
    super.key,
    required this.order,
    required this.mode,
    this.onAction,
  });

  Color _accentColor() => switch (order.status) {
        OrderStatus.pending => AppColors.accentAmber,
        OrderStatus.accepted || OrderStatus.arrivedAtPickup => AppColors.statusActiveText,
        OrderStatus.inTransit || OrderStatus.arrivedAtDropoff => AppColors.jobBlue,
        OrderStatus.completed => AppColors.statusCompletedText,
        OrderStatus.cancelled => AppColors.statusCancelledText,
      };

  (Color bg, Color text) _statusChip() => switch (order.status) {
        OrderStatus.pending => (AppColors.statusPendingBg, AppColors.statusPendingText),
        OrderStatus.accepted ||
        OrderStatus.arrivedAtPickup =>
          (AppColors.statusActiveBg, AppColors.statusActiveText),
        OrderStatus.inTransit ||
        OrderStatus.arrivedAtDropoff =>
          (AppColors.statusInTransitBg, AppColors.statusInTransitText),
        OrderStatus.completed => (AppColors.statusCompletedBg, AppColors.statusCompletedText),
        OrderStatus.cancelled => (AppColors.statusCancelledBg, AppColors.statusCancelledText),
      };

  String _statusLabel(AppLocalizations l10n) => switch (order.status) {
        OrderStatus.pending => l10n.orderStatusPending,
        OrderStatus.accepted => l10n.orderStatusAccepted,
        OrderStatus.arrivedAtPickup => l10n.orderStatusArrivedAtPickup,
        OrderStatus.inTransit => l10n.orderStatusInTransit,
        OrderStatus.arrivedAtDropoff => l10n.orderStatusArrivedAtDropoff,
        OrderStatus.completed => l10n.orderStatusCompleted,
        OrderStatus.cancelled => l10n.orderStatusCancelled,
      };

  void _openDetails(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => OrderDetailsView(
        order: order,
        hideStatus: true,
        isDriverView: mode == OrderCardMode.driverAvailable ||
            mode == OrderCardMode.driverHistory ||
            mode == OrderCardMode.driverActive,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final accent = _accentColor();

    return GestureDetector(
      onTap: (mode == OrderCardMode.driverAvailable ||
              mode == OrderCardMode.driverHistory)
          ? () => _openDetails(context)
          : null,
      child: Container(
        decoration: BoxDecoration(
          color: accent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Container(
          margin: const EdgeInsetsDirectional.only(start: 4),
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
              _buildHeader(context, l10n, accent),
              const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F3)),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                child: _buildRoute(),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                child: _buildWasteChips(context),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(14, 12, 14, 0),
                child: Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F3)),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: _buildFooter(context, l10n, accent),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n, Color accent) {
    final (chipBg, chipText) = _statusChip();
    final d = order.createdAt;
    final dateStr =
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    final typeIcon =
        order.type == OrderType.pickup ? Icons.upload_rounded : Icons.download_rounded;
    final shortId = order.id.length > 6 ? order.id.substring(0, 6) : order.id;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(typeIcon, size: 17, color: accent),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: chipBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _statusLabel(l10n),
              style: GoogleFonts.cairo(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: chipText,
              ),
            ),
          ),
          if (mode == OrderCardMode.driverActive) ...[
            const SizedBox(width: 6),
            Icon(Icons.circle, size: 7, color: AppColors.statusActiveText),
          ],
          const Spacer(),
          Text(
            dateStr,
            style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.mutedText),
          ),
          const SizedBox(width: 6),
          Container(width: 1, height: 10, color: AppColors.borderSubtle),
          const SizedBox(width: 6),
          Text(
            '#$shortId',
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.mutedText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoute() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryGreen.withValues(alpha: 0.4),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            Container(width: 1.5, height: 20, color: AppColors.borderSubtle),
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: const Color(0xFFE53935),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE53935).withValues(alpha: 0.3),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                order.pickupAddress,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                order.dropoffAddress,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: GoogleFonts.cairo(fontSize: 13, color: AppColors.mutedText),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWasteChips(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      alignment: WrapAlignment.end,
      children: order.wasteTypes.map((t) {
        final icon = WasteTypeIcons.iconFor(t);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.surfaceAltBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                t.labelFor(locale),
                style: GoogleFonts.cairo(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(width: 4),
              Icon(icon, size: 12, color: AppColors.mutedText),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFooter(BuildContext context, AppLocalizations l10n, Color accent) {
    final isDriverAccepted =
        mode == OrderCardMode.driverActive && order.status == OrderStatus.accepted;

    final bool hasAction = mode == OrderCardMode.driverAvailable ||
        mode == OrderCardMode.companyJob ||
        mode == OrderCardMode.driverActive ||
        mode == OrderCardMode.supplierActive ||
        mode == OrderCardMode.driverHistory;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: _buildMetrics(context, l10n, isDriverAccepted)),
        if (hasAction) ...[
          const SizedBox(width: 12),
          _buildActionButton(context, l10n, accent, isDriverAccepted),
        ],
      ],
    );
  }

  Widget _buildMetrics(
      BuildContext context, AppLocalizations l10n, bool isDriverAccepted) {
    return Wrap(
      spacing: 16,
      runSpacing: 4,
      children: [
        if (isDriverAccepted && order.acceptedAt != null)
          _TimerMetric(acceptedAt: order.acceptedAt!, label: l10n.orderWaitingTime)
        else if (order.eta != null)
          _MetricPill(
            icon: Icons.timer_rounded,
            value: order.eta!,
            label: l10n.orderArrivalTime,
            color: AppColors.mutedText,
          ),
        if (order.reward > 0)
          _MetricPill(
            icon: Icons.attach_money_rounded,
            value: '${order.reward.toStringAsFixed(1)} ${l10n.orderCurrencyJD}',
            label: mode == OrderCardMode.driverAvailable
                ? l10n.orderPotentialEarnings
                : l10n.orderEarningsLabel,
            color: AppColors.statusActiveText,
            bold: true,
          ),
        if ((order.itemPrice ?? 0) > 0)
          _MetricPill(
            icon: Icons.receipt_long_rounded,
            value: '${order.itemPrice!.toStringAsFixed(1)} ${l10n.orderCurrencyJD}',
            label: l10n.orderTotalCost,
            color: AppColors.textMain,
            bold: true,
          ),
      ],
    );
  }

  Widget _buildActionButton(
      BuildContext context, AppLocalizations l10n, Color accent, bool isDriverAccepted) {
    final String label;
    final bool filled;

    if (mode == OrderCardMode.driverAvailable) {
      label = l10n.orderAcceptButton;
      filled = true;
    } else if (mode == OrderCardMode.driverActive) {
      label = isDriverAccepted ? l10n.orderViewRoute : l10n.driverViewDetails;
      filled = isDriverAccepted;
    } else {
      label = l10n.driverViewDetails;
      filled = false;
    }

    final VoidCallback tap = onAction ??
        () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => OrderDetailsView(
                order: order,
                hideStatus: mode != OrderCardMode.companyJob &&
                    mode != OrderCardMode.supplierActive,
                isDriverView: mode == OrderCardMode.driverAvailable ||
                    mode == OrderCardMode.driverHistory ||
                    mode == OrderCardMode.driverActive,
              ),
            ));

    if (filled) {
      return ElevatedButton(
        onPressed: tap,
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w700),
        ),
        child: Text(label),
      );
    }

    return OutlinedButton(
      onPressed: tap,
      style: OutlinedButton.styleFrom(
        foregroundColor: accent,
        side: BorderSide(color: accent.withValues(alpha: 0.5)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w700),
      ),
      child: Text(label),
    );
  }
}

// ── Metric pill ────────────────────────────────────────────────────────────

class _MetricPill extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final bool bold;

  const _MetricPill({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: GoogleFonts.cairo(fontSize: 10, color: AppColors.mutedText)),
        const SizedBox(height: 2),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
            Text(
              value,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Live timer widget ───────────────────────────────────────────────────────

class _TimerMetric extends StatelessWidget {
  final DateTime acceptedAt;
  final String label;

  const _TimerMetric({required this.acceptedAt, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: GoogleFonts.cairo(fontSize: 10, color: AppColors.mutedText)),
        const SizedBox(height: 2),
        StreamBuilder<void>(
          stream: Stream.periodic(const Duration(seconds: 1)),
          builder: (_, __) {
            final diff = DateTime.now().difference(acceptedAt);
            final m = diff.inMinutes.toString().padLeft(2, '0');
            final s = (diff.inSeconds % 60).toString().padLeft(2, '0');
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.timer_rounded, size: 13, color: AppColors.accentAmber),
                const SizedBox(width: 4),
                Text(
                  '$m:$s',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accentAmber,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
