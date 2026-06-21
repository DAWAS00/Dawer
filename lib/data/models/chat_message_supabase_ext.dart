import '../../domain/chat/entities/chat_message.dart';
import 'user_role.dart';

/// Data-layer (de)serialization between `ChatMessage` and the `chat_messages`
/// Postgres row. Mirrors the `order_supabase_ext.dart` pattern — the entity
/// itself stays free of Supabase/JSON concerns.
//
/// Column ↔ field mapping (see migration `00003_chat.sql`):
///   id            → id            (uuid)
///   room_id       → roomId        (uuid, == Order.id)
///   sender_id     → senderId      (uuid, public.users.id)
///   sender_name   → senderName    (text)
///   sender_role   → senderRole    (user_role enum: 'driver'|'supplier'|'recyclingCo')
///   content       → content       (text)
///   sent_at       → sentAt        (timestamptz)
///   is_read       → isRead        (bool)
extension ChatMessageSupabaseExt on ChatMessage {
  Map<String, dynamic> toSupabaseMap() {
    return <String, dynamic>{
      'room_id': roomId,
      'sender_id': senderId,
      'sender_name': senderName,
      'sender_role': senderRole.dbValue,
      'content': content,
      'sent_at': sentAt.toUtc().toIso8601String(),
      'is_read': isRead,
    };
  }
}

/// Parses a `chat_messages` row into a [ChatMessage].
/// Tolerant of missing/null fields so a partial realtime payload doesn't crash.
ChatMessage chatMessageFromSupabaseJson(Map<String, dynamic> row) {
  final roleStr = row['sender_role'] as String? ?? 'supplier';
  final role = UserRole.values.firstWhere(
    (r) => r.dbValue == roleStr,
    orElse: () => UserRole.supplier,
  );

  final sentAtRaw = row['sent_at'];
  DateTime sentAt;
  if (sentAtRaw is String) {
    sentAt = DateTime.parse(sentAtRaw);
  } else if (sentAtRaw is DateTime) {
    sentAt = sentAtRaw;
  } else {
    sentAt = DateTime.now().toUtc();
  }

  return ChatMessage(
    id: (row['id'] ?? '').toString(),
    roomId: (row['room_id'] ?? '').toString(),
    senderId: (row['sender_id'] ?? '').toString(),
    senderName: (row['sender_name'] as String?) ?? '',
    senderRole: role,
    content: (row['content'] as String?) ?? '',
    sentAt: sentAt,
    isRead: (row['is_read'] as bool?) ?? false,
  );
}
