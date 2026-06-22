import '../../../data/models/user_role.dart';

// ── ChatMessage entity ────────────────────────────────────────────────────────
//
// Mirrors the shape of the `chat_messages` table row. Backend-agnostic — do NOT
// add Supabase imports here; (de)serialization lives in the data layer
// (`chat_message_supabase_ext.dart`).

/// The kind of payload a [ChatMessage] carries. Mirrors the DB `kind` column
/// added in migration `00005_chat_media.sql`. Defaults to [text] so historical
/// messages (and any caller that doesn't specify) keep working.
enum ChatMessageKind {
  /// Plain text body in [ChatMessage.content].
  text,

  /// Image attachment at [ChatMessage.attachmentUrl]; [content] is the caption.
  image,

  /// Geographic pin at [ChatMessage.lat]/[lng]; [content] is an optional label.
  location,

  /// Order-state event rendered centered/greyed, e.g. "Order accepted".
  /// [content] holds the localized text; sender fields are the system actor.
  system,
}

class ChatMessage {
  final String id;

  /// Ties this message to a specific order. Matches [Order.id].
  final String roomId;

  final String senderId;
  final String senderName;
  final UserRole senderRole;

  /// Text body (for [ChatMessageKind.text]), caption (for [image]), label
  /// (for [location]), or localized system text (for [system]).
  final String content;

  /// Classifies the payload. See [ChatMessageKind].
  final ChatMessageKind kind;

  /// Storage URL for the attached image (only for [ChatMessageKind.image]).
  final String? attachmentUrl;

  /// Location pin latitude (only for [ChatMessageKind.location]).
  final double? lat;

  /// Location pin longitude (only for [ChatMessageKind.location]).
  final double? lng;

  /// Cached Arabic translation of [content] (for auto-translate, Phase 7).
  final String? translationAr;

  /// Cached English translation of [content] (for auto-translate, Phase 7).
  final String? translationEn;

  final DateTime sentAt;
  final bool isRead;

  const ChatMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.content,
    required this.sentAt,
    this.kind = ChatMessageKind.text,
    this.attachmentUrl,
    this.lat,
    this.lng,
    this.translationAr,
    this.translationEn,
    this.isRead = false,
  });

  ChatMessage copyWith({
    String? id,
    String? roomId,
    String? senderId,
    String? senderName,
    UserRole? senderRole,
    String? content,
    ChatMessageKind? kind,
    String? attachmentUrl,
    double? lat,
    double? lng,
    String? translationAr,
    String? translationEn,
    DateTime? sentAt,
    bool? isRead,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderRole: senderRole ?? this.senderRole,
      content: content ?? this.content,
      kind: kind ?? this.kind,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      translationAr: translationAr ?? this.translationAr,
      translationEn: translationEn ?? this.translationEn,
      sentAt: sentAt ?? this.sentAt,
      isRead: isRead ?? this.isRead,
    );
  }
}
