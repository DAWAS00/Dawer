import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../data/models/order/order.dart';
import '../../../../../ui/core/components/dwaar_detail_card.dart';

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
    final isActive =
        order.status == OrderStatus.accepted ||
        order.status == OrderStatus.inTransit ||
        order.status == OrderStatus.arrivedAtPickup ||
        order.status == OrderStatus.arrivedAtDropoff;

    return SliverAppBar(
      pinned: true,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.ctaGradientStart, AppColors.headerGradientEnd],
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      leading: Center(
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                  ),
                ),
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
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
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 10, bottom: 10),
            child: DwaarStatusBadge(
              label: order.status.label,
              backgroundColor: _statusColor(
                order.status,
              ).withValues(alpha: 0.2),
              textColor: Colors.white,
              pulsing: isActive,
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
