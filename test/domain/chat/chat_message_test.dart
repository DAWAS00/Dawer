import 'package:flutter_test/flutter_test.dart';
import 'package:dwaar/data/models/user_role.dart';
import 'package:dwaar/domain/chat/entities/chat_message.dart';

void main() {
  final base = ChatMessage(
    id: 'msg-1',
    roomId: 'ORD-001',
    senderId: 'user-1',
    senderName: 'محمد',
    senderRole: UserRole.supplier,
    content: 'مرحباً',
    sentAt: DateTime(2025, 1, 1, 10, 0),
  );

  // ── Defaults ──────────────────────────────────────────────────────────────────

  group('ChatMessage – defaults', () {
    test('isRead defaults to false', () {
      expect(base.isRead, isFalse);
    });

    test('all required fields are stored correctly', () {
      expect(base.id, 'msg-1');
      expect(base.roomId, 'ORD-001');
      expect(base.senderId, 'user-1');
      expect(base.senderName, 'محمد');
      expect(base.senderRole, UserRole.supplier);
      expect(base.content, 'مرحباً');
    });
  });

  // ── copyWith ──────────────────────────────────────────────────────────────────

  group('ChatMessage – copyWith', () {
    test('returns new instance with updated field', () {
      final updated = base.copyWith(isRead: true);
      expect(updated.isRead, isTrue);
      expect(updated.id, base.id); // other fields unchanged
    });

    test('content update does not affect other fields', () {
      final updated = base.copyWith(content: 'رسالة جديدة');
      expect(updated.content, 'رسالة جديدة');
      expect(updated.senderId, base.senderId);
      expect(updated.senderRole, base.senderRole);
      expect(updated.sentAt, base.sentAt);
    });

    test('copyWith with no args returns equivalent object', () {
      final copy = base.copyWith();
      expect(copy.id, base.id);
      expect(copy.roomId, base.roomId);
      expect(copy.content, base.content);
      expect(copy.isRead, base.isRead);
    });

    test('senderId can be changed', () {
      final updated = base.copyWith(senderId: 'driver-99');
      expect(updated.senderId, 'driver-99');
    });

    test('senderRole can be changed', () {
      final updated = base.copyWith(senderRole: UserRole.driver);
      expect(updated.senderRole, UserRole.driver);
    });

    test('sentAt can be changed', () {
      final newTime = DateTime(2025, 6, 15, 14, 30);
      final updated = base.copyWith(sentAt: newTime);
      expect(updated.sentAt, newTime);
    });
  });
}
