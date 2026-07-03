import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../domain/chat/entities/chat_message.dart';

// ── ChatBubble ────────────────────────────────────────────────────────────────
//
// Renders a single message, branching on [ChatMessage.kind].
// BiDi-aware: Arabic script → RTL text direction; Latin → LTR.

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMine;

  /// True while the message is an optimistic local insert awaiting server confirmation.
  final bool isSending;

  /// True if the send attempt failed — shows a retry button.
  final bool isFailed;

  /// Called when the user taps the retry button on a failed message.
  final VoidCallback? onRetry;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isMine,
    this.isSending = false,
    this.isFailed = false,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    // System messages (order state events) render centered — no bubble.
    if (message.kind == ChatMessageKind.system) {
      return _SystemMessage(content: message.content);
    }

    return Align(
      alignment: isMine ? Alignment.centerLeft : Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
          decoration: BoxDecoration(
            color: isMine ? AppColors.primaryGreen : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(isMine ? 4 : 18),
              bottomRight: Radius.circular(isMine ? 18 : 4),
            ),
          ),
          child: switch (message.kind) {
            ChatMessageKind.image => _ImageBubbleBody(
              message: message,
              isMine: isMine,
              isSending: isSending,
              isFailed: isFailed,
              onRetry: onRetry,
            ),
            ChatMessageKind.location => _LocationBubbleBody(
              message: message,
              isMine: isMine,
              isSending: isSending,
              isFailed: isFailed,
              onRetry: onRetry,
            ),
            _ => _TextBubbleBody(
              message: message,
              isMine: isMine,
              isSending: isSending,
              isFailed: isFailed,
              onRetry: onRetry,
            ),
          },
        ),
      ),
    );
  }
}

// ── Text bubble ───────────────────────────────────────────────────────────────

class _TextBubbleBody extends StatelessWidget {
  final ChatMessage message;
  final bool isMine;
  final bool isSending;
  final bool isFailed;
  final VoidCallback? onRetry;
  const _TextBubbleBody({
    required this.message,
    required this.isMine,
    this.isSending = false,
    this.isFailed = false,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final dir = _detectDirection(message.content);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isMine) _SenderLabel(message: message),
          Text(
            message.content,
            textDirection: dir,
            textAlign: dir == TextDirection.rtl
                ? TextAlign.right
                : TextAlign.left,
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: isMine ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          _Timestamp(
            message: message,
            isMine: isMine,
            isSending: isSending,
            isFailed: isFailed,
            onRetry: onRetry,
          ),
        ],
      ),
    );
  }
}

// ── Image bubble ──────────────────────────────────────────────────────────────

class _ImageBubbleBody extends StatelessWidget {
  final ChatMessage message;
  final bool isMine;
  final bool isSending;
  final bool isFailed;
  final VoidCallback? onRetry;
  const _ImageBubbleBody({
    required this.message,
    required this.isMine,
    this.isSending = false,
    this.isFailed = false,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final url = message.attachmentUrl;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Image thumbnail
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
          child: url != null
              ? CachedNetworkImage(
                  imageUrl: url,
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => _ImagePlaceholder(),
                  errorWidget: (_, __, ___) => _ImagePlaceholder(),
                )
              : _ImagePlaceholder(),
        ),
        // Caption + timestamp
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isMine) _SenderLabel(message: message),
              if (message.content.isNotEmpty) ...[
                Text(
                  message.content,
                  textDirection: _detectDirection(message.content),
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    color: isMine ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
              ],
              _Timestamp(
                message: message,
                isMine: isMine,
                isSending: isSending,
                isFailed: isFailed,
                onRetry: onRetry,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 180,
      color: Colors.black12,
      child: const Icon(Icons.image_rounded, size: 40, color: Colors.white54),
    );
  }
}

// ── Location bubble ───────────────────────────────────────────────────────────

class _LocationBubbleBody extends StatelessWidget {
  final ChatMessage message;
  final bool isMine;
  final bool isSending;
  final bool isFailed;
  final VoidCallback? onRetry;
  const _LocationBubbleBody({
    required this.message,
    required this.isMine,
    this.isSending = false,
    this.isFailed = false,
    this.onRetry,
  });

  Future<void> _openMaps() async {
    final lat = message.lat;
    final lng = message.lng;
    if (lat == null || lng == null) return;
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor = isMine ? Colors.white : const Color(0xFF1E293B);
    final subColor = isMine ? Colors.white70 : AppColors.mutedText;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isMine) _SenderLabel(message: message),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.location_on_rounded,
                size: 18,
                color: isMine ? Colors.white70 : AppColors.primaryGreen,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  message.content.isNotEmpty ? message.content : 'موقع مشارك',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
          if (message.lat != null && message.lng != null) ...[
            const SizedBox(height: 4),
            Text(
              '${message.lat!.toStringAsFixed(4)}, ${message.lng!.toStringAsFixed(4)}',
              style: GoogleFonts.dmSans(fontSize: 10, color: subColor),
            ),
          ],
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _openMaps,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isMine
                    ? Colors.white.withValues(alpha: 0.2)
                    : AppColors.primaryGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.open_in_new_rounded,
                    size: 12,
                    color: isMine ? Colors.white : AppColors.primaryGreen,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'افتح في الخريطة',
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isMine ? Colors.white : AppColors.primaryGreen,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          _Timestamp(
            message: message,
            isMine: isMine,
            isSending: isSending,
            isFailed: isFailed,
            onRetry: onRetry,
          ),
        ],
      ),
    );
  }
}

// ── System message ─────────────────────────────────────────────────────────────

class _SystemMessage extends StatelessWidget {
  final String content;
  const _SystemMessage({required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.mutedText.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            content,
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(fontSize: 11, color: AppColors.mutedText),
          ),
        ),
      ),
    );
  }
}

// ── Shared sub-widgets ────────────────────────────────────────────────────────

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
  final bool isSending;
  final bool isFailed;
  final VoidCallback? onRetry;

  const _Timestamp({
    required this.message,
    required this.isMine,
    this.isSending = false,
    this.isFailed = false,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    // Failed state — show error + retry button
    if (isFailed) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onRetry != null)
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red.shade700,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'إعادة',
                  style: GoogleFonts.cairo(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          const SizedBox(width: 4),
          const Icon(
            Icons.error_outline_rounded,
            size: 13,
            color: Colors.redAccent,
          ),
        ],
      );
    }

    final h = message.sentAt.hour.toString().padLeft(2, '0');
    final m = message.sentAt.minute.toString().padLeft(2, '0');

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isMine) ...[
          // Sending → clock; sent but unread → single tick; read → double tick
          Icon(
            isSending
                ? Icons.access_time_rounded
                : message.isRead
                ? Icons.done_all_rounded
                : Icons.done_rounded,
            size: 13,
            color: isSending
                ? Colors.white.withValues(alpha: 0.4)
                : message.isRead
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

// ── Helpers ───────────────────────────────────────────────────────────────────

/// Returns RTL if the string's first meaningful characters are Arabic script,
/// otherwise LTR. Handles expat drivers typing English in an Arabic thread.
TextDirection _detectDirection(String text) {
  for (final rune in text.runes) {
    if (rune >= 0x0600 && rune <= 0x06FF) return TextDirection.rtl; // Arabic
    if (rune >= 0x0041 && rune <= 0x007A) return TextDirection.ltr; // Latin
  }
  return TextDirection.rtl; // default for Jordanian context
}
