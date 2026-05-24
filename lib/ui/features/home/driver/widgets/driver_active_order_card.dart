import 'package:flutter/material.dart';
import 'package:dwaar/core/theme/app_tokens.dart';
import 'package:dwaar/core/constants/app_colors.dart';
import 'package:dwaar/data/models/order.dart';

class DriverActiveOrderCard extends StatelessWidget {
  const DriverActiveOrderCard({
    super.key,
    required this.order,
    required this.onConfirmArrival,
  });

  final Order order;
  final VoidCallback onConfirmArrival;

  @override
  Widget build(BuildContext context) {
    final dt = context.dt;
    
    // Mock progress based on status
    double progress = 0.1;
    if (order.status == OrderStatus.accepted) progress = 0.3;
    if (order.status == OrderStatus.arrivedAtPickup) progress = 0.5;
    if (order.status == OrderStatus.inTransit) progress = 0.8;
    if (order.status == OrderStatus.completed) progress = 1.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: dt.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF4CAF50), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CAF50).withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFFE8F5E9),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Text(
                  '#${order.id} · ${order.wasteTypes.map((e) => e.label).join('، ')}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
                const Spacer(),
                Text(
                  '${(progress * 100).round()}% مكتمل',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _RouteRow(from: order.pickupAddress, to: order.dropoffAddress),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: dt.surfaceVariant,
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                    minHeight: 3,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      '${order.reward.toStringAsFixed(1)} دينار',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: dt.onSurface,
                      ),
                    ),
                    const Spacer(),
                    if (order.etaMinutes != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3F2FD),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.access_time_rounded,
                                size: 10, color: Color(0xFF1565C0)),
                            const SizedBox(width: 3),
                            Text(
                              '${order.etaMinutes} دقيقة',
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1565C0),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: onConfirmArrival,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryGreen,
                      side: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      order.status == OrderStatus.accepted 
                        ? 'تأكيد الوصول للاستلام' 
                        : 'تأكيد الوصول للتسليم'
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteRow extends StatelessWidget {
  const _RouteRow({required this.from, required this.to});
  final String from;
  final String to;

  @override
  Widget build(BuildContext context) {
    final dt = context.dt;
    return Row(
      children: [
        const _RouteDot(color: Color(0xFF2E7D32)),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            from,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 9, color: dt.onSurfaceVariant),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(child: Container(height: 1, color: dt.border)),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            to,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 9, color: dt.onSurfaceVariant),
          ),
        ),
        const SizedBox(width: 4),
        const _RouteDot(color: Color(0xFFD32F2F)),
      ],
    );
  }
}

class _RouteDot extends StatelessWidget {
  const _RouteDot({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
