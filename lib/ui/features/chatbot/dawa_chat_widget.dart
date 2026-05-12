import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dawa_chat_view_model.dart';
import 'widgets/dawa_chat_header.dart';
import 'widgets/dawa_image_pick_sheet.dart';
import 'widgets/dawa_input_bar.dart';
import 'widgets/dawa_message_bubble.dart';
import 'widgets/dawa_scanning_indicator.dart';

/// Entry-point widget for the Dawa support chat.
///
/// Wraps [_DawaChatBody] in a [ChangeNotifierProvider] so it owns its own VM.
/// Drop this into any bottom sheet, scaffold, or full screen.
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

  void _onImagePick(DawaChatViewModel vm) {
    showDawaImagePickSheet(
      context,
      onPicked: (source) {
        vm.handleImagePick(source).then((_) => _scrollToBottom());
      },
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
            DawaChatHeader(theme: theme),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: vm.messages.length,
                itemBuilder: (context, index) {
                  final msg = vm.messages[index];
                  return DawaMessageBubble(
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
            if (vm.isScanning) DawaScanningIndicator(theme: theme),
            DawaInputBar(
              controller: _controller,
              theme: theme,
              onSend: () => _send(vm),
              onImagePick: () => _onImagePick(vm),
            ),
          ],
        ),
      ),
    );
  }
}
