import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dwaar/core/constants/app_colors.dart';
import 'package:dwaar/data/models/order/order.dart';

/// Horizontal 5-step tracker for an order's lifecycle.
///
/// Three node states make "where is my order now" obvious at a glance:
/// - **completed** — solid green node with a check
/// - **current**   — green node wrapped in a soft halo ring ("you are here")
/// - **upcoming**  — hollow grey node
///
/// Backward compatible: same `OrderProgressStepper(status:)` API used by the
/// driver active card, shared order card and supplier/restaurant order card.
class OrderProgressStepper extends StatelessWidget {
  final OrderStatus status;

  const OrderProgressStepper({super.key, required this.status});

  int get _currentStep => switch (status) {
    OrderStatus.pending => 0,
    OrderStatus.accepted => 1,
    OrderStatus.arrivedAtPickup => 2,
    OrderStatus.inTransit => 3,
    OrderStatus.arrivedAtDropoff || OrderStatus.completed => 4,
    _ => 0,
  };

  /// True once the order has fully finished — the last node renders as a
  /// completed check rather than a "current" halo.
  bool get _isDone => status == OrderStatus.completed;

  static const _steps = [
    'قيد الانتظار',
    'تم القبول',
    'وصل للاستلام',
    'في الطريق',
    'تم التسليم',
  ];

  @override
  Widget build(BuildContext context) {
    if (status == OrderStatus.cancelled) {
      return const SizedBox.shrink();
    }

    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Row(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(_steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          final connectorStep = i ~/ 2;
          final done = connectorStep < _currentStep;
          return Expanded(
            child: Container(
              height: 2.5,
              margin: const EdgeInsets.only(top: 13),
              color: done ? AppColors.primaryGreen : AppColors.borderSubtle,
            ),
          );
        }

        final step = i ~/ 2;
        final isCompleted =
            step < _currentStep || (step == _currentStep && _isDone);
        final isCurrent = step == _currentStep && !_isDone;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StepNode(isCompleted: isCompleted, isCurrent: isCurrent),
            const SizedBox(height: 5),
            SizedBox(
              width: 52,
              child: Text(
                _steps[step],
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: 9,
                  fontWeight: (isCompleted || isCurrent)
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: (isCompleted || isCurrent)
                      ? AppColors.primaryGreen
                      : AppColors.mutedText,
                  height: 1.2,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _StepNode extends StatelessWidget {
  const _StepNode({required this.isCompleted, required this.isCurrent});

  final bool isCompleted;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    // Current step: green dot inside a soft halo ring to read as "you are here".
    if (isCurrent) {
      return Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.primaryGreen.withValues(alpha: 0.18),
          shape: BoxShape.circle,
        ),
        child: Container(
          width: 16,
          height: 16,
          decoration: const BoxDecoration(
            color: AppColors.primaryGreen,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.circle, size: 7, color: Colors.white),
        ),
      );
    }

    // Completed step: solid green node with a check.
    if (isCompleted) {
      return Container(
        width: 26,
        height: 26,
        decoration: const BoxDecoration(
          color: AppColors.primaryGreen,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check, size: 13, color: Colors.white),
      );
    }

    // Upcoming step: hollow grey node.
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: AppColors.background,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.borderSubtle, width: 1.5),
      ),
    );
  }
}
