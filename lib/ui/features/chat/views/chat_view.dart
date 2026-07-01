import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/state/view_state.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../data/models/order/order.dart';
import '../../../../data/models/user_role.dart';
import '../../../../domain/chat/entities/chat_message.dart';
import '../../../../domain/chat/repositories/i_chat_repository.dart';
import '../../../../domain/repositories/i_auth_repository.dart';
import '../../../../l10n/l10n.dart';
import '../viewmodels/chat_viewmodel.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input_bar.dart';

class ChatView extends StatelessWidget {
  final String orderId;

  /// Full order object — optional. Pass it whenever available so the AppBar
  /// subtitle and order-context card can render. Callers with only an orderId
  /// (e.g. proximity banner) may leave this null.
  final Order? order;

  const ChatView({super.key, required this.orderId, this.order});

  static Future<void> push(
    BuildContext context, {
    required String orderId,
    Order? order,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatView(orderId: orderId, order: order),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = context.read<IAuthRepository>().currentSession;

    return ChangeNotifierProvider(
      create: (ctx) => ChatViewModel(
        repo: ctx.read<IChatRepository>(),
        orderId: orderId,
        currentUserId: session?.userId ?? 'guest',
        currentUserName: session?.userName ?? 'Guest',
        currentUserRole: session?.role ?? UserRole.supplier,
        order: order,
      )..init(),
      child: _ChatScaffold(orderId: orderId),
    );
  }
} 
class _ChatScaffold extends StatelessWidget {
  final String orderId;
  const _ChatScaffold({required this.orderId});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ChatViewModel>();
    return Scaffold(
      backgroundColor: context.dt.scaffold,
      appBar: _ChatAppBar(orderId: orderId),
      body: Column(
        children: [
          _frontendOnlyBanner(context),
          Expanded(
            child: _MessageList(vm: vm),
          ),
          _TypingIndicator(isVisible: vm.isOtherTyping),
          ChatInputBar(
            onSend: vm.send,
            onTyping: vm.onTyping,
            onPickImage: vm.pickAndSendImage,
            onShareLocation: vm.sendCurrentLocation,
            isSendingLocation: vm.isSendingLocation,
            quickReplies: _quickRepliesForStatus(
              vm.order?.status,
              vm.currentUserRole,
            ),
          ),
        ],
      ),
    );
  }

  // State-aware quick replies — chips change at each order stage.
  List<String> _quickRepliesForStatus(
    OrderStatus? status,
    UserRole role,
  ) {
    final isDriver = role == UserRole.driver;
    return switch (status) {
      OrderStatus.pending => isDriver
          ? ['في الطريق إليك', 'سأكون هناك قريباً']
          : ['المواد جاهزة', 'بانتظارك'],
      OrderStatus.accepted => isDriver
          ? ['في الطريق إليك', 'أنا على بعد 5 دقائق']
          : ['المواد جاهزة', 'أين أنت الآن؟'],
      OrderStatus.arrivedAtPickup => isDriver
          ? ['وصلت، أين الحاوية؟', 'ما رمز الباب؟', 'لا أرى العنوان']
          : ['أنا قادم', 'الحاوية في الخارج', 'رمز الباب معك'],
      OrderStatus.inTransit => isDriver
          ? ['تم التحميل، في الطريق']
          : ['متى تصل؟', 'شكراً على الاستلام'],
      OrderStatus.arrivedAtDropoff => isDriver
          ? ['وصلت لنقطة التسليم', 'بانتظار الاستلام']
          : ['جاهزون للاستلام', 'تفضّل للداخل'],
      OrderStatus.completed || OrderStatus.cancelled => isDriver
          ? ['شكراً على التعاون']
          : ['شكراً، خدمة ممتازة'],
      null => isDriver
          ? ['في الطريق إليك', 'لقد وصلت']
          : ['المواد جاهزة', 'بانتظارك'],
    };
  }

  // Dev-only banner — hidden in release builds and when live repo is wired.
  Widget _frontendOnlyBanner(BuildContext context) {
    final isMock = context.read<IChatRepository>().runtimeType.toString() != 'SupabaseChatRepository';
    if (!kDebugMode || !isMock) return const SizedBox.shrink();
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
          const Icon(Icons.construction_rounded,
              size: 14, color: AppColors.accentAmber),
        ],
      ),
    );
  }
}
 

