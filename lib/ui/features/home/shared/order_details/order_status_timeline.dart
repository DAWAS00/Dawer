import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../data/models/order.dart';

class OrderStatusTimeline extends StatelessWidget {
  final OrderStatus status;

  const OrderStatusTimeline({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final steps = [
      (OrderStatus.pending, 'انتظار'),
      (OrderStatus.accepted, 'قُبل'),
      (OrderStatus.inTransit, 'في الطريق'),
      (OrderStatus.completed, 'مكتمل'),
    ];

    final currentIndex = steps.indexWhere((s) => s.$1 == status);

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'حالة الطلب',
            style: GoogleFonts.cairo(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF002819),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: List.generate(steps.length * 2 - 1, (i) {
              if (i.isOdd) {
                final filled = (i ~/ 2) < currentIndex;
                return Expanded(
                  child: Container(
                    height: 3,
                    color: filled
                        ? const Color(0xFF06402B)
                        : const Color(0xFFE0E6E1),
                  ),
                );
              }
              final stepIdx = i ~/ 2;
              return _TimelineStep(
                label: steps[stepIdx].$2,
                active: stepIdx == currentIndex,
                done: stepIdx < currentIndex,
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ── Timeline Step ─────────────────────────────────────────────────────────────

class _TimelineStep extends StatelessWidget {
  final String label;
  final bool active;
  final bool done;

  const _TimelineStep({
    required this.label,
    required this.active,
    required this.done,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: done || active
                ? const Color(0xFF06402B)
                : const Color(0xFFE0E6E1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            done ? Icons.check_rounded : Icons.circle,
            size: done ? 16 : 8,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 10,
            fontWeight: active ? FontWeight.bold : FontWeight.w400,
            color: active || done
                ? const Color(0xFF002819)
                : const Color(0xFF9099A2),
          ),
        ),
      ],
    );
  }
}
