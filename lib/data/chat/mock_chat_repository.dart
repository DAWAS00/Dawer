import 'dart:async';
import 'dart:io';

import '../../core/result/result.dart';
import '../../data/models/user_role.dart';
import '../../domain/chat/entities/chat_message.dart';
import '../../domain/chat/repositories/i_chat_repository.dart';

// ── MockChatRepository ────────────────────────────────────────────────────────
//
// Frontend-only implementation backed by in-memory state + StreamControllers.
// Pre-seeded with a short conversation on ORD-S01 so the UI is immediately
// testable without a running backend.
//
// Backend extension: delete this file and register SupabaseChatRepository in
// DawerApp's MultiProvider. No other files need to change.

class MockChatRepository implements IChatRepository {
  int _seq = 100;

  String _nextId() => 'msg-${_seq++}';

  // roomId → message list
  final Map<String, List<ChatMessage>> _rooms = {};

  // roomId → broadcast controller
  final Map<String, StreamController<List<ChatMessage>>> _controllers = {};

  MockChatRepository() {
    _seed();
  }

  // ── Seed ───────────────────────────────────────────────────────────────────

  void _seed() {
    final now = DateTime.now();
    _rooms['ORD-S01'] = [
      ChatMessage(
        id: 'msg-01',
        roomId: 'ORD-S01',
        senderId: 'driver-01',
        senderName: 'خالد محمد',
        senderRole: UserRole.driver,
        content: 'مرحباً، أنا في الطريق إليك.',
        sentAt: now.subtract(const Duration(minutes: 10)),
        isRead: true,
      ),
      ChatMessage(
        id: 'msg-02',
        roomId: 'ORD-S01',
        senderId: 'mock-user-01',
        senderName: 'مورد دوّر',
        senderRole: UserRole.supplier,
        content: 'ممتاز! المواد جاهزة عند الباب.',
        sentAt: now.subtract(const Duration(minutes: 8)),
        isRead: true,
      ),
      ChatMessage(
        id: 'msg-03',
        roomId: 'ORD-S01',
        senderId: 'driver-01',
        senderName: 'خالد محمد',
        senderRole: UserRole.driver,
        content: 'سأصل خلال ١٢ دقيقة تقريباً.',
        sentAt: now.subtract(const Duration(minutes: 6)),
        isRead: false,
      ),
    ];
  }

  // ── IChatRepository ────────────────────────────────────────────────────────

  @override
  Stream<List<ChatMessage>> watchMessages(String orderId) {
    final ctrl = _controllers.putIfAbsent(
      orderId,
      () => StreamController<List<ChatMessage>>.broadcast(),
    );
    Future.microtask(() {
      if (!ctrl.isClosed) ctrl.add(List.of(_rooms[orderId] ?? []));
    });
    return ctrl.stream;
  }

  @override
  Future<AppResult<void>> sendMessage({
    required String orderId,
    required String senderId,
    required String senderName,
    required UserRole senderRole,
    required String content,
  }) async {
    final msg = ChatMessage(
      id: _nextId(),
      roomId: orderId,
      senderId: senderId,
      senderName: senderName,
      senderRole: senderRole,
      content: content,
      sentAt: DateTime.now(),
    );
    _rooms.putIfAbsent(orderId, () => []).add(msg);
    _controllers[orderId]?.add(List.of(_rooms[orderId]!));
    return const Success(null);
  }

  @override
  Future<AppResult<void>> sendImage({
    required String orderId,
    required String senderId,
    required String senderName,
    required UserRole senderRole,
    required File image,
    String? caption,
  }) async {
    final msg = ChatMessage(
      id: _nextId(),
      roomId: orderId,
      senderId: senderId,
      senderName: senderName,
      senderRole: senderRole,
      content: caption?.trim() ?? '',
      kind: ChatMessageKind.image,
      // Mock: use the local file path so the UI can render it in dev.
      attachmentUrl: image.path,
      sentAt: DateTime.now(),
    );
    _rooms.putIfAbsent(orderId, () => []).add(msg);
    _controllers[orderId]?.add(List.of(_rooms[orderId]!));
    return const Success(null);
  }

  @override
  Future<AppResult<void>> sendLocation({
    required String orderId,
    required String senderId,
    required String senderName,
    required UserRole senderRole,
    required double lat,
    required double lng,
    String? label,
  }) async {
    final msg = ChatMessage(
      id: _nextId(),
      roomId: orderId,
      senderId: senderId,
      senderName: senderName,
      senderRole: senderRole,
      content: label?.trim() ?? '',
      kind: ChatMessageKind.location,
      lat: lat,
      lng: lng,
      sentAt: DateTime.now(),
    );
    _rooms.putIfAbsent(orderId, () => []).add(msg);
    _controllers[orderId]?.add(List.of(_rooms[orderId]!));
    return const Success(null);
  }

  @override
  Future<AppResult<void>> markRead(String orderId, String userId) async {
    final msgs = _rooms[orderId];
    if (msgs == null) return const Success(null);
    // Update in-memory only — do NOT emit to the stream or it re-triggers
    // the watchMessages listener causing an infinite loop.
    _rooms[orderId] = msgs
        .map((m) => m.senderId != userId ? m.copyWith(isRead: true) : m)
        .toList();
    return const Success(null);
  }

  @override
  Future<int> unreadCount(String orderId, String userId) async {
    return (_rooms[orderId] ?? [])
        .where((m) => m.senderId != userId && !m.isRead)
        .length;
  }

  @override
  Future<void> broadcastTyping(String orderId, String senderId) async {}

  @override
  Stream<void> watchTyping(String orderId, String excludeUserId) =>
      const Stream.empty();

  void dispose() {
    for (final ctrl in _controllers.values) {
      ctrl.close();
    }
    _controllers.clear();
  }
}
