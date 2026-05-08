import 'package:flutter/material.dart';
import 'dawa_chat_constants.dart';

/// Inline "analyzing image..." spinner shown above the input bar while
/// the chatbot is running ML Kit on a picked image.
class DawaScanningIndicator extends StatelessWidget {
  final ThemeData theme;
  const DawaScanningIndicator({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: kDawaPrimaryGreen,
                ),
              ),
              SizedBox(width: 8),
              Text(
                'جاري تحليل الصورة...',
                style: TextStyle(fontFamily: 'Cairo', fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
