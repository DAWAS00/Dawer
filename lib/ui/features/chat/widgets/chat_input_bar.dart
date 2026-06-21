import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/l10n.dart';

// ── ChatInputBar ──────────────────────────────────────────────────────────────
//
// Text field + send button fixed at the bottom of ChatView.
// [onSend] is called with the trimmed text; the bar clears itself.

class ChatInputBar extends StatefulWidget {
  final ValueChanged<String> onSend;
  final List<String>? quickReplies;

  const ChatInputBar({
    super.key,
    required this.onSend,
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Quick reply scripts
            if (widget.quickReplies != null && widget.quickReplies!.isNotEmpty) ...[
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(bottom: 8),
                reverse: true, // RTL context
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
                        backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.08),
                        side: BorderSide(color: AppColors.primaryGreen.withValues(alpha: 0.2)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                        onPressed: () => widget.onSend(script),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
            Row(
              children: [
                // Send button — left side (visually leading in RTL)
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
                    onChanged: (v) => setState(() => _hasText = v.trim().isNotEmpty),
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
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide:
                            const BorderSide(color: AppColors.primaryGreen),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
