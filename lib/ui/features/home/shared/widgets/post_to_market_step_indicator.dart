import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PostMarketStepIndicator extends StatelessWidget {
  final int currentStep;
  const PostMarketStepIndicator({super.key, required this.currentStep});

  static const _labels = ['الصور', 'التفاصيل', 'الموقع'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: List.generate(3, (i) {
          final done = i < currentStep;
          final active = i == currentStep;
          return Expanded(
            child: Row(
              children: [
                _StepDot(index: i, done: done, active: active,
                    label: _labels[i]),
                if (i < 2)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: done
                          ? const Color(0xFF065F46)
                          : const Color(0xFFE5E7EB),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  final int index;
  final bool done;
  final bool active;
  final String label;
  const _StepDot(
      {required this.index,
      required this.done,
      required this.active,
      required this.label});

  @override
  Widget build(BuildContext context) {
    final Color bg = done
        ? const Color(0xFF065F46)
        : active
            ? const Color(0xFF1E40AF)
            : const Color(0xFFE5E7EB);
    final Color fg = (done || active) ? Colors.white : const Color(0xFF9CA3AF);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 28,
          height: 28,
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
          child: Center(
            child: done
                ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                : Text('${index + 1}',
                    style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: fg)),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 10,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
            color: active
                ? const Color(0xFF1E40AF)
                : done
                    ? const Color(0xFF065F46)
                    : const Color(0xFF9CA3AF),
          ),
        ),
      ],
    );
  }
}
