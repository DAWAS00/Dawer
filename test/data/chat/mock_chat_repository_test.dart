import 'package:flutter_test/flutter_test.dart';
import 'package:dwaar/data/chat/mock_chat_repository.dart';
import 'package:dwaar/data/models/user_role.dart';
import 'package:dwaar/domain/chat/entities/chat_message.dart';

// Collects all events from a broadcast stream for the duration of [action].
Future<List<List<ChatMessage>>> _collect(
  Stream<List<ChatMessage>> stream,
  Future<void> Function() action,
) async {
  final events = <List<ChatMessage>>[];
  final sub = stream.listen(events.add);
  await Future.delayed(Duration.zero); // let initial microtask emit settle
  await action();
  await Future.delayed(Duration.zero); // let post-action emit settle
  await sub.cancel();
  return events;
}

void main() {
  late MockChatRepository repo;

  setUp(() => repo = MockChatRepository());
  tearDown(() => repo.dispose());

  // ── Seed ─────────────────────────────────────────────────────────────────────

  group('MockChatRepository – seed data', () {
    test('ORD-S01 is pre-seeded with 3 messages', () async {
      final events = await _collect(
        repo.watchMessages('ORD-S01'),
        () async {},
      );
      expect(events.first.length, 3);
    });

    test('seed messages have correct roomId', () async {
      final events = await _collect(
        repo.watchMessages('ORD-S01'),
        () async {},
      );
      expect(events.first.every((m) => m.roomId == 'ORD-S01'), isTrue);
    });

    test('unknown order emits empty list', () async {
      final events = await _collect(
        repo.watchMessages('ORD-UNKNOWN'),
        () async {},
      );
      expect(events.first, isEmpty);
    });
  });

  // ── watchMessages ─────────────────────────────────────────────────────────────

  group('MockChatRepository – watchMessages', () {
    test('stream emits immediately on subscribe', () async {
      final events = await _collect(
        repo.watchMessages('ORD-S01'),
        () async {},
      );
      expect(events, isNotEmpty);
    });

    test('stream emits updated list after sendMessage', () async {
      final events = await _collect(
        repo.watchMessages('ORD-S01'),
        () => repo.sendMessage(
          orderId: 'ORD-S01',
          senderId: 'user-99',
          senderName: 'اختبار',
          senderRole: UserRole.supplier,
          content: 'رسالة جديدة',
        ),
      );
      expect(events.last.any((m) => m.content == 'رسالة جديدة'), isTrue);
    });

    test('new order room starts empty then grows after send', () async {
      final events = await _collect(
        repo.watchMessages('ORD-NEW'),
        () => repo.sendMessage(
          orderId: 'ORD-NEW',
          senderId: 'u1',
          senderName: 'مستخدم',
          senderRole: UserRole.driver,
          content: 'أول رسالة',
        ),
      );
      expect(events.first, isEmpty);
      expect(events.last.length, 1);
      expect(events.last.first.content, 'أول رسالة');
    });
  });

  // ── sendMessage ───────────────────────────────────────────────────────────────

  group('MockChatRepository – sendMessage', () {
    test('returns Success', () async {
      final result = await repo.sendMessage(
        orderId: 'ORD-S01',
        senderId: 'u1',
        senderName: 'مستخدم',
        senderRole: UserRole.supplier,
        content: 'مرحبا',
      );
      expect(result.isSuccess, isTrue);
    });

    test('message is appended with correct fields', () async {
      final events = await _collect(
        repo.watchMessages('ORD-S01'),
        () => repo.sendMessage(
          orderId: 'ORD-S01',
          senderId: 'user-42',
          senderName: 'أحمد',
          senderRole: UserRole.recyclingCo,
          content: 'هل الطلب جاهز؟',
        ),
      );
      final sent = events.last.last;
      expect(sent.senderId, 'user-42');
      expect(sent.senderName, 'أحمد');
      expect(sent.senderRole, UserRole.recyclingCo);
      expect(sent.content, 'هل الطلب جاهز؟');
      expect(sent.isRead, isFalse);
    });

    test('each message gets a unique id', () async {
      await repo.sendMessage(
        orderId: 'ORD-S01',
        senderId: 'u1',
        senderName: 'أ',
        senderRole: UserRole.driver,
        content: 'أولى',
      );
      await repo.sendMessage(
        orderId: 'ORD-S01',
        senderId: 'u1',
        senderName: 'أ',
        senderRole: UserRole.driver,
        content: 'ثانية',
      );

      final events = await _collect(
        repo.watchMessages('ORD-S01'),
        () async {},
      );
      final ids = events.first.map((m) => m.id).toSet();
      expect(ids.length, events.first.length);
    });
  });

  // ── markRead ──────────────────────────────────────────────────────────────────

  group('MockChatRepository – markRead', () {
    test('marks other-sender messages as read', () async {
      await repo.markRead('ORD-S01', 'mock-user-01');

      final events = await _collect(
        repo.watchMessages('ORD-S01'),
        () async {},
      );
      final driverMsgs =
          events.first.where((m) => m.senderId == 'driver-01');
      expect(driverMsgs.every((m) => m.isRead), isTrue);
    });

    test('own messages are not touched by markRead', () async {
      await repo.markRead('ORD-S01', 'mock-user-01');

      final events = await _collect(
        repo.watchMessages('ORD-S01'),
        () async {},
      );
      final mine =
          events.first.where((m) => m.senderId == 'mock-user-01');
      expect(mine, isNotEmpty);
    });

    test('returns Success for unknown room', () async {
      final result = await repo.markRead('ORD-GHOST', 'u1');
      expect(result.isSuccess, isTrue);
    });
  });

  // ── unreadCount ───────────────────────────────────────────────────────────────

  group('MockChatRepository – unreadCount', () {
    test('counts unread messages from other senders', () async {
      final count = await repo.unreadCount('ORD-S01', 'mock-user-01');
      expect(count, 1); // msg-03 from driver-01 is unread
    });

    test('returns 0 after markRead', () async {
      await repo.markRead('ORD-S01', 'mock-user-01');
      final count = await repo.unreadCount('ORD-S01', 'mock-user-01');
      expect(count, 0);
    });

    test('returns 0 for unknown order', () async {
      final count = await repo.unreadCount('ORD-GHOST', 'u1');
      expect(count, 0);
    });

    test('own messages are never counted as unread', () async {
      // driver-01's view: supplier msg-02 was isRead=true, so 0 unread
      final count = await repo.unreadCount('ORD-S01', 'driver-01');
      expect(count, 0);
    });
  });
}
