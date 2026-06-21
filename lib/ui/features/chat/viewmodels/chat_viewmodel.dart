import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../../core/state/view_state.dart';
import '../../../../data/models/user_role.dart';
import '../../../../domain/chat/entities/chat_message.dart';
import '../../../../domain/chat/repositories/i_chat_repository.dart';
import '../../../../domain/failures/app_failure.dart';

// ── ChatViewModel ─────────────────────────────────────────────────────────────
//
// Owns message list state for a single order chat room.
// Created per-view — not registered globally.
//
// Identity (`currentUserId`/`Name`/`Role`) is injected from the auth session
// by `ChatView` (which reads `IAuthRepository.currentSession`). The defaults
// here are only a fallback for offline/mock mode where no session exists.

class ChatViewModel extends ChangeNotifier {
  ChatViewModel({
    required IChatRepository repo,
    required this.orderId,
    this.currentUserId = 'guest',
    this.currentUserName = 'Guest',
    this.currentUserRole = UserRole.supplier,
  }) : _repo = repo;

  final IChatRepository _repo;
  final String orderId;
  final String currentUserId;
  final String currentUserName;
  final UserRole currentUserRole;

  ViewState<List<ChatMessage>> _state = const Idle();
  ViewState<List<ChatMessage>> get state => _state;

  StreamSubscription<List<ChatMessage>>? _sub;
  bool _disposed = false;

  void init() {
    _state = const Loading();
    notifyListeners();

    _sub = _repo.watchMessages(orderId).listen(
      (msgs) {
        if (_disposed) return;
        _state = Loaded(msgs);
        notifyListeners();
        // Only mark-read when there's actually something unread from others.
        // Avoids a redundant UPDATE write on every realtime snapshot (the
        // UPDATE would otherwise fire a realtime event → re-render cycle,
        // harmless but wasteful — converges in 2 cycles either way).
        final hasUnreadFromOthers = msgs.any(
          (m) => m.senderId != currentUserId && !m.isRead,
        );
        if (hasUnreadFromOthers) {
          _repo.markRead(orderId, currentUserId);
        }
      },
      onError: (_) {
        if (_disposed) return;
        _state = const Failed(
          UnknownFailure(message: 'تعذّر تحميل الرسائل'),
        );
        notifyListeners();
      },
    );
  }

  Future<void> send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    await _repo.sendMessage(
      orderId: orderId,
      senderId: currentUserId,
      senderName: currentUserName,
      senderRole: currentUserRole,
      content: trimmed,
    );
  }

  @override
  void dispose() {
    _disposed = true;
    _sub?.cancel();
    super.dispose();
  }
}
