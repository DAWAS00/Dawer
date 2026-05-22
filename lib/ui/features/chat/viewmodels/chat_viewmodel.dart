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
// Backend extension: [currentUserId], [currentUserName], and [currentUserRole]
// are currently hardcoded to a mock identity. Replace with the real auth
// session (e.g. LocalStore.currentUser) when backend is enabled.

class ChatViewModel extends ChangeNotifier {
  ChatViewModel({
    required IChatRepository repo,
    required this.orderId,
    // TODO(backend): inject from auth session instead of defaulting to mock
    this.currentUserId = 'mock-user-01',
    this.currentUserName = 'مورد دوّر',
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
        _repo.markRead(orderId, currentUserId);
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
