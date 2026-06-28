import 'package:flutter/material.dart';

class CommonWizardProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const CommonWizardProgressBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: List.generate(totalSteps, (i) {
          final isDone = i < currentStep;
          final isActive = i == currentStep;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: i < totalSteps - 1 ? 6 : 0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: isDone
                      ? const Color(0xFF059669)
                      : isActive
                          ? const Color(0xFF06402B)
                          : const Color(0xFFE5E7EB),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
