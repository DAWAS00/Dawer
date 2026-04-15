import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dawa_chat_view_model.dart';

/// Entry-point widget for the Dawa support chat.
///
/// Wraps [_DawaChatBody] in a [ChangeNotifierProvider] so it owns its own VM.
/// Drop this into any bottom sheet, scaffold, or full screen:
///
/// ```dart
/// showModalBottomSheet(
///   context: context,
///   isScrollControlled: true,
///   builder: (_) => const DawaChatWidget(),
/// );
/// ```
class DawaChatWidget extends StatelessWidget {
  const DawaChatWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DawaChatViewModel(),
      child: const _DawaChatBody(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Body (stateful — owns scroll + text controllers)
// ─────────────────────────────────────────────────────────────────

class _DawaChatBody extends StatefulWidget {
  const _DawaChatBody();

  @override
  State<_DawaChatBody> createState() => _DawaChatBodyState();
}

class _DawaChatBodyState extends State<_DawaChatBody> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send(DawaChatViewModel vm) {
    final text = _controller.text;
    if (text.trim().isEmpty) return;
    _controller.clear();
    vm.handleUserMessage(text);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DawaChatViewModel>();
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            _DawaChatHeader(theme: theme),

            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: vm.messages.length,
                itemBuilder: (context, index) {
                  final msg = vm.messages[index];
                  return _MessageBubble(
                    message: msg,
                    theme: theme,
                    onFollowUpTap: (id) {
                      vm.handleFollowUpTap(id);
                      _scrollToBottom();
                    },
                  );
                },
              ),
            ),

            _InputBar(
              controller: _controller,
              theme: theme,
              onSend: () => _send(vm),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Header — drag handle + Dawer branding
// ─────────────────────────────────────────────────────────────────

class _DawaChatHeader extends StatelessWidget {
  final ThemeData theme;
  const _DawaChatHeader({required this.theme});

  @override
  Widget build(BuildContext context) {
    // Dawer primary green
    const primaryGreen = Color(0xFF1E5C35);

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
          // Drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: theme.dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title row — leaf icon + label
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.eco_rounded, color: primaryGreen, size: 20),
              const SizedBox(width: 6),
              Text(
                'مساعد دوّر الذكي',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: primaryGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Message bubble + follow-up chips
// ─────────────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  final DawaMessage message;
  final ThemeData theme;
  final ValueChanged<String> onFollowUpTap;

  const _MessageBubble({
    required this.message,
    required this.theme,
    required this.onFollowUpTap,
  });

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF1E5C35);
    final isUser = message.isUser;

    final bubbleColor = isUser
        ? primaryGreen
        : theme.colorScheme.surfaceContainerHighest;
    final textColor = isUser
        ? Colors.white
        : (theme.textTheme.bodyMedium?.color ?? theme.colorScheme.onSurface);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          // ML Kit source badge (shown when triggered by image scan)
          if (message.mlSource != null && !isUser)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  '📸 نتيجة تحليل الصورة',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFFC8860A),
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
            ),

          // Bubble
          Align(
            alignment:
                isUser ? Alignment.centerLeft : Alignment.centerRight,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.78,
              ),
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 4 : 16),
                  bottomRight: Radius.circular(isUser ? 16 : 4),
                ),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  color: textColor,
                  height: 1.6,
                ),
              ),
            ),
          ),

          // Follow-up chips (bot messages only)
          if (!isUser && message.followUps.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                alignment: WrapAlignment.end,
                children: message.followUps.map((entry) {
                  final label = entry.response.split('\n').first;
                  final short = label.length > 30
                      ? '${label.substring(0, 28)}…'
                      : label;
                  return GestureDetector(
                    onTap: () => onFollowUpTap(entry.id),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: primaryGreen.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: primaryGreen.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Text(
                        short,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: primaryGreen,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Input bar
// ─────────────────────────────────────────────────────────────────

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final ThemeData theme;
  final VoidCallback onSend;

  const _InputBar({
    required this.controller,
    required this.theme,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF1E5C35);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(color: theme.dividerColor, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                textDirection: TextDirection.rtl,
                decoration: InputDecoration(
                  hintText: 'اكتب سؤالك هنا...',
                  hintStyle: TextStyle(
                    fontFamily: 'Cairo',
                    color: theme.hintColor,
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
                onSubmitted: (_) => onSend(),
                textInputAction: TextInputAction.send,
              ),
            ),
            const SizedBox(width: 8),
            Material(
              color: primaryGreen,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: onSend,
                customBorder: const CircleBorder(),
                child: const Padding(
                  padding: EdgeInsets.all(10),
                  child: Icon(Icons.send_rounded,
                      color: Colors.white, size: 22),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
