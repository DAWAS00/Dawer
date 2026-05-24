import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:dwaar/core/theme/app_tokens.dart';
import 'package:dwaar/core/constants/app_colors.dart';
import 'package:dwaar/data/models/order.dart';

class DriverAvailableOrderCard extends StatefulWidget {
  const DriverAvailableOrderCard({
    super.key,
    required this.order,
    required this.onAccept,
    this.onTap,
  });

  final Order order;
  final VoidCallback onAccept;
  final VoidCallback? onTap;

  @override
  State<DriverAvailableOrderCard> createState() => _DriverAvailableOrderCardState();
}

class _DriverAvailableOrderCardState extends State<DriverAvailableOrderCard> {
  bool _isAccepting = false;

  void _handleAccept() {
    setState(() => _isAccepting = true);
    // Give time for the animation to play before triggering the actual logic
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) widget.onAccept();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dt = context.dt;
    final (badgeLabel, badgeBg, badgeFg) = _resolveBadge(widget.order.status);
    final dateString = '${widget.order.createdAt.day}/${widget.order.createdAt.month}/${widget.order.createdAt.year}';

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: dt.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: dt.border, width: 0.5),
          boxShadow: [
            BoxShadow(
                color: dt.shadow.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 1)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '#${widget.order.id}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: dt.onSurface,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        dateString,
                        style: TextStyle(
                          fontSize: 9,
                          color: dt.onSurfaceMuted,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: badgeBg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          badgeLabel,
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            color: badgeFg,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 4,
                    children: widget.order.wasteTypes
                        .map((c) => _CategoryTag(label: c.label))
                        .toList(),
                  ),
                ],
              ),
            ),
            Divider(
                height: 1, thickness: 0.5, color: dt.border.withValues(alpha: 0.5)),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
              child: Column(
                children: [
                  _RouteRow(from: widget.order.pickupAddress, to: widget.order.dropoffAddress),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isAccepting ? null : _handleAccept,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isAccepting ? const Color(0xFF4CAF50) : AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: _isAccepting
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_rounded, size: 18),
                                SizedBox(width: 8),
                                Text('تم القبول ✓', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              ],
                            )
                          : const Text('اقبل الطلب', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ).animate(target: _isAccepting ? 1 : 0)
                     .shimmer(duration: 400.ms, color: Colors.white24)
                     .scale(duration: 200.ms, begin: const Offset(1, 1), end: const Offset(1.05, 1.05), curve: Curves.easeOutBack)
                     .then()
                     .scale(duration: 200.ms, end: const Offset(1, 1)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate(target: _isAccepting ? 1 : 0)
       .fadeOut(duration: 300.ms, delay: 400.ms)
       .scale(end: const Offset(0.9, 0.9), duration: 300.ms, delay: 400.ms),
    );
  }

  (String, Color, Color) _resolveBadge(OrderStatus status) =>
      switch (status) {
        OrderStatus.pending => ('جديد', const Color(0xFFE3F2FD), const Color(0xFF1565C0)),
        _ => (status.label, const Color(0xFFE8F5E9), AppColors.primaryGreen),
      };
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
