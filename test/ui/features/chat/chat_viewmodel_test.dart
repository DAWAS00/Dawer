import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:dwaar/core/result/result.dart';
import 'package:dwaar/core/state/view_state.dart';
import 'package:dwaar/data/models/user_role.dart';
import 'package:dwaar/domain/chat/entities/chat_message.dart';
import 'package:dwaar/domain/chat/repositories/i_chat_repository.dart';
import 'package:dwaar/ui/features/chat/viewmodels/chat_viewmodel.dart';

// ── Fake IChatRepository ──────────────────────────────────────────────────────

class _FakeChatRepository implements IChatRepository {
  final _ctrl = StreamController<List<ChatMessage>>.broadcast();
  final List<ChatMessage> _sent = [];
  String? lastMarkReadOrderId;
  String? lastMarkReadUserId;

  List<ChatMessage> get sentMessages => List.unmodifiable(_sent);

  /// Push a list of messages into the stream.
  void emit(List<ChatMessage> msgs) => _ctrl.add(msgs);

  @override
  Stream<List<ChatMessage>> watchMessages(String orderId) {
    // Emit initial state on next microtask so subscribers are ready.
    Future.microtask(() => _ctrl.add([]));
    return _ctrl.stream;
  }

  @override
  Future<AppResult<void>> sendMessage({
    required String orderId,
    required String senderId,
    required String senderName,
    required UserRole senderRole,
    required String content,
  }) async {
    _sent.add(ChatMessage(
      id: 'test-${_sent.length}',
      roomId: orderId,
      senderId: senderId,
      senderName: senderName,
      senderRole: senderRole,
      content: content,
      sentAt: DateTime.now(),
    ));
    return const Success(null);
  }

  @override
  Future<AppResult<void>> markRead(String orderId, String userId) async {
    lastMarkReadOrderId = orderId;
    lastMarkReadUserId = userId;
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
  }) async => const Success(null);

  @override
  Future<AppResult<void>> sendLocation({
    required String orderId,
    required String senderId,
    required String senderName,
    required UserRole senderRole,
    required double lat,
    required double lng,
    String? label,
  }) async => const Success(null);

  @override
  Future<int> unreadCount(String orderId, String userId) async => 0;

  @override
  Future<void> broadcastTyping(String orderId, String senderId) async {}

  @override
  Stream<void> watchTyping(String orderId, String excludeUserId) =>
      const Stream.empty();

  void dispose() => _ctrl.close();
}

// ── Helpers ───────────────────────────────────────────────────────────────────

ChatMessage _msg(String id, String senderId) => ChatMessage(
      id: id,
      roomId: 'ORD-TEST',
      senderId: senderId,
      senderName: 'اختبار',
      senderRole: UserRole.supplier,
      content: 'رسالة $id',
      sentAt: DateTime.now(),
    );

