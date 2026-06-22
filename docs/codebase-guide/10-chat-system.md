# 10. Order Chat System

## Overview

Every order has a dedicated 1:1 chat room between the customer (supplier or restaurant) and the assigned driver. Chat is order-scoped — one room per order ID. The room is read-only once the order reaches `completed` or `cancelled`, but history is always visible.

Chat was added as a complete system: domain interface → two implementations (mock + Supabase) → ViewModel → View → Widgets.

---

## Architecture

```
domain/chat/
  entities/chat_message.dart      ← ChatMessage, ChatMessageKind
  repositories/i_chat_repository.dart  ← IChatRepository interface

data/chat/
  mock_chat_repository.dart       ← in-memory, dev/test
  supabase_chat_repository.dart   ← Supabase Realtime + Storage

ui/features/chat/
  viewmodels/chat_viewmodel.dart  ← ChatViewModel (ChangeNotifier)
  views/chat_view.dart            ← full-screen chat screen
  widgets/chat_bubble.dart        ← BiDi-aware message bubble
  widgets/chat_input_bar.dart     ← text field + attachment buttons
```

The IChatRepository is bound in `main.dart`. Currently `MockChatRepository` is wired when Supabase is unavailable; `SupabaseChatRepository` is used when `useSupabase = true`.

---

## Domain Contract: IChatRepository

```dart
// lib/domain/chat/repositories/i_chat_repository.dart
abstract interface class IChatRepository {
  Stream<List<ChatMessage>> watchMessages(String orderId);

  Future<AppResult<void>> sendMessage({
    required String orderId,
    required String senderId,
    required String senderName,
    required UserRole senderRole,
    required String content,
  });

  Future<AppResult<void>> sendImage({
    required String orderId,
    required String senderId,
    required String senderName,
    required UserRole senderRole,
    required File image,
    String? caption,
  });

  Future<AppResult<void>> sendLocation({
    required String orderId,
    required String senderId,
    required String senderName,
    required UserRole senderRole,
    required double lat,
    required double lng,
    String? label,
  });

  Future<AppResult<void>> markRead(String orderId, String userId);
  Future<int> unreadCount(String orderId, String userId);

  Future<void> broadcastTyping(String orderId, String senderId);
  Stream<void> watchTyping(String orderId, String excludeUserId);
}
```

---

## ChatMessage Entity

```dart
// lib/domain/chat/entities/chat_message.dart
enum ChatMessageKind { text, image, location, system }

class ChatMessage {
  final String id;
  final String roomId;        // = orderId
  final String senderId;
  final String senderName;
  final UserRole senderRole;
  final String content;       // text body / caption / label / system text
  final ChatMessageKind kind;
  final String? attachmentUrl; // for kind == image
  final double? lat;           // for kind == location
  final double? lng;
  final String? translationAr; // Phase 7: auto-translate cache
  final String? translationEn;
  final DateTime sentAt;
  final bool isRead;
}
```

`kind` mirrors the `kind` column added in `supabase/migrations/00005_chat_media.sql`.

---

## Supabase Database Schema

Migration `00003_chat.sql` creates:

