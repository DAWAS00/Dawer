import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/utils/date_formatter.dart';
import '../../../../../data/models/order.dart';
import '../../../../../l10n/l10n.dart';

class OrderStatusTimeline extends StatelessWidget {
  final Order order;

  const OrderStatusTimeline({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final steps = [
      (OrderStatus.pending, l10n.orderStatusStepPending, order.createdAt),
      (OrderStatus.accepted, l10n.orderStatusStepAccepted, order.acceptedAt),
      (OrderStatus.arrivedAtPickup, l10n.orderStatusStepArrivedAtPickup, order.arrivedAtPickupAt),
      (OrderStatus.inTransit, l10n.orderStatusStepInTransit, order.inTransitAt),
      (OrderStatus.arrivedAtDropoff, l10n.orderStatusStepArrivedAtDropoff, order.arrivedAtDropoffAt),
      (OrderStatus.completed, l10n.orderStatusStepCompleted, order.completedAt),
    ];

    // Map intermediate arrival statuses to their position in the steps list.
    int currentIndex = steps.indexWhere((s) => s.$1 == order.status);
    if (currentIndex == -1) {
      // Cancelled or unknown — treat as the last known completed step.
      currentIndex = steps.length - 1;
    }

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
            l10n.orderStatusTitle,
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
                timestamp: steps[stepIdx].$3,
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
  final DateTime? timestamp;
  final bool active;
  final bool done;

  const _TimelineStep({
    required this.label,
    required this.active,
    required this.done,
    this.timestamp,
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
        if (timestamp != null && (done || active))
          Text(
            DateFormatter.time(timestamp!),
            style: GoogleFonts.dmSans(
              fontSize: 9,
              color: const Color(0xFF9099A2),
            ),
          ),
      ],
    );
  }
}