/// Pump the event loop enough to let microtasks + async listeners settle.
Future<void> _settle() => Future.delayed(Duration.zero);

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  late _FakeChatRepository fakeRepo;
  late ChatViewModel vm;

  setUp(() {
    fakeRepo = _FakeChatRepository();
    vm = ChatViewModel(
      repo: fakeRepo,
      orderId: 'ORD-TEST',
      currentUserId: 'mock-user-01',
      currentUserName: 'مستخدم اختبار',
      currentUserRole: UserRole.supplier,
    );
  });

  tearDown(() {
    vm.dispose();
    fakeRepo.dispose();
  });

  // ── Init ──────────────────────────────────────────────────────────────────────

  group('ChatViewModel – init', () {
    test('state is Idle before init', () {
      expect(vm.state, isA<Idle>());
    });

    test('state becomes Loading immediately after init', () {
      vm.init();
      expect(vm.state, isA<Loading>());
    });

    test('state becomes Loaded after stream emits', () async {
      vm.init();
      await _settle();
      expect(vm.state, isA<Loaded<List<ChatMessage>>>());
    });

    test('Loaded state contains messages pushed by the stream', () async {
      vm.init();
      await _settle();

      fakeRepo.emit([_msg('m1', 'other-user')]);
      await _settle();

      final state = vm.state as Loaded<List<ChatMessage>>;
      expect(state.data.any((m) => m.id == 'm1'), isTrue);
    });

    test('notifies listeners when state changes', () async {
      var notified = 0;
      vm.addListener(() => notified++);
      vm.init();
      await _settle();
      expect(notified, greaterThanOrEqualTo(2)); // Loading + Loaded
    });
  });

  // ── markRead ──────────────────────────────────────────────────────────────────

  group('ChatViewModel – markRead on receive', () {
    test('markRead is called with correct orderId after stream emits', () async {
      vm.init();
      await _settle();
      fakeRepo.emit([_msg('m1', 'other-user')]);
      await _settle();

      expect(fakeRepo.lastMarkReadOrderId, 'ORD-TEST');
    });

    test('markRead is called with currentUserId', () async {
      vm.init();
      await _settle();
      fakeRepo.emit([_msg('m1', 'other-user')]);
      await _settle();

      expect(fakeRepo.lastMarkReadUserId, 'mock-user-01');
    });
  });

  // ── send ──────────────────────────────────────────────────────────────────────

  group('ChatViewModel – send', () {
    test('delegates to repo with correct sender info', () async {
      vm.init();
      await vm.send('مرحباً');

      expect(fakeRepo.sentMessages.length, 1);
      final sent = fakeRepo.sentMessages.first;
      expect(sent.content, 'مرحباً');
      expect(sent.senderId, 'mock-user-01');
      expect(sent.senderName, 'مستخدم اختبار');
      expect(sent.senderRole, UserRole.supplier);
    });

    test('trims whitespace before sending', () async {
      vm.init();
      await vm.send('  رسالة  ');
      expect(fakeRepo.sentMessages.first.content, 'رسالة');
    });

    test('empty string is not sent', () async {
      vm.init();
      await vm.send('');
      expect(fakeRepo.sentMessages, isEmpty);
    });

    test('whitespace-only string is not sent', () async {
      vm.init();
      await vm.send('   ');
      expect(fakeRepo.sentMessages, isEmpty);
    });

    test('multiple sends each create a separate message', () async {
      vm.init();
      await vm.send('أولى');
      await vm.send('ثانية');

      expect(fakeRepo.sentMessages.length, 2);
      expect(fakeRepo.sentMessages[0].content, 'أولى');
      expect(fakeRepo.sentMessages[1].content, 'ثانية');
    });
  });

  // ── Identity ──────────────────────────────────────────────────────────────────

  group('ChatViewModel – identity', () {
    test('exposes currentUserId', () {
      expect(vm.currentUserId, 'mock-user-01');
    });

    test('exposes orderId', () {
      expect(vm.orderId, 'ORD-TEST');
    });

    test('exposes currentUserRole', () {
      expect(vm.currentUserRole, UserRole.supplier);
    });
  });

  // ── Dispose ───────────────────────────────────────────────────────────────────
  // Use a local repo+vm so tearDown doesn't double-dispose.

  group('ChatViewModel – dispose', () {
    test('dispose does not throw', () async {
      final localRepo = _FakeChatRepository();
      final localVm = ChatViewModel(
        repo: localRepo,
        orderId: 'ORD-DISP',
        currentUserId: 'u1',
        currentUserName: 'مستخدم',
        currentUserRole: UserRole.supplier,
      );
      localVm.init();
      await _settle();
      expect(() => localVm.dispose(), returnsNormally);
      localRepo.dispose();
    });

    test('no state changes after dispose — no crash', () async {
      final localRepo = _FakeChatRepository();
      final localVm = ChatViewModel(
        repo: localRepo,
        orderId: 'ORD-DISP',
        currentUserId: 'u1',
        currentUserName: 'مستخدم',
        currentUserRole: UserRole.supplier,
      );
      localVm.init();
      await _settle();
      localVm.dispose();

      // Push event after dispose — _disposed guard should swallow it silently
      localRepo.emit([_msg('m99', 'other')]);
      await _settle();
      localRepo.dispose();
      // No assertion — absence of crash/assertion-error is the pass condition
    });
  });
}
