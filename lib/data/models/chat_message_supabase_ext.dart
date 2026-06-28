import '../../domain/chat/entities/chat_message.dart';
import 'user_role.dart';

/// Data-layer (de)serialization between `ChatMessage` and the `chat_messages`
/// Postgres row. Mirrors the `order_supabase_ext.dart` pattern — the entity
/// itself stays free of Supabase/JSON concerns.
//
/// Column ↔ field mapping (migrations `00003_chat.sql` + `00005_chat_media.sql`):
///   id            → id            (uuid)
///   room_id       → roomId        (uuid, == Order.id)
///   sender_id     → senderId      (uuid, profiles.auth_id)
///   sender_name   → senderName    (text)
///   sender_role   → senderRole    (user_role enum)
///   content       → content       (text — body / caption / label / system text)
///   kind          → kind          (text: 'text'|'image'|'location'|'system')
///   attachment_url→ attachmentUrl (text — image storage URL)
///   lat / lng     → lat / lng     (double precision — location kind)
///   translation_ar→ translationAr(text — cached Arabic translation)
///   translation_en→ translationEn(text — cached English translation)
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
      'kind': kind.name,
      if (attachmentUrl != null) 'attachment_url': attachmentUrl,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (translationAr != null) 'translation_ar': translationAr,
      if (translationEn != null) 'translation_en': translationEn,
      'sent_at': sentAt.toUtc().toIso8601String(),
      'is_read': isRead,
    };
  }
}

/// Parses a `chat_messages` row into a [ChatMessage].
/// Tolerant of missing/null fields so a partial realtime payload doesn't crash,
/// and so historical rows (pre-`00005`) without a `kind` still parse as `text`.
ChatMessage chatMessageFromSupabaseJson(Map<String, dynamic> row) {
  final roleStr = row['sender_role'] as String? ?? 'supplier';
  final role = UserRole.values.firstWhere(
    (r) => r.dbValue == roleStr,
    orElse: () => UserRole.supplier,
  );

  final kindStr = row['kind'] as String? ?? 'text';
  final kind = ChatMessageKind.values.firstWhere(
    (k) => k.name == kindStr,
    orElse: () => ChatMessageKind.text,
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
    kind: kind,
    attachmentUrl: row['attachment_url'] as String?,
    lat: (row['lat'] as num?)?.toDouble(),
    lng: (row['lng'] as num?)?.toDouble(),
    translationAr: row['translation_ar'] as String?,
    translationEn: row['translation_en'] as String?,
    sentAt: sentAt,
    isRead: (row['is_read'] as bool?) ?? false,
  );
}
