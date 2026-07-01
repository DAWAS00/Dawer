import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../data/models/order/order.dart';

class OrderDetailsAppBar extends StatelessWidget {
  final Order order;
  final bool hideStatus;

  const OrderDetailsAppBar({
    super.key,
    required this.order,
    this.hideStatus = false,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      foregroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تفاصيل الطلب',
            style: GoogleFonts.cairo(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            '#${order.id}',
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.7),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
      actions: [
        if (!hideStatus)
          Container(
            margin: const EdgeInsets.only(left: 16, top: 10, bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: _statusColor(order.status).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _statusColor(order.status).withValues(alpha: 0.5),
              ),
            ),
            child: Text(
              order.status.label,
              style: GoogleFonts.cairo(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }

  Color _statusColor(OrderStatus s) {
    switch (s) {
      case OrderStatus.pending:
        return AppColors.statusPendingText;
      case OrderStatus.accepted:
      case OrderStatus.arrivedAtPickup:
        return AppColors.statusActiveText;
      case OrderStatus.inTransit:
      case OrderStatus.arrivedAtDropoff:
        return AppColors.statusInTransitText;
      case OrderStatus.completed:
        return AppColors.statusCompletedText;
      case OrderStatus.cancelled:
        return AppColors.statusCancelledText;
    }
  }
}
