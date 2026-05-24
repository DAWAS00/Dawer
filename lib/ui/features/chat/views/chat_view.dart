import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/state/view_state.dart';
import '../../../../domain/chat/entities/chat_message.dart';
import '../../../../domain/chat/repositories/i_chat_repository.dart';
import '../../../../l10n/l10n.dart';
import '../viewmodels/chat_viewmodel.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input_bar.dart';

// ── ChatView ──────────────────────────────────────────────────────────────────
//
// Full-screen chat for a single order. Creates its own [ChatViewModel] locally
// so it doesn't pollute the global provider tree.
//
// Backend extension: pass real currentUserId / currentUserName / currentUserRole
// from the auth session instead of the defaults in [ChatViewModel].

class ChatView extends StatelessWidget {
  final String orderId;

  const ChatView({super.key, required this.orderId});

  /// Named push helper — keeps navigation calls concise.
  static Future<void> push(BuildContext context, {required String orderId}) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ChatView(orderId: orderId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => ChatViewModel(
        repo: ctx.read<IChatRepository>(),
        orderId: orderId,
        // TODO(backend): replace with real auth session values
      )..init(),
      child: _ChatScaffold(orderId: orderId),
    );
  }
}

// ── Scaffold ──────────────────────────────────────────────────────────────────

class _ChatScaffold extends StatelessWidget {
  final String orderId;
  const _ChatScaffold({required this.orderId});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ChatViewModel>();
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      appBar: _ChatAppBar(orderId: orderId),
      body: Column(
        children: [
          _frontendOnlyBanner(context),
          Expanded(child: _MessageList(vm: vm)),
          ChatInputBar(onSend: vm.send),
        ],
      ),
    );
  }

  // Frontend-only notice bar — remove this widget when backend is enabled.
  Widget _frontendOnlyBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      color: AppColors.amberContainer,
      child: Row(
        children: [
          const Spacer(),
          Text(
            context.l10n.chatDevBanner,
            textAlign: TextAlign.right,
            style: GoogleFonts.cairo(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.accentAmber,
            ),
          ),
          const SizedBox(width: 6),
          Icon(Icons.construction_rounded,
              size: 14, color: AppColors.accentAmber),
        ],
      ),
    );
  }
}

// ── AppBar ────────────────────────────────────────────────────────────────────

class _ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String orderId;
  const _ChatAppBar({required this.orderId});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF06402B),
      foregroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.chatTitle,
            style: GoogleFonts.cairo(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            '#$orderId',
            style: GoogleFonts.dmSans(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Message List ──────────────────────────────────────────────────────────────

class _MessageList extends StatefulWidget {
  final ChatViewModel vm;
  const _MessageList({required this.vm});

  @override
  State<_MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<_MessageList> {
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.vm.state;

    if (state is Loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state is Failed<List<ChatMessage>>) {
      return Center(
        child: Text(
          state.failure.message,
          style: GoogleFonts.cairo(color: AppColors.mutedText),
        ),
      );
    }
    if (state is Loaded<List<ChatMessage>>) {
      final msgs = state.data;
      if (msgs.isEmpty) return _EmptyState();
      _scrollToBottom();
      return ListView.builder(
        controller: _scrollCtrl,
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: msgs.length,
        itemBuilder: (_, i) => ChatBubble(
          message: msgs[i],
          isMine: msgs[i].senderId == widget.vm.currentUserId,
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.chat_bubble_outline_rounded,
              size: 48, color: AppColors.mutedText.withValues(alpha: 0.4)),
          const SizedBox(height: 12),
          Text(
            context.l10n.chatEmpty,
            style: GoogleFonts.cairo(fontSize: 14, color: AppColors.mutedText),
          ),
        ],
      ),
    );
  }
}
