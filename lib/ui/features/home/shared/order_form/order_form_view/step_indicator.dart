part of '../order_form_view.dart';

class _StepDotsIndicator extends StatelessWidget {
  final int currentStep;
  static const int _total = 3;

  const _StepDotsIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(_total * 2 - 1, (i) {
        if (i.isOdd) return _connector(i ~/ 2);
        final step = i ~/ 2;
        return _dot(step);
      }),
    );
  }

  Widget _dot(int step) {
    final isDone = step < currentStep;
    final isActive = step == currentStep;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      width: isActive ? 18 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFF06402B)
            : isDone
                ? const Color(0xFF06402B).withValues(alpha: 0.4)
                : const Color(0xFFE6E9E7),
        borderRadius: BorderRadius.circular(4),
      ),
      child: isDone
          ? const Icon(Icons.check_rounded, size: 7, color: Colors.white)
          : null,
    );
  }

  Widget _connector(int beforeStep) {
    final isPast = beforeStep < currentStep - 1;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: 10,
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        color: isPast
            ? const Color(0xFF06402B).withValues(alpha: 0.4)
            : const Color(0xFFE6E9E7),
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }
}
