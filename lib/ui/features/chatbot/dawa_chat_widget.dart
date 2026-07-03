import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:dwaar/core/constants/app_colors.dart';
import 'package:dwaar/l10n/l10n.dart';
import 'dawa_chat_view_model.dart';
import 'dawa_chatbot_service.dart' show DawaEntry;
import 'widgets/waste_analysis_result_card.dart';

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
  DawaChatViewModel? _vm;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe once to auto-scroll whenever a new message or state arrives.
    final vm = context.read<DawaChatViewModel>();
    if (_vm != vm) {
      _vm?.removeListener(_onVmChanged);
      _vm = vm;
      _vm!.addListener(_onVmChanged);
    }
  }

  void _onVmChanged() {
    _scrollToBottom();
  }

  @override
  void dispose() {
    _vm?.removeListener(_onVmChanged);
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send(DawaChatViewModel vm) {
    final text = _controller.text;
    if (text.trim().isEmpty) return;
    _controller.clear();
    vm.handleUserMessage(text);
  }

  void _showImagePicker(DawaChatViewModel vm) {
    final l10n = context.l10n;
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(
                Icons.camera_alt_rounded,
                color: AppColors.primaryGreen,
              ),
              title: Text(
                l10n.chatbotTakePhoto,
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
              onTap: () {
                Navigator.pop(context);
                vm.handleImagePick(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library_rounded,
                color: AppColors.primaryGreen,
              ),
              title: Text(
                l10n.chatbotPickFromGallery,
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
              onTap: () {
                Navigator.pop(context);
                vm.handleImagePick(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                itemCount: vm.messages.length,
                itemBuilder: (context, index) {
                  final msg = vm.messages[index];
                  return _MessageBubble(
                    message: msg,
                    theme: theme,
                    onFollowUpTap: (id) => vm.handleFollowUpTap(id),
                  );
                },
              ),
            ),

            // One busy indicator at a time: image scan → oil analysis → reply.
            if (vm.isScanning)
              _BusyIndicator(
                theme: theme,
                label: context.l10n.chatbotScanningImage,
              )
            else if (vm.isAnalyzing)
              _BusyIndicator(
                theme: theme,
                label: context.l10n.chatbotAnalyzingMaterial,
              )
            else if (vm.isThinking)
              _BusyIndicator(theme: theme, label: context.l10n.chatbotThinking),

            _InputBar(
              controller: _controller,
              theme: theme,
              isBusy: vm.isBusy,
              onSend: () => _send(vm),
              onImagePick: () => _showImagePicker(vm),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Busy indicator — animated typing dots, shared by scan / analysis /
//  thinking states. Rendered as a bot-side bubble with the Dawa avatar.
// ─────────────────────────────────────────────────────────────────

class _BusyIndicator extends StatelessWidget {
  final ThemeData theme;
  final String label;

  const _BusyIndicator({required this.theme, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const _DawaAvatar(size: 28),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _TypingDots(),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    color: theme.hintColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Three staggered bouncing dots — the classic "typing…" affordance.
class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            // Each dot bounces in a staggered 0.2-phase offset.
            final t = (_ctrl.value + i * 0.2) % 1.0;
            final bounce = t < 0.5 ? t * 2 : (1 - t) * 2;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1.5),
              child: Transform.translate(
                offset: Offset(0, -3 * bounce),
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(
                      alpha: 0.4 + 0.6 * bounce,
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Dawa avatar — shared by header, bot bubbles, and busy indicator
// ─────────────────────────────────────────────────────────────────

class _DawaAvatar extends StatelessWidget {
  final double size;
  final bool showOnlineDot;

  const _DawaAvatar({required this.size, this.showOnlineDot = false});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primaryGreen, AppColors.primaryDark],
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.eco_rounded, color: Colors.white, size: size * 0.5),
        ),
        if (showOnlineDot)
          Positioned(
            bottom: 0,
            left: 0,
            child: Container(
              width: size * 0.28,
              height: size * 0.28,
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
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
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(bottom: BorderSide(color: theme.dividerColor, width: 1)),
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

          // Identity row — avatar + name + live status
          Row(
            children: [
              const _DawaAvatar(size: 42, showOnlineDot: true),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.chatbotTitle,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    Text(
                      l10n.chatbotOnlineNow,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11,
                        color: theme.hintColor,
                      ),
                    ),
                  ],
                ),
              ),
              // AI badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primaryGreen.withValues(alpha: 0.25),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      size: 12,
                      color: AppColors.primaryGreen,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'AI',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ],
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
    const primaryGreen = AppColors.primaryGreen;
    final isUser = message.isUser;

    // Oil analysis messages render as a rich card, not a plain bubble.
    if (!isUser && message.wasteAnalysis != null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            WasteAnalysisResultCard(result: message.wasteAnalysis!),
            if (message.followUps.isNotEmpty)
              _FollowUpChips(
                followUps: message.followUps,
                onTap: onFollowUpTap,
              ),
          ],
        ),
      );
    }

    final bubbleColor = isUser
        ? primaryGreen
        : theme.colorScheme.surfaceContainerHighest;
    final textColor = isUser
        ? Colors.white
        : (theme.textTheme.bodyMedium?.color ?? theme.colorScheme.onSurface);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: isUser
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        children: [
          // ML Kit source badge (shown when triggered by image scan)
          if (message.mlSource != null && !isUser)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  context.l10n.chatbotImageScanResult,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFFC8860A),
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
            ),

          // Bubble row — bot messages carry the Dawa avatar beside them.
          Row(
            mainAxisAlignment: isUser
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isUser) ...[
                const _DawaAvatar(size: 28),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.74,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isUser ? 4 : 16),
                      bottomRight: Radius.circular(isUser ? 16 : 4),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isUser ? AppColors.primaryDark : Colors.black)
                            .withValues(alpha: 0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Image thumbnail
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
              ),
            ],
          ),

          // Follow-up chips (bot messages only)
          if (!isUser && message.followUps.isNotEmpty)
            _FollowUpChips(followUps: message.followUps, onTap: onFollowUpTap),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Follow-up chips — quick-reply suggestions under bot messages
