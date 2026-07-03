import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/date_formatter.dart';
import '../../../../../data/models/order/order.dart';
import '../../../../../l10n/l10n.dart';
import '../../../../../ui/core/components/dwaar_detail_card.dart';

class OrderStatusTimeline extends StatelessWidget {
  final Order order;

  const OrderStatusTimeline({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final steps = [
      (OrderStatus.pending, l10n.orderStatusStepPending, order.createdAt),
      (OrderStatus.accepted, l10n.orderStatusStepAccepted, order.acceptedAt),
      (
        OrderStatus.arrivedAtPickup,
        l10n.orderStatusStepArrivedAtPickup,
        order.arrivedAtPickupAt,
      ),
      (OrderStatus.inTransit, l10n.orderStatusStepInTransit, order.inTransitAt),
      (
        OrderStatus.arrivedAtDropoff,
        l10n.orderStatusStepArrivedAtDropoff,
        order.arrivedAtDropoffAt,
      ),
      (OrderStatus.completed, l10n.orderStatusStepCompleted, order.completedAt),
    ];

    // Map intermediate arrival statuses to their position in the steps list.
    int currentIndex = steps.indexWhere((s) => s.$1 == order.status);
    if (currentIndex == -1) {
      // Cancelled or unknown — treat as the last known completed step.
      currentIndex = steps.length - 1;
    }

    return DwaarDetailCard(
      elevation: DwaarCardElevation.raised,
      margin: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      animationIndex: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DwaarDetailHeader(
            icon: LucideIcons.route,
            title: l10n.orderStatusTitle,
            iconColor: AppColors.primaryGreen,
          ),
          const DwaarDetailDivider(verticalPadding: 10),
          const SizedBox(height: 4),
          Row(
            children: List.generate(steps.length * 2 - 1, (i) {
              if (i.isOdd) {
                final filled = (i ~/ 2) < currentIndex;
                return Expanded(child: _AnimatedConnector(filled: filled));
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

// ── Animated Gradient Connector ───────────────────────────────────────────────

class _AnimatedConnector extends StatelessWidget {
  final bool filled;

  const _AnimatedConnector({required this.filled});

  @override
  Widget build(BuildContext context) {
    if (!filled) {
      return Container(
        height: 2.5,
        decoration: BoxDecoration(
          color: const Color(0xFFE0E6E1),
          borderRadius: BorderRadius.circular(2),
        ),
      );
    }

    return Container(
          height: 2.5,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            gradient: const LinearGradient(
              colors: [AppColors.ctaGradientStart, AppColors.ctaGradientEnd],
            ),
          ),
        )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .shimmer(
          duration: 2000.ms,
          color: AppColors.headerGradientEnd.withValues(alpha: 0.4),
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
    final dotSize = 32.0;

    Widget dot = Container(
      width: dotSize,
      height: dotSize,
      decoration: BoxDecoration(
        color: done || active
            ? AppColors.primaryGreen
            : const Color(0xFFE0E6E1),
        shape: BoxShape.circle,
        boxShadow: active
            ? [
                BoxShadow(
                  color: AppColors.primaryGreen.withValues(alpha: 0.25),
                  blurRadius: 12,
                  spreadRadius: 2,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Icon(
        done ? LucideIcons.check : Icons.circle,
        size: done ? 16 : 8,
        color: Colors.white,
      ),
    );

    // Ring effect for current step
    if (active) {
      dot =
          Container(
                width: dotSize + 8,
                height: dotSize + 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primaryGreen.withValues(alpha: 0.2),
                    width: 3,
                  ),
                ),
                child: Center(child: dot),
              )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scaleXY(
                begin: 0.95,
                end: 1.05,
                duration: 1200.ms,
                curve: Curves.easeInOut,
              );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        dot,
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 10,
            fontWeight: active ? FontWeight.bold : FontWeight.w500,
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
              fontWeight: active ? FontWeight.bold : FontWeight.w500,
              color: const Color(0xFF9099A2),
            ),
          ),
      ],
    );
  }
}
