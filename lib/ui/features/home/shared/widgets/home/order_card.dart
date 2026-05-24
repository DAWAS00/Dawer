import 'package:flutter/material.dart';
import 'package:dwaar/core/theme/app_tokens.dart';
import 'package:dwaar/core/constants/app_colors.dart';
import 'package:dwaar/data/models/order.dart';

class HomeOrderCard extends StatelessWidget {
  const HomeOrderCard({
    super.key,
    required this.order,
    this.onTap,
  });

  final Order order;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final dt = context.dt;
    final (statusLabel, statusBg, statusFg, progressColor) = _resolveStatus(order.status);

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _OrderCardTop(
              order: order,
              statusLabel: statusLabel,
              statusBg: statusBg,
              statusFg: statusFg,
            ),
            Divider(
              height: 1,
              thickness: 0.5,
              color: dt.border.withValues(alpha: 0.5),
            ),
            _OrderCardBottom(
              order: order,
              progressColor: progressColor,
            ),
          ],
        ),
      ),
    );
  }

  (String, Color, Color, Color) _resolveStatus(OrderStatus status) =>
      switch (status) {
        OrderStatus.inTransit || OrderStatus.arrivedAtPickup || OrderStatus.arrivedAtDropoff || OrderStatus.accepted => (
            status.label,
            const Color(0xFFE8F5E9),
            AppColors.primaryGreen,
            const Color(0xFF4CAF50),
          ),
        OrderStatus.pending => (
            status.label,
            AppColors.amberContainer,
            AppColors.accentAmber,
            AppColors.accentAmber,
          ),
        OrderStatus.completed => (
            status.label,
            const Color(0xFFE8F5E9),
            AppColors.primaryGreen,
            const Color(0xFF4CAF50),
          ),
        OrderStatus.cancelled => (
            status.label,
            const Color(0xFFFFEBEE),
            const Color(0xFFD32F2F),
            const Color(0xFFD32F2F),
          ),
      };
}

class _OrderCardTop extends StatelessWidget {
  const _OrderCardTop({
    required this.order,
    required this.statusLabel,
    required this.statusBg,
    required this.statusFg,
  });

  final Order order;
  final String statusLabel;
  final Color statusBg;
  final Color statusFg;

  @override
  Widget build(BuildContext context) {
    final dt = context.dt;
    final dateString = '${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '#${order.id}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: dt.onSurface,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '· $dateString',
                style: TextStyle(
                  fontSize: 10,
                  color: dt.onSurfaceMuted,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: statusFg,
                  ),
                ),
              ),
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
          _RouteRow(from: order.pickupAddress, to: order.dropoffAddress),
        ],
      ),
    );
  }
}

class _OrderCardBottom extends StatelessWidget {
  const _OrderCardBottom({
    required this.order,
    required this.progressColor,
  });

  final Order order;
  final Color progressColor;

  @override
  Widget build(BuildContext context) {
    final dt = context.dt;
    // Calculate mock progress based on status
    double progress = 0.1;
    if (order.status == OrderStatus.accepted) progress = 0.3;
    if (order.status == OrderStatus.inTransit) progress = 0.7;
    if (order.status == OrderStatus.completed) progress = 1.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: dt.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                order.itemPrice != null
                    ? '${order.itemPrice!.toStringAsFixed(1)} دينار'
                    : '— دينار',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: order.itemPrice != null ? dt.onSurface : dt.onSurfaceMuted,
                ),
              ),
              const Spacer(),
              if (order.status == OrderStatus.inTransit) ...[
                const Icon(Icons.access_time_rounded, size: 11, color: AppColors.mutedText),
                const SizedBox(width: 3),
                const Text(
                  'في الطريق',
                  style: TextStyle(fontSize: 9, color: AppColors.mutedText),
                ),
              ] else if (order.status == OrderStatus.pending) ...[
                const Icon(Icons.hourglass_empty_rounded, size: 11, color: AppColors.accentAmber),
                const SizedBox(width: 3),
                const Text(
                  'في الانتظار',
                  style: TextStyle(fontSize: 9, color: AppColors.mutedText),
                ),
              ],
            ],
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
        const SizedBox(width: 5),
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
        const SizedBox(width: 5),
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
      width: 7,
      height: 7,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
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