// ─────────────────────────────────────────────────────────────────

class _FollowUpChips extends StatelessWidget {
  final List<DawaEntry> followUps;
  final ValueChanged<String> onTap;

  const _FollowUpChips({required this.followUps, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Indent past the 28px avatar + 8px gap so chips align with the bubble.
      padding: const EdgeInsetsDirectional.only(top: 6, start: 36),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        alignment: WrapAlignment.end,
        children: followUps.map((entry) {
          final label = entry.response.split('\n').first;
          final short = label.length > 30
              ? '${label.substring(0, 28)}…'
              : label;
          return Material(
            color: AppColors.primaryGreen.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              onTap: () => onTap(entry.id),
              borderRadius: BorderRadius.circular(18),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppColors.primaryGreen.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.bolt_rounded,
                      size: 13,
                      color: AppColors.primaryGreen,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      short,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
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
  final bool isBusy;
  final VoidCallback onSend;
  final VoidCallback onImagePick;

  const _InputBar({
    required this.controller,
    required this.theme,
    required this.isBusy,
    required this.onSend,
    required this.onImagePick,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: theme.dividerColor, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Text field with camera action inside the pill
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.primaryGreen.withValues(alpha: 0.15),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        textDirection: TextDirection.rtl,
                        minLines: 1,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: l10n.chatbotInputHint,
                          hintStyle: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 13,
                            color: theme.hintColor,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsetsDirectional.fromSTEB(
                            16,
                            12,
                            4,
                            12,
                          ),
                        ),
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14,
                        ),
                        onSubmitted: isBusy ? null : (_) => onSend(),
                        textInputAction: TextInputAction.send,
                      ),
                    ),
                    // Camera / image pick — disabled while busy
                    IconButton(
                      onPressed: isBusy ? null : onImagePick,
                      tooltip: l10n.chatbotSendImageTooltip,
                      icon: Icon(
                        Icons.add_photo_alternate_rounded,
                        color: isBusy ? Colors.grey : AppColors.primaryGreen,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Send button — gradient pill, visually disabled while busy
            GestureDetector(
              onTap: isBusy ? null : onSend,
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: isBusy
                      ? LinearGradient(
                          colors: [Colors.grey.shade400, Colors.grey.shade500],
                        )
                      : const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primaryGreen,
                            AppColors.primaryDark,
                          ],
                        ),
                  shape: BoxShape.circle,
                  boxShadow: isBusy
                      ? null
                      : [
                          BoxShadow(
                            color: AppColors.primaryDark.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                ),
                child: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
