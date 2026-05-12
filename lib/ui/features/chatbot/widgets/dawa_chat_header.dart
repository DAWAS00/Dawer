import 'package:flutter/material.dart';
import 'dawa_chat_constants.dart';

/// Drag-handle + branding header shown at the top of the Dawa chat sheet.
class DawaChatHeader extends StatelessWidget {
  final ThemeData theme;
  const DawaChatHeader({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(color: theme.dividerColor, width: 1),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: theme.dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.eco_rounded,
                color: kDawaPrimaryGreen,
                size: 20,
              ),
              const SizedBox(width: 6),
              Text(
                'مساعد دوّر الذكي',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: kDawaPrimaryGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
