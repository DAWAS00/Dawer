import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../data/models/order.dart';
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
    final cs = Theme.of(context).colorScheme;
    final isDark = cs.brightness == Brightness.dark;
    final (Color statusBg, Color statusText, String statusLabel) = _statusStyle();
    final dateStr =
        '${order.createdAt.day.toString().padLeft(2, '0')}/${order.createdAt.month.toString().padLeft(2, '0')}/${order.createdAt.year}';
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
            // ── Top row ───────────────────────────────────────────────────
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
                  _buildWasteChips(context),
                  if (order.supplierName != null &&
                      (mode == OrderCardMode.driverAvailable ||
                          mode == OrderCardMode.driverActive)) ...[          
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          order.supplierName!,
                          style: GoogleFonts.cairo(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: cs.onSurface.withValues(alpha: 0.85)),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'من:',
                          style: GoogleFonts.cairo(
                              fontSize: 12,
                              color: cs.onSurface.withValues(alpha: 0.5)),
                        ),
                      ],
                    ),
                  ],
                  if (mode == OrderCardMode.companyIncoming ||
                      mode == OrderCardMode.companyJob)
                    ..._buildUnderChipsRows(context),
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


  Widget _buildWasteChips(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
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
            t.label,
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
    final cs = Theme.of(context).colorScheme;
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
                'وقت الانتظار',
                style: GoogleFonts.cairo(
                  fontSize: 10,
                  color: cs.onSurface.withValues(alpha: 0.55),
                ),
              ),
              const SizedBox(height: 2),
              _TimerSinceAccepted(acceptedAt: order.acceptedAt!),
            ],
          ),
        ] else ...[
          // Regular ETA or Reward Display
          if (order.eta != null) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'وقت الوصول',
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
                  'العائد',
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
                      'دينار',
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
            child: _ActionButton(label: 'اقبل الطلب', onTap: onAction ?? () {}),
          ),
        if (mode == OrderCardMode.companyJob)
          SizedBox(
            width: 110,
            child: _ActionButton(
              label: 'عرض التفاصيل',
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
              label: 'عرض التفاصيل',
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
              label: isDriverAccepted ? 'عرض المسار' : 'عرض التفاصيل',
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
              label: 'عرض التفاصيل',
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

  // ── Secondary row helpers ────────────────────────────────────────────────

  List<Widget> _buildUnderChipsRows(BuildContext context) {
    if (mode == OrderCardMode.companyIncoming) {
      return [
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (order.estimatedWeightKg != null) ...
              [
                _badge(
                  '${order.estimatedWeightKg} كغ (تقديري)',
                  const Color(0xFFEBF4EE),
                  const Color(0xFF1E5C35),
                ),
                const SizedBox(width: 8),
              ],
            Text(
              'من: ${order.supplierName ?? ''}',
              style: GoogleFonts.cairo(
                  fontSize: 12, color: const Color(0xFF404943)),
            ),
          ],
        ),
        if (order.status == OrderStatus.inTransit &&
            order.etaMinutes != null) ...
          [
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: _badge(
                'وصول خلال ${order.etaMinutes} دقيقة',
                const Color(0xFFDBEAFE),
                const Color(0xFF1E40AF),
                useDmSans: true,
                bold: true,
                hPad: 8,
              ),
            ),
          ],
      ];
    }
    // companyJob
    final hasPayment = order.paymentModel != null;
    final hasMinQty = order.minQuantityKg != null;
    if (!hasPayment && !hasMinQty) return [];
    return [
      const SizedBox(height: 8),
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (hasMinQty) ...
            [
              Text(
                'الحد الأدنى: ${order.minQuantityKg} كغ',
                style: GoogleFonts.cairo(
                    fontSize: 11, color: const Color(0xFF717973)),
              ),
              const SizedBox(width: 8),
            ],
          if (order.paymentModel == PaymentModel.perKg)
            _badge(
              '${order.pricePerKg ?? 0} د.أ/كغ',
              const Color(0xFFFEF3C7),
              const Color(0xFFC8860A),
              useDmSans: true,
            )
          else if (order.paymentModel == PaymentModel.flatFee)
            _badge(
              'مبلغ ثابت',
              const Color(0xFFD1FAE5),
              const Color(0xFF1E5C35),
            ),
        ],
      ),
    ];
  }

  Widget _buildTimeElapsedRow() {
    if (order.status == OrderStatus.accepted && order.acceptedAt != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Text(
          'في انتظار الاستلام — ${DateFormatter.relative(order.acceptedAt!)}',
          textAlign: TextAlign.right,
          style: GoogleFonts.cairo(
              fontSize: 12, color: const Color(0xFFC8860A)),
        ),
      );
    }
    if (order.status == OrderStatus.inTransit && order.inTransitAt != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Text(
          'في الطريق — ${DateFormatter.relative(order.inTransitAt!)}',
          textAlign: TextAlign.right,
          style: GoogleFonts.cairo(
              fontSize: 12, color: const Color(0xFF1E40AF)),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildDriverAvailableExtras() {
    final hasWeight  = order.weightCategory != null;
    final hasDist    = order.distanceKm != null;
    final hasEta     = order.etaMinutes != null;
    if (!hasWeight && !hasDist && !hasEta) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (hasEta) ...
            [
              Text(
                '${order.etaMinutes} د وصول',
                style: GoogleFonts.dmSans(
                    fontSize: 11, color: const Color(0xFF717973)),
              ),
              const SizedBox(width: 8),
            ],
          if (hasDist) ...
            [
              Text(
                '${order.distanceKm!.toStringAsFixed(1)} كم',
                style: GoogleFonts.dmSans(
                    fontSize: 12, color: const Color(0xFF404943)),
              ),
              const SizedBox(width: 8),
            ],
          if (hasWeight)
            _badge(
              order.weightCategory!.shortLabel,
              const Color(0xFFEBF4EE),
              const Color(0xFF1E5C35),
            ),
        ],
      ),
    );
  }

  Widget _badge(
    String text,
    Color bg,
    Color fg, {
    bool useDmSans = false,
    bool bold = false,
    double hPad = 6,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: useDmSans
            ? GoogleFonts.dmSans(
                fontSize: 11,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                color: fg,
              )
            : GoogleFonts.cairo(
                fontSize: 11,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                color: fg,
              ),
      ),
    );
  }

  // ── Status style ─────────────────────────────────────────────────────────

  (Color, Color, String) _statusStyle() {
    switch (order.status) {
      case OrderStatus.pending:
        return (AppColors.statusPendingBg, AppColors.statusPendingText, 'قيد الانتظار');
      case OrderStatus.accepted:
        return (AppColors.statusActiveBg, AppColors.statusActiveText, 'تم القبول');
      case OrderStatus.inTransit:
        return (AppColors.statusInTransitBg, AppColors.statusInTransitText, 'في الطريق');
      case OrderStatus.completed:
        return (AppColors.statusCompletedBg, AppColors.statusCompletedText, 'مكتمل');
      case OrderStatus.cancelled:
        return (AppColors.statusCancelledBg, AppColors.statusCancelledText, 'ملغي');
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
