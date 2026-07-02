import 'package:flutter/material.dart';

import 'package:dwaar/core/constants/app_colors.dart';
import 'package:dwaar/l10n/l10n.dart';
import 'dawa_chat_widget.dart';

/// Cross-cutting host that overlays a draggable Dawa-assistant bubble on top
/// of any home shell. Wrapped once around the role shells in [HomeRouter] so
/// every user role gets the same global entry point.
///
/// The bubble is draggable anywhere on screen and snaps to the nearest
/// horizontal edge on release. Tapping it opens the chat as a draggable
/// bottom sheet ([DawaAssistantSheet.show]).
class DawaAssistantHost extends StatefulWidget {
  final Widget child;

  const DawaAssistantHost({super.key, required this.child});

  @override
  State<DawaAssistantHost> createState() => _DawaAssistantHostState();
}

class _DawaAssistantHostState extends State<DawaAssistantHost> {
  static const double _bubbleSize = 56;
  static const double _edgePadding = 12;
  // Keep the bubble clear of app bars and bottom navigation.
  static const double _topReserve = 96;
  static const double _bottomReserve = 120;

  // Null until first layout: start docked at the bottom-trailing corner.
  Offset? _position;
  bool _snapping = false;

  Offset _clamp(Offset raw, Size screen) {
    final maxX = screen.width - _bubbleSize - _edgePadding;
    final maxY = screen.height - _bubbleSize - _bottomReserve;
    return Offset(
      raw.dx.clamp(_edgePadding, maxX),
      raw.dy.clamp(_topReserve, maxY),
    );
  }

  void _snapToEdge(Size screen) {
    final pos = _position!;
    final centerX = pos.dx + _bubbleSize / 2;
    final targetX = centerX < screen.width / 2
        ? _edgePadding
        : screen.width - _bubbleSize - _edgePadding;
    setState(() {
      _snapping = true;
      _position = Offset(targetX, pos.dy);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    // Default dock: bottom corner on the leading side's opposite (thumb zone).
    _position ??= Offset(
      isRtl ? _edgePadding : screen.width - _bubbleSize - _edgePadding,
      screen.height - _bubbleSize - _bottomReserve,
    );

    return Stack(
      children: [
        widget.child,
        AnimatedPositioned(
          duration: _snapping
              ? const Duration(milliseconds: 220)
              : Duration.zero,
          curve: Curves.easeOutBack,
          left: _position!.dx,
          top: _position!.dy,
          child: GestureDetector(
            onPanStart: (_) => _snapping = false,
            onPanUpdate: (d) => setState(
              () => _position = _clamp(_position! + d.delta, screen),
            ),
            onPanEnd: (_) => _snapToEdge(screen),
            onTap: () => DawaAssistantSheet.show(context),
            child: _AssistantBubble(
              semanticsLabel: context.l10n.chatbotOpenAssistant,
            ),
          ),
        ),
      ],
    );
  }
}

class _AssistantBubble extends StatelessWidget {
  final String semanticsLabel;

  const _AssistantBubble({required this.semanticsLabel});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticsLabel,
      child: Container(
        width: _DawaAssistantHostState._bubbleSize,
        height: _DawaAssistantHostState._bubbleSize,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primaryGreen, AppColors.primaryDark],
          ),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryDark.withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Icon(Icons.eco_rounded, color: Colors.white, size: 26),
      ),
    );
  }
}

/// Opens the Dawa chat as a draggable, keyboard-aware bottom sheet.
/// Shared by the floating bubble and any in-page entry points (e.g. the
/// marketplace header button) so the chat always presents the same way.
class DawaAssistantSheet {
  const DawaAssistantSheet._();

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Padding(
        // Keep the input bar above the keyboard.
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
        ),
        child: DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.45,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, __) => const _SheetChrome(child: DawaChatWidget()),
        ),
      ),
    );
  }
}

class _SheetChrome extends StatelessWidget {
  final Widget child;

  const _SheetChrome({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.15),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      // DawaChatWidget's header already renders its own drag handle.
      child: child,
    );
  }
}