```sql
CREATE TABLE chat_messages (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  room_id     UUID NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
  sender_id   UUID NOT NULL REFERENCES public.profiles(auth_id),
  sender_name TEXT NOT NULL,
  sender_role user_role NOT NULL,
  content     TEXT NOT NULL,
  kind        TEXT NOT NULL DEFAULT 'text',
  attachment_url TEXT,
  lat         DOUBLE PRECISION,
  lng         DOUBLE PRECISION,
  is_read     BOOLEAN NOT NULL DEFAULT false,
  sent_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

RLS: participants (supplier, driver) can SELECT their own room. Only sender can INSERT. UPDATE is limited to `is_read`.

Migration `00005_chat_media.sql` adds the `chat-attachments` storage bucket:
- Private bucket (not public)
- Images only (`image/jpeg`, `image/png`, `image/webp`)
- 5 MB per file
- Participant-scoped read + write policies

---

## SupabaseChatRepository

Key behaviors:

1. **watchMessages** — subscribes to `chat_messages` filtered by `room_id` using Supabase Realtime. Emits a full sorted list on every INSERT/UPDATE.
2. **sendMessage** — plain `INSERT` with `kind = 'text'`.
3. **sendImage** — uploads the `File` to the `chat-attachments` bucket (path: `{orderId}/{uuid}.jpg`), then inserts a row with `kind = 'image'` and `attachment_url` pointing to the signed storage URL.
4. **sendLocation** — inserts a row with `kind = 'location'`, `lat`, `lng`.
5. **broadcastTyping / watchTyping** — uses Supabase Realtime Broadcast on channel `chat:{orderId}:typing`. Fire-and-forget; no DB row.
6. **markRead** — bulk UPDATE `is_read = true WHERE room_id = ? AND sender_id != ?`.

---

## ChatViewModel

```dart
// lib/ui/features/chat/viewmodels/chat_viewmodel.dart
class ChatViewModel extends ChangeNotifier {
  // Exposes:
  List<ChatMessage> get messages       // sorted ascending by sentAt
  bool get isLoading
  bool get isSending
  bool get isOtherTyping              // set true for 4s after each typing pulse
  AppFailure? get lastError
  bool get isRoomLocked               // true when order status is completed/cancelled
  String get otherPartyName
  String get orderStatusLabel

  // Actions:
  Future<void> sendText(String content)
  Future<void> sendImage(File image, {String? caption})
  Future<void> sendLocation(double lat, double lng, {String? label})
  void startTyping()                  // debounced — only broadcasts once per 3s
}
```

`isRoomLocked` is derived from the linked `Order.status`. When locked, `chat_input_bar.dart` renders a "Chat ended" banner instead of the text field.

---

## ChatView

`ChatView` is pushed from `OrderDetailsView` via the chat icon in the AppBar. It receives `orderId`, `currentUserId`, `currentUserName`, `currentUserRole`, and the `Order`.

Structure:
- AppBar: other party's name + order status chip
- Pinned `OrderContextCard` showing waste type, pickup address, and order status
- `ListView.builder` of `ChatBubble` widgets (reversed, new messages at bottom)
- `ChatInputBar` with text field, image picker, and location sender

---

## ChatBubble

`ChatBubble` renders differently per `ChatMessageKind`:

| Kind | Render |
|---|---|
| `text` | Standard speech bubble, BiDi text alignment |
| `image` | Tappable thumbnail with optional caption below |
| `location` | Map pin card with lat/lng coordinates and optional label |
| `system` | Centered grey pill (no bubble, no avatar) |

Sent messages align right; received messages align left. Arabic content uses `TextDirection.rtl`.

---

## Optimistic Send

`sendText`, `sendImage`, `sendLocation` use optimistic updates:

1. Insert a temporary `ChatMessage` with a fake ID (`optimistic-{timestamp}`) and `sentAt = now()` into the local list.
2. Call the repository method.
3. On success: the Realtime subscription will deliver the real row (which replaces the optimistic one by matching content + sender).
4. On failure: show `lastError` and remove the optimistic message.

---

## How to Add Chat to an Order Screen

```dart
// In any order detail screen:
IconButton(
  icon: const Icon(Icons.chat_bubble_outline),
  onPressed: () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ChatView(
        orderId: order.id,
        currentUserId: session.userId,
        currentUserName: session.userName,
        currentUserRole: session.role,
        order: order,
      ),
    ),
  ),
)
```

Provide `IChatRepository` via `context.read<IChatRepository>()` in `ChatViewModel`.

---

## What Is Not Yet Done

| Gap | Notes |
|---|---|
| Unread badge on order cards | `unreadCount()` is implemented in repo but not called anywhere in the card widgets |
| Push notification on new message | `INotificationService` is a no-op; FCM wiring is missing for chat events |
| Message pagination | `watchMessages` streams all messages; long threads will load everything at once |
| Auto-translate (Phase 7) | `translationAr` / `translationEn` fields exist in the entity; the translation service is not wired |
| Voice messages | Not started |
