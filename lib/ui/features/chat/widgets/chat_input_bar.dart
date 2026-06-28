import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/l10n.dart';

// ── ChatInputBar ──────────────────────────────────────────────────────────────
//
// Text field + send button + attach button fixed at the bottom of ChatView.
// Attach button opens a bottom sheet with Photo / Location options.

class ChatInputBar extends StatefulWidget {
  final ValueChanged<String> onSend;

  /// Called whenever the text field content changes (for typing indicator broadcast).
  final VoidCallback? onTyping;

  /// Opens system image picker and sends the chosen image.
  /// Null = image attachment not wired (hides the option).
  final Future<String?> Function()? onPickImage;

  /// Gets GPS position and sends it as a location message.
  /// Null = location sharing not wired (hides the option).
  final Future<String?> Function()? onShareLocation;

  /// When true, location is being fetched — spinner replaces the pin icon.
  final bool isSendingLocation;

  final List<String>? quickReplies;

  const ChatInputBar({
    super.key,
    required this.onSend,
    this.onTyping,
    this.onPickImage,
    this.onShareLocation,
    this.isSendingLocation = false,
    this.quickReplies,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final _ctrl = TextEditingController();
  bool _hasText = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_ctrl.text.trim().isEmpty) return;
    widget.onSend(_ctrl.text);
    _ctrl.clear();
    setState(() => _hasText = false);
  }

  void _openAttachSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'إرفاق',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 16),
              if (widget.onPickImage != null)
                _AttachOption(
                  icon: Icons.image_rounded,
                  label: 'صورة من المعرض',
                  color: const Color(0xFF3B82F6),
                  onTap: () async {
                    Navigator.of(sheetCtx).pop();
                    final err = await widget.onPickImage!();
                    if (err != null && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(err, style: GoogleFonts.cairo())),
                      );
                    }
                  },
                ),
              if (widget.onShareLocation != null) ...[
                const SizedBox(height: 8),
                _AttachOption(
                  icon: Icons.location_on_rounded,
                  label: 'موقعك الحالي',
                  color: const Color(0xFF10B981),
                  onTap: () async {
                    Navigator.of(sheetCtx).pop();
                    final err = await widget.onShareLocation!();
                    if (err != null && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(err, style: GoogleFonts.cairo())),
                      );
                    }
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final showAttach =
        widget.onPickImage != null || widget.onShareLocation != null;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Quick reply chips
            if (widget.quickReplies != null &&
                widget.quickReplies!.isNotEmpty) ...[
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(bottom: 8),
                reverse: true,
                child: Row(
                  children: widget.quickReplies!.map((script) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ActionChip(
                        label: Text(
                          script,
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                        backgroundColor:
                            AppColors.primaryGreen.withValues(alpha: 0.08),
                        side: BorderSide(
                            color:
                                AppColors.primaryGreen.withValues(alpha: 0.2)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 0),
                        onPressed: () => widget.onSend(script),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
            Row(
              children: [
                // Send button — left (leading in RTL)
                AnimatedOpacity(
                  opacity: _hasText ? 1.0 : 0.4,
                  duration: const Duration(milliseconds: 150),
                  child: GestureDetector(
                    onTap: _hasText ? _submit : null,
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Input field
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    maxLines: 4,
                    minLines: 1,
                    onChanged: (v) {
                      setState(() => _hasText = v.trim().isNotEmpty);
                      if (v.trim().isNotEmpty) widget.onTyping?.call();
                    },
                    onSubmitted: (_) => _submit(),
                    style: GoogleFonts.cairo(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: context.l10n.chatInputHint,
                      hintStyle: GoogleFonts.cairo(
                        fontSize: 14,
                        color: AppColors.mutedText,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide:
                            BorderSide(color: Colors.grey.shade200),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide:
                            BorderSide(color: Colors.grey.shade200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide:
                            const BorderSide(color: AppColors.primaryGreen),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      isDense: true,
                    ),
                  ),
                ),
                // Attach button — right side (trailing in RTL)
                if (showAttach) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: widget.isSendingLocation ? null : _openAttachSheet,
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: widget.isSendingLocation
                          ? const Padding(
                              padding: EdgeInsets.all(11),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primaryGreen,
                              ),
                            )
                          : const Icon(
                              Icons.attach_file_rounded,
                              color: Color(0xFF64748B),
                              size: 20,
                            ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Attach option row ─────────────────────────────────────────────────────────

class _AttachOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AttachOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(width: 14),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
        ],
      ),
    );
  }
}
