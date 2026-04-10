import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
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
    return GestureDetector(
      onTap: (mode == OrderCardMode.driverAvailable || mode == OrderCardMode.driverHistory)
          ? () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => OrderDetailsView(order: order),
                ),
              )
          : null,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildWasteChips(),
                  const SizedBox(height: 10),
                  _buildAddressRow(),
                  const SizedBox(height: 12),
                  _buildFooterRow(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final (Color bg, Color text, String label) = _statusStyle();
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

  Widget _buildWasteChips() {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      alignment: WrapAlignment.end,
      children: order.wasteTypes.map((t) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF2F4F2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            t.label,
            style: GoogleFonts.cairo(
              fontSize: 12,
              color: const Color(0xFF404943),
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAddressRow() {
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
            color: const Color(0xFFC0C9C1),
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
        if (isDriverAccepted && order.acceptedAt != null) ...[
          // Show timer since accepted
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'وقت الانتظار',
                style: GoogleFonts.cairo(
                  fontSize: 10,
                  color: const Color(0xFF717973),
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
                    color: const Color(0xFF717973),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.timer_rounded,
                        size: 14, color: Color(0xFF404943)),
                    const SizedBox(width: 4),
                    Text(
                      order.eta!,
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF404943),
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
                    color: const Color(0xFF717973),
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
              color: const Color(0xFF404943),
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
