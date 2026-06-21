import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dwaar/core/constants/app_colors.dart';
import 'package:dwaar/data/models/order/order.dart';

class OrderProgressStepper extends StatelessWidget {
  final OrderStatus status;

  const OrderProgressStepper({
    super.key,
    required this.status,
  });

  int get _currentStep => switch (status) {
        OrderStatus.pending => 0,
        OrderStatus.accepted => 1,
        OrderStatus.arrivedAtPickup => 2,
        OrderStatus.inTransit => 3,
        OrderStatus.arrivedAtDropoff || OrderStatus.completed => 4,
        _ => 0,
      };

  static const _steps = [
    'قيد الانتظار',
    'تم القبول',
    'وصل للاستلام',
    'في الطريق',
    'تم التسليم'
  ];

  @override
  Widget build(BuildContext context) {
    if (status == OrderStatus.cancelled) {
      return const SizedBox.shrink();
    }

    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Row(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      children: List.generate(_steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          final connectorStep = i ~/ 2;
          final done = connectorStep < _currentStep;
          return Expanded(
            child: Container(
              height: 2,
              color: done ? AppColors.primaryGreen : AppColors.borderSubtle,
            ),
          );
        }

        final step = i ~/ 2;
        final done = step <= _currentStep;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: done ? AppColors.primaryGreen : AppColors.background,
                shape: BoxShape.circle,
                border: Border.all(
                  color: done ? AppColors.primaryGreen : AppColors.borderSubtle,
                  width: 1.5,
                ),
              ),
              child: done
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
            const SizedBox(height: 4),
            Text(
              _steps[step],
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 8,
                fontWeight: done ? FontWeight.bold : FontWeight.normal,
                color: done ? AppColors.primaryGreen : AppColors.mutedText,
                height: 1.2,
              ),
            ),
          ],
        );
      }),
    );
  }
}
