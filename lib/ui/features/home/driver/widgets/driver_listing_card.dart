import 'package:flutter/material.dart';
import 'package:dwaar/core/theme/app_tokens.dart';
import 'package:dwaar/core/constants/app_colors.dart';
import 'package:dwaar/data/models/order/order.dart';

class DriverListingCard extends StatelessWidget {
  const DriverListingCard({
    super.key,
    required this.order,
    this.onDelete,
    this.onTap,
  });

  final Order order;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final dt = context.dt;

    // Calculate time ago (simplified)
    final diff = DateTime.now().difference(order.createdAt);
    final postedAgo = diff.inHours > 0
        ? 'منذ ${diff.inHours} ساعة'
        : 'منذ ${diff.inMinutes} دقيقة';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: dt.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: dt.border, width: 0.5),
          boxShadow: [
            BoxShadow(
              color: dt.shadow.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '#${order.id}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: dt.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          postedAgo,
                          style: TextStyle(
                            fontSize: 9,
                            color: dt.onSurfaceMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: order.status == OrderStatus.pending
                          ? AppColors.amberContainer
                          : const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      order.status == OrderStatus.pending
                          ? 'بانتظار مشتري'
                          : 'نشط',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        color: order.status == OrderStatus.pending
                            ? AppColors.accentAmber
                            : AppColors.primaryGreen,
                      ),
                    ),
                  ),
                  if (onDelete != null) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: onDelete,
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        size: 18,
                        color: Color(0xFFD32F2F),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 4,
                children: order.wasteTypes
                    .map((c) => _CategoryTag(label: c.label))
                    .toList(),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    '${order.itemPrice?.toStringAsFixed(1) ?? "0.0"} د.أ',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: dt.onSurface,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    order.weightCategory?.shortLabel ?? 'غير محدد',
                    style: TextStyle(fontSize: 9, color: dt.onSurfaceMuted),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryTag extends StatelessWidget {
  const _CategoryTag({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final dt = context.dt;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: dt.surfaceVariant,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 9, color: dt.onSurfaceVariant),
      ),
    );
  }
}
