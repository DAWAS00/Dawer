import 'package:flutter/material.dart';
import '../../../chatbot/dawa_chat_widget.dart';

/// Single FAB on the marketplace tab. Tapping opens [DawaChatWidget]
/// as a draggable bottom sheet — swipe down to dismiss.
class MarketplaceChatbotFab extends StatelessWidget {
  const MarketplaceChatbotFab({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'market_dawa_chat_fab',
      onPressed: () => _openDawaChat(context),
      backgroundColor: const Color(0xFF06402B),
      elevation: 4,
      tooltip: 'مساعد دوّار',
      child: const Icon(
        Icons.smart_toy_rounded,
        color: Colors.white,
        size: 26,
      ),
    );
  }

  void _openDawaChat(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.92,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        snap: true,
        snapSizes: const [0.4, 0.92],
        builder: (_, scrollController) => ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: Scaffold(
            backgroundColor: const Color(0xFF06402B),
            body: Column(
              children: [
                _DragHandle(scrollController: scrollController),
                const Expanded(child: DawaChatWidget()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DragHandle extends StatelessWidget {
  final ScrollController scrollController;
  const _DragHandle({required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        scrollController.position.moveTo(
          scrollController.offset - details.primaryDelta!,
          clamp: true,
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        color: const Color(0xFF06402B),
        child: Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }
}
