import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../data/models/order.dart';
import '../../../../data/models/order_labels.dart';
import '../../../../l10n/l10n.dart';
import 'order_details_view.dart';

enum OrderCardMode { driverAvailable, driverHistory, driverActive, supplierActive, companyIncoming, companyJob }

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

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context);
    return GestureDetector(
      onTap: (mode == OrderCardMode.driverAvailable ||
              mode == OrderCardMode.driverHistory)
          ? () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => OrderDetailsView(
                    order: order,
                    viewerRole: OrderDetailsViewerRole.driver,
                  ),
                ),
              )
          : null,
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: cs.onSurface.withValues(alpha: isDark ? 0.12 : 0.07)),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(l10n),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusLabel,
                      style: GoogleFonts.cairo(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: statusText),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    dateStr,
                    style: GoogleFonts.dmSans(
                        fontSize: 11,
                        color: cs.onSurface.withValues(alpha: 0.45),
                        letterSpacing: 0.3),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    width: 1,
                    height: 10,
                    color: cs.onSurface.withValues(alpha: 0.2),
                  ),
                  Icon(
                    order.type == OrderType.pickup
                        ? Icons.upload_rounded
                        : Icons.download_rounded,
                    size: 13,
                    color: cs.onSurface.withValues(alpha: 0.4),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    '#${order.id}',
                    style: GoogleFonts.dmSans(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface.withValues(alpha: 0.65),
                        letterSpacing: 0.3),
                  ),
                ],
              ),
            ),
            Divider(
                height: 1,
                thickness: 1,
                color: cs.onSurface.withValues(alpha: 0.07)),
            // ── Body ────────────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildWasteChips(locale),
                  const SizedBox(height: 10),
                  _buildAddressRow(context),
                  if (mode == OrderCardMode.driverActive)
                    _buildTimeElapsedRow(),
                  const SizedBox(height: 12),
                  _buildFooterRow(context),
                  if (mode == OrderCardMode.driverAvailable)
                    _buildDriverAvailableExtras(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    final (Color bg, Color text, String label) = _statusStyle(l10n);
    final dateString = '${order.createdAt.day.toString().padLeft(2, '0')}/${order.createdAt.month.toString().padLeft(2, '0')}/${order.createdAt.year}';
    
    return Container(
      decoration: BoxDecoration(
        color: bg.withValues(alpha: 0.12),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: text,
              ),
            ),
          ),
          const Spacer(),
          Text(
            dateString,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: const Color(0xFF717973),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 8),
          Container(width: 1, height: 12, color: const Color(0xFF717973).withValues(alpha: 0.3)),
          const SizedBox(width: 8),
          Text(
            '#${order.id}',
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: const Color(0xFF717973),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 6),
          Icon(
            order.type == OrderType.pickup
                ? Icons.upload_rounded
                : Icons.download_rounded,
            size: 14,
            color: const Color(0xFF717973),
          ),
        ],
      ),
    );
  }

  Widget _buildWasteChips(Locale locale) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      alignment: WrapAlignment.end,
      children: order.wasteTypes.map((t) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: cs.onSurface.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            t.labelFor(locale),
            style: GoogleFonts.cairo(
              fontSize: 12,
              color: cs.onSurface.withValues(alpha: 0.78),
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAddressRow(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AddressLine(
          icon: Icons.radio_button_checked,
          iconColor: const Color(0xFF06402B),
          text: order.pickupAddress,
        ),
        Padding(
          padding: const EdgeInsets.only(right: 9),
          child: Container(
            width: 1,
            height: 16,
            color: cs.onSurface.withValues(alpha: 0.18),
          ),
        ),
        _AddressLine(
          icon: Icons.location_on_rounded,
          iconColor: Colors.red.shade400,
          text: order.dropoffAddress,
        ),
      ],
    );
  }

  Widget _buildFooterRow(BuildContext context) {
    final l10n = context.l10n;
    // If it's a driver viewing an accepted order, they need to see the timer and start button
    final isDriverAccepted = mode == OrderCardMode.driverActive &&
        order.status == OrderStatus.accepted;

    final bool hasAction = mode == OrderCardMode.driverAvailable ||
        mode == OrderCardMode.companyJob ||
        mode == OrderCardMode.driverActive ||
        mode == OrderCardMode.supplierActive ||
        mode == OrderCardMode.driverHistory;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (mode == OrderCardMode.supplierActive &&
            order.status == OrderStatus.inTransit &&
            order.etaMinutes != null) ...
          [
            _badge(
              'وصول خلال ${order.etaMinutes} دقيقة',
              const Color(0xFFDBEAFE),
              const Color(0xFF1E40AF),
              useDmSans: true,
              bold: true,
              hPad: 8,
            ),
            const SizedBox(width: 8),
          ],
        if (isDriverAccepted && order.acceptedAt != null) ...[
          // Show timer since accepted
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.orderWaitingTime,
                style: GoogleFonts.cairo(
                  fontSize: 10,
                  color: cs.onSurface.withValues(alpha: 0.55),
                ),
              ),
              const SizedBox(height: 2),
              _TimerSinceAccepted(acceptedAt: order.acceptedAt!),
            ],
          ),
        ] else ...[          // Regular ETA or Reward Display
          if (order.eta != null) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.orderArrivalTime,
                  style: GoogleFonts.cairo(
                    fontSize: 10,
                    color: cs.onSurface.withValues(alpha: 0.55),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.timer_rounded,
                        size: 14, color: cs.onSurface.withValues(alpha: 0.65)),
                    const SizedBox(width: 4),
                    Text(
                      order.eta!,
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (order.reward > 0) const SizedBox(width: 24),
          ],
          if (order.reward > 0)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.orderEarningsLabel,
                  style: GoogleFonts.cairo(
                    fontSize: 10,
                    color: cs.onSurface.withValues(alpha: 0.55),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      order.reward.toStringAsFixed(1),
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.statusActiveText,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      l10n.orderCurrencyJD,
                      style: GoogleFonts.cairo(
                        fontSize: 10,
                        color: AppColors.statusActiveText,
                      ),
                    ),
                  ],
                ),
              ],
            ),
        ],

        if (mode == OrderCardMode.supplierActive) ...
          [
            const SizedBox(width: 8),
            _badge(
              DateFormatter.relative(order.createdAt),
              const Color(0xFFF4F6F5),
              const Color(0xFF717973),
            ),
          ],

        // Spacer to push the action button to the far left
        if (hasAction) const Spacer(),

        // Action buttons
        if (mode == OrderCardMode.driverAvailable)
          SizedBox(
            width: 110,
            child: _ActionButton(label: context.l10n.orderAcceptButton, onTap: onAction ?? () {}),
          ),
        if (mode == OrderCardMode.companyJob)
          SizedBox(
            width: 110,
            child: _ActionButton(
              label: context.l10n.driverViewDetails,
              outlined: true,
              onTap: onAction ??
                  () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => OrderDetailsView(order: order),
                        ),
                      ),
            ),
          ),
        if (mode == OrderCardMode.supplierActive)
          SizedBox(
            width: 110,
            child: _ActionButton(
              label: context.l10n.driverViewDetails,
              outlined: true,
              onTap: onAction ??
                  () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => OrderDetailsView(order: order),
                        ),
                      ),
            ),
          ),
        if (mode == OrderCardMode.driverActive)
          SizedBox(
            width: 110,
            child: _ActionButton(
              label: isDriverAccepted ? context.l10n.orderViewRoute : context.l10n.driverViewDetails,
              outlined: !isDriverAccepted,
              onTap: onAction ??
                  () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => OrderDetailsView(order: order),
                        ),
                      ),
            ),
          ),
        if (mode == OrderCardMode.driverHistory)
          SizedBox(
            width: 110,
            child: _ActionButton(
              label: context.l10n.driverViewDetails,
              outlined: true,
              onTap: onAction ??
                  () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => OrderDetailsView(order: order),
                        ),
                      ),
            ),
          ),
      ],
    );
  }

  (Color, Color, String) _statusStyle(AppLocalizations l10n) {
    switch (order.status) {
      case OrderStatus.pending:
        return (AppColors.statusPendingBg, AppColors.statusPendingText, l10n.orderStatusPending);
      case OrderStatus.accepted:
        return (AppColors.statusActiveBg, AppColors.statusActiveText, l10n.orderStatusAccepted);
      case OrderStatus.inTransit:
        return (AppColors.statusInTransitBg, AppColors.statusInTransitText, l10n.orderStatusInTransit);
      case OrderStatus.completed:
        return (AppColors.statusCompletedBg, AppColors.statusCompletedText, l10n.orderStatusCompleted);
      case OrderStatus.cancelled:
        return (AppColors.statusCancelledBg, AppColors.statusCancelledText, l10n.orderStatusCancelled);
    }
  }
}

class _AddressLine extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String text;

  const _AddressLine({
    required this.icon,
    required this.iconColor,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: iconColor),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.cairo(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.78),
            ),
          ),
        ),
      ],
    );
  }
}

class _TimerSinceAccepted extends StatelessWidget {
  final DateTime acceptedAt;

  const _TimerSinceAccepted({required this.acceptedAt});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Stream.periodic(const Duration(seconds: 1)),
      builder: (context, snapshot) {
        final diff = DateTime.now().difference(acceptedAt);
        final minutes = diff.inMinutes;
        final seconds = diff.inSeconds % 60;
        final timeString = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
        
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.timer_rounded, size: 14, color: AppColors.accentAmber),
            const SizedBox(width: 4),
            Text(
              timeString,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.accentAmber,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool outlined;

  const _ActionButton({
    required this.label,
    required this.onTap,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: outlined ? Colors.transparent : const Color(0xFF06402B),
          borderRadius: BorderRadius.circular(10),
          border: outlined
              ? Border.all(color: const Color(0xFF06402B))
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: outlined ? const Color(0xFF06402B) : Colors.white,
          ),
        ),
      ),
    );
  }
}
