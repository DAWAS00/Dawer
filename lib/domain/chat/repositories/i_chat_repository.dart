import '../../../core/result/result.dart';
import '../../../data/models/user_role.dart';
import '../entities/chat_message.dart';

// ── IChatRepository ───────────────────────────────────────────────────────────
//
// Domain contract for all chat I/O. The current implementation is
// [MockChatRepository] (frontend-only, in-memory). To enable the backend:
//   1. Create SupabaseChatRepository implementing this interface.
//   2. Swap it in DawerApp's MultiProvider — no other code changes needed.

abstract interface class IChatRepository {
  /// Live stream of messages for a given order.
  /// Backend: subscribe to Supabase realtime on `chat_messages` filtered by roomId.
  Stream<List<ChatMessage>> watchMessages(String orderId);

  /// Append a new message. Returns failure on network / permission error.
  /// Backend: INSERT into `chat_messages`.
  Future<AppResult<void>> sendMessage({
    required String orderId,
    required String senderId,
    required String senderName,
    required UserRole senderRole,
    required String content,
  });

  /// Mark all messages in [orderId] as read for [userId].
  /// Backend: UPDATE chat_messages SET is_read = true WHERE room_id = orderId
  ///          AND sender_id != userId.
  Future<AppResult<void>> markRead(String orderId, String userId);

  /// Unread count badge for the chat icon.
  /// Backend: SELECT count(*) WHERE room_id = orderId AND sender_id != userId
  ///          AND is_read = false.
  Future<int> unreadCount(String orderId, String userId);
}
