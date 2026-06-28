import 'dart:io';

import '../../../core/result/result.dart';
import '../../../data/models/user_role.dart';
import '../entities/chat_message.dart';

// ── IChatRepository ───────────────────────────────────────────────────────────
//
// Domain contract for all order-scoped chat I/O. Implementations:
//   • [MockChatRepository] — frontend-only, in-memory.
//   • [SupabaseChatRepository] — Supabase Realtime + Storage.

abstract interface class IChatRepository {
  /// Live stream of messages for a given order.
  /// Backend: subscribe to Supabase realtime on `chat_messages` filtered by roomId.
  Stream<List<ChatMessage>> watchMessages(String orderId);

  /// Append a new text message. Returns failure on network / permission error.
  /// Backend: INSERT into `chat_messages` with kind='text'.
  Future<AppResult<void>> sendMessage({
    required String orderId,
    required String senderId,
    required String senderName,
    required UserRole senderRole,
    required String content,
  });

  /// Sends an image attachment. The implementation uploads [image] to storage
  /// and inserts a row with kind='image'; [caption] becomes `content`.
  /// Backend: upload to `chat-attachments` bucket → INSERT.
  Future<AppResult<void>> sendImage({
    required String orderId,
    required String senderId,
    required String senderName,
    required UserRole senderRole,
    required File image,
    String? caption,
  });

  /// Sends a location pin. [label] becomes `content`; lat/lng carry the point.
  /// Backend: INSERT with kind='location'.
  Future<AppResult<void>> sendLocation({
    required String orderId,
    required String senderId,
    required String senderName,
    required UserRole senderRole,
    required double lat,
    required double lng,
    String? label,
  });

  /// Mark all messages in [orderId] as read for [userId].
  /// Backend: UPDATE chat_messages SET is_read = true WHERE room_id = orderId
  ///          AND sender_id != userId.
  Future<AppResult<void>> markRead(String orderId, String userId);

  /// Unread count badge for the chat icon.
  /// Backend: SELECT count(*) WHERE room_id = orderId AND sender_id != userId
  ///          AND is_read = false.
  Future<int> unreadCount(String orderId, String userId);

  /// Broadcasts a "typing" pulse to other room participants.
  /// Fire-and-forget — implementations may no-op (mock) or use Supabase Broadcast.
  Future<void> broadcastTyping(String orderId, String senderId);

  /// Stream that emits whenever someone OTHER than [excludeUserId] is typing.
  /// Each emission = one typing pulse; caller sets its own 4-second dismiss timer.
  Stream<void> watchTyping(String orderId, String excludeUserId);
}
