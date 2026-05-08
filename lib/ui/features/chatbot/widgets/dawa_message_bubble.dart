import 'dart:io';
import 'package:flutter/material.dart';
import '../dawa_chat_view_model.dart' show DawaMessage;
import 'dawa_chat_constants.dart';

/// A single message bubble (user or bot) plus optional follow-up chips.
class DawaMessageBubble extends StatelessWidget {
  final DawaMessage message;
  final ThemeData theme;
  final ValueChanged<String> onFollowUpTap;

  const DawaMessageBubble({
    super.key,
    required this.message,
    required this.theme,
    required this.onFollowUpTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          if (message.mlSource != null && !isUser) const _ScanBadge(),
          _BubbleBody(message: message, theme: theme, isUser: isUser),
          if (!isUser && message.followUps.isNotEmpty)
            _FollowUpChips(
              followUps: message.followUps,
              onTap: onFollowUpTap,
            ),
        ],
      ),
    );
  }
}

class _ScanBadge extends StatelessWidget {
  const _ScanBadge();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: kDawaScanBadgeBg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Text(
          '📸 نتيجة تحليل الصورة',
          style: TextStyle(
            fontSize: 11,
            color: kDawaScanBadgeFg,
            fontFamily: 'Cairo',
          ),
        ),
      ),
    );
  }
}

class _BubbleBody extends StatelessWidget {
  final DawaMessage message;
  final ThemeData theme;
  final bool isUser;
  const _BubbleBody({
    required this.message,
    required this.theme,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) {
    final bubbleColor = isUser
        ? kDawaPrimaryGreen
        : theme.colorScheme.surfaceContainerHighest;
    final textColor = isUser
        ? Colors.white
        : (theme.textTheme.bodyMedium?.color ?? theme.colorScheme.onSurface);

    return Align(
      alignment: isUser ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 4 : 16),
            bottomRight: Radius.circular(isUser ? 16 : 4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (message.imagePath != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    File(message.imagePath!),
                    height: 160,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            Text(
              message.text,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                color: textColor,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FollowUpChips extends StatelessWidget {
  final List<dynamic> followUps; // List<DawaEntry>; kept dynamic to avoid extra import.
  final ValueChanged<String> onTap;
  const _FollowUpChips({required this.followUps, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        alignment: WrapAlignment.end,
        children: followUps.map<Widget>((entry) {
          final label = (entry.response as String).split('\n').first;
          final short =
              label.length > 30 ? '${label.substring(0, 28)}…' : label;
          return GestureDetector(
            onTap: () => onTap(entry.id as String),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: kDawaPrimaryGreen.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: kDawaPrimaryGreen.withValues(alpha: 0.35),
                ),
              ),
              child: Text(
                short,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: kDawaPrimaryGreen,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
