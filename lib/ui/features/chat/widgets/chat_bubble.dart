import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../domain/chat/entities/chat_message.dart';

// ── ChatBubble ────────────────────────────────────────────────────────────────
//
// Renders a single message. [isMine] controls alignment and color.
// RTL-aware: mine → left side (visually right in RTL), other → right side.

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMine;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isMine,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMine ? Alignment.centerLeft : Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isMine
                ? AppColors.primaryGreen
                : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(isMine ? 4 : 18),
              bottomRight: Radius.circular(isMine ? 18 : 4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isMine) _SenderLabel(message: message),
              Text(
                message.content,
                textAlign: TextAlign.right,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: isMine ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 4),
              _Timestamp(message: message, isMine: isMine),
            ],
          ),
        ),
      ),
    );
  }
}

class _SenderLabel extends StatelessWidget {
  final ChatMessage message;
  const _SenderLabel({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        message.senderName,
        style: GoogleFonts.cairo(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryGreen,
        ),
      ),
    );
  }
}

class _Timestamp extends StatelessWidget {
  final ChatMessage message;
  final bool isMine;
  const _Timestamp({required this.message, required this.isMine});

  @override
  Widget build(BuildContext context) {
    final h = message.sentAt.hour.toString().padLeft(2, '0');
    final m = message.sentAt.minute.toString().padLeft(2, '0');
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isMine) ...[
          Icon(
            message.isRead ? Icons.done_all_rounded : Icons.done_rounded,
            size: 13,
            color: message.isRead
                ? Colors.white70
                : Colors.white.withValues(alpha: 0.5),
          ),
          const SizedBox(width: 4),
        ],
        Text(
          '$h:$m',
          style: GoogleFonts.dmSans(
            fontSize: 10,
            color: isMine
                ? Colors.white.withValues(alpha: 0.7)
                : AppColors.mutedText,
          ),
        ),
      ],
    );
  }
}
