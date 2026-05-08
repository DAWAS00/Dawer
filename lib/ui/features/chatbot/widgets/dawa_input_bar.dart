import 'package:flutter/material.dart';
import 'dawa_chat_constants.dart';

/// Bottom input bar for the Dawa chat: image-pick button, text field, send.
class DawaInputBar extends StatelessWidget {
  final TextEditingController controller;
  final ThemeData theme;
  final VoidCallback onSend;
  final VoidCallback onImagePick;

  const DawaInputBar({
    super.key,
    required this.controller,
    required this.theme,
    required this.onSend,
    required this.onImagePick,
  });

  @override
  Widget build(BuildContext context) {
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
            _ImagePickButton(onTap: onImagePick),
            const SizedBox(width: 4),
            Expanded(child: _ChatTextField(controller: controller, theme: theme, onSend: onSend)),
            const SizedBox(width: 8),
            _SendButton(onTap: onSend),
          ],
        ),
      ),
    );
  }
}

class _ImagePickButton extends StatelessWidget {
  final VoidCallback onTap;
  const _ImagePickButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: const Padding(
          padding: EdgeInsets.all(8),
          child: Icon(
            Icons.add_photo_alternate_rounded,
            color: kDawaPrimaryGreen,
            size: 26,
          ),
        ),
      ),
    );
  }
}

class _ChatTextField extends StatelessWidget {
  final TextEditingController controller;
  final ThemeData theme;
  final VoidCallback onSend;
  const _ChatTextField({
    required this.controller,
    required this.theme,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textDirection: TextDirection.rtl,
      decoration: InputDecoration(
        hintText: 'اكتب سؤالك أو أرسل صورة...',
        hintStyle: TextStyle(fontFamily: 'Cairo', color: theme.hintColor),
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHighest,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
      ),
      style: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
      onSubmitted: (_) => onSend(),
      textInputAction: TextInputAction.send,
    );
  }
}

class _SendButton extends StatelessWidget {
  final VoidCallback onTap;
  const _SendButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kDawaPrimaryGreen,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: const Padding(
          padding: EdgeInsets.all(10),
          child: Icon(Icons.send_rounded, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}
