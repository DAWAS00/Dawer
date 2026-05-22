import '../../../data/models/user_role.dart';

// ── ChatMessage entity ────────────────────────────────────────────────────────
//
// Mirrors the shape of the future `chat_messages` table row.
// Backend extension: add fromJson / toJson + Supabase realtime subscription
// when the backend is enabled. Do NOT add Supabase imports here — domain is
// backend-agnostic.

class ChatMessage {
  final String id;

  /// Ties this message to a specific order. Matches [Order.id].
  final String roomId;

  final String senderId;
  final String senderName;
  final UserRole senderRole;
  final String content;
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
    this.isRead = false,
  });

  ChatMessage copyWith({
    String? id,
    String? roomId,
    String? senderId,
    String? senderName,
    UserRole? senderRole,
    String? content,
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
      sentAt: sentAt ?? this.sentAt,
      isRead: isRead ?? this.isRead,
    );
  }
}