class _ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String orderId;
  const _ChatAppBar({required this.orderId});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ChatViewModel>();
    final otherName = vm.otherPartyName;
    final otherRole = vm.otherPartyRoleLabel;
    final statusLabel = vm.orderStatusLabel; 
    final String subtitle;
    if (otherName != null && otherRole != null) {
      subtitle = statusLabel != null
          ? '$otherName ($otherRole) · $statusLabel'
          : '$otherName ($otherRole)';
    } else {
      subtitle = '#$orderId';
    }

    return AppBar(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
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
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.cairo(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.75),
            ),
          ),
        ],
      ),
    );
  }
}

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

  List<Widget> _buildItems(
    List<ChatMessage> msgs,
    String currentUserId,
    Set<String> failedIds,
    void Function(ChatMessage) onRetry,
  ) {
    final items = <Widget>[];
    DateTime? lastDate;
    for (final msg in msgs) {
      final msgDate =
          DateTime(msg.sentAt.year, msg.sentAt.month, msg.sentAt.day);
      if (lastDate == null || msgDate != lastDate) {
        items.add(_DateSeparator(date: msgDate));
        lastDate = msgDate;
      }
      final isOptimistic = msg.id.startsWith('opt_');
      final isFailed = failedIds.contains(msg.id);
      items.add(ChatBubble(
        message: msg,
        isMine: msg.senderId == currentUserId,
        isSending: isOptimistic && !isFailed,
        isFailed: isFailed,
        onRetry: isFailed ? () => onRetry(msg) : null,
      ));
    }
    return items;
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
          style: GoogleFonts.cairo(color: context.dt.onSurfaceMuted),
        ),
      );
    }
    if (state is Loaded<List<ChatMessage>>) {
      final msgs = state.data;
      final order = widget.vm.order;
      final items = _buildItems(
        msgs,
        widget.vm.currentUserId,
        widget.vm.failedIds,
        widget.vm.retry,
      );

      return CustomScrollView(
        controller: _scrollCtrl,
        slivers: [
          // Pinned order-context card at the top.
          if (order != null)
            SliverToBoxAdapter(
              child: _OrderContextCard(order: order),
            ),
          if (msgs.isEmpty)
            SliverFillRemaining(child: _EmptyState())
          else ...[
            SliverPadding(
              padding: const EdgeInsets.only(bottom: 12),
              sliver: SliverList.builder(
                itemCount: items.length,
                itemBuilder: (_, i) => items[i],
              ),
            ),
          ],
        ],
      );
    }
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _scrollToBottom());
    return const SizedBox.shrink();
  }
}

// ── Order context card ────────────────────────────────────────────────────────

class _OrderContextCard extends StatefulWidget {
  final Order order;
  const _OrderContextCard({required this.order});

  @override
  State<_OrderContextCard> createState() => _OrderContextCardState();
}

class _OrderContextCardState extends State<_OrderContextCard> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final o = widget.order;
    final wasteLabel = o.wasteTypes.isNotEmpty
        ? o.wasteTypes.map((w) => w.label).join('، ')
        : null;
    final weight =
        o.weightKg != null ? '${o.weightKg!.toStringAsFixed(0)} كجم' : null;
    final accent = Theme.of(context).primaryColor;

    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: GestureDetector(
        onTap: () => setState(() => _expanded = !_expanded),
        child: Container(
          margin: const EdgeInsets.fromLTRB(12, 10, 12, 4),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: accent.withValues(alpha: 0.18),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Header row — always visible.
              Row(
                children: [
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: accent,
                  ),
                  const Spacer(),
                  if (wasteLabel != null)
                    Flexible(
                      child: Text(
                        wasteLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: accent,
                        ),
                      ),
                    ),
                  const SizedBox(width: 6),
                  Icon(Icons.inventory_2_rounded, size: 15, color: accent),
                ],
              ),
              // Expanded details.
              if (_expanded) ...[
                const SizedBox(height: 8),
                if (weight != null)
                  _ContextRow(
                    icon: Icons.scale_rounded,
                    text: weight,
                  ),
                _ContextRow(
                  icon: Icons.location_on_rounded,
                  text: o.pickupAddress,
                ),
                if (o.supplierNotes != null &&
                    o.supplierNotes!.trim().isNotEmpty)
                  _ContextRow(
                    icon: Icons.note_rounded,
                    text: o.supplierNotes!,
                    highlight: true,
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ContextRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool highlight;
  const _ContextRow({
    required this.icon,
    required this.text,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        highlight ? const Color(0xFFC8860A) : context.dt.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              text,
              textAlign: TextAlign.right,
              style: GoogleFonts.cairo(
                fontSize: 12,
                color: color,
                fontWeight:
                    highlight ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Icon(icon, size: 13, color: color),
        ],
      ),
    );
  }
}

// ── Date separator ────────────────────────────────────────────────────────────

class _DateSeparator extends StatelessWidget {
  final DateTime date;
  const _DateSeparator({required this.date});

  String _label() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    if (date == today) return 'اليوم';
    if (date == yesterday) return 'أمس';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(child: Divider(color: context.dt.border)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              _label(),
              style: GoogleFonts.cairo(
                fontSize: 11,
                color: context.dt.onSurfaceMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(child: Divider(color: context.dt.border)),
        ],
      ),
    );
  }
}

// ── Typing indicator ──────────────────────────────────────────────────────────

class _TypingIndicator extends StatefulWidget {
  final bool isVisible;
  const _TypingIndicator({required this.isVisible});

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _dot1;
  late final Animation<double> _dot2;
  late final Animation<double> _dot3;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
    _dot1 = Tween(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.5)),
    );
    _dot2 = Tween(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.2, 0.7)),
    );
    _dot3 = Tween(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.4, 0.9)),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: widget.isVisible
          ? Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
              color: context.dt.scaffold,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'يكتب الآن',
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      color: context.dt.onSurfaceMuted,
                    ),
                  ),
                  const SizedBox(width: 6),
                  AnimatedBuilder(
                    animation: _ctrl,
                    builder: (_, __) => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _Dot(opacity: _dot1.value),
                        _Dot(opacity: _dot2.value),
                        _Dot(opacity: _dot3.value),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}

class _Dot extends StatelessWidget {
  final double opacity;
  const _Dot({required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Opacity(
        opacity: opacity,
        child: Container(
          width: 5,
          height: 5,
          decoration: const BoxDecoration(
            color: AppColors.primaryGreen,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.chat_bubble_outline_rounded,
              size: 48,
              color: context.dt.onSurfaceMuted.withValues(alpha: 0.4)),
          const SizedBox(height: 12),
          Text(
            context.l10n.chatEmpty,
            style: GoogleFonts.cairo(
                fontSize: 14, color: context.dt.onSurfaceMuted),
          ),
        ],
      ),
    );
  }
}
