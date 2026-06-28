# Rider ↔ Customer Chat Redesign Plan — Dwaar (دوّر)

> **Goal:** transform the current text-only, no-notification, no-media chat into
> a best-in-class rider↔customer chat purpose-built for waste-recycling
> logistics in Jordan. Based on research into Uber, Talabat, Careem, DoorDash,
> Instacart, and WhatsApp + a full audit of the existing chat domain.
>
> **Status:** Design — ready for review before implementation.

---

## The core principle

> **Chat exists to coordinate the pickup — gate codes, bin locations, waste
> readiness, access, timing — not to socialize. Every feature must reduce the
> number of "where exactly?" / "is it ready?" messages.**

The waste-logistics use case differs from food delivery: instead of "leave at
door," it's "which bin is yours in the shared yard," "the truck can't fit the
alley — meet me at the corner," "is the cardboard dry or wet," and "what's the
gate code." The chat should collapse these into **one-tap actions and visual
proof**, not prose.

---

## What's wrong today (evidence-backed, from the code audit)

| # | Problem | Evidence |
|---|---|---|
| 1 | **No push notifications** — a backgrounded rider/customer never knows a message arrived | Zero FCM/APNs wiring; `flutter_local_notifications` declared in pubspec but never initialized |
| 2 | **Unread-count badge never shown** — `unreadCount()` exists in the repo but has zero UI callers | `i_chat_repository.dart:35` docstring says "for the chat icon badge"; grep of `lib/ui` finds 0 callers |
| 3 | **Text-only** — no photo, location, voice, or system messages | `ChatMessage` has no `kind`/`type` field; `00003_chat.sql` has no media/location columns; input bar has no attach button |
| 4 | **Static quick replies** — same 7 chips regardless of order state | `chat_view.dart:74-88` hardcoded Arabic; don't change when status is "arrived" vs "en route" |
| 5 | **No order context in the thread** — AppBar shows only `#orderId` | `chat_view.dart:_ChatAppBar`; no waste type/volume/address/gate-code card pinned in the conversation |
| 6 | **No typing indicator, no "delivered" receipt** | Bubble has only unread/read ticks (`done`/`done_all`); no intermediate "delivered" state |
| 7 | **No pagination** — `watchMessages` fetches the entire room history | `supabase_chat_repository.dart:28-35` has no `.limit()`/cursor; will lag on long threads |
| 8 | **Not locked after order completes** — a finished order's room stays writable | RLS INSERT policy (`00003_chat.sql:79`) checks participant but not `orders.status` |
| 9 | **No RTL auto-direction on message content** — an English message from an expat driver renders forced-RTL | `chat_bubble.dart` hardcodes `textAlign: right`; Dwaar's own RTL plan TASK-001 calls for per-message auto-detection |
| 10 | **Optimistic-UI gap** — sent message appears only after the realtime round-trip | `chat_viewmodel.dart:69-80` doesn't insert locally; on slow networks the message seems to vanish |
| 11 | **Dev banner always shown** even with Supabase active | `chat_view.dart:_frontendOnlyBanner` isn't conditional on the repo binding |
| 12 | **Hardcoded Arabic** — 7 quick replies + error strings, only 5 ARB keys used | `chat_view.dart:77-86`, `supabase_chat_repository.dart:48` |

---

## The redesigned chat — feature set (ranked by impact for waste logistics)

### Tier 1 — ship first (highest impact, addresses the biggest gaps)

| # | Feature | Why it ranks here | Proven in |
|---|---|---|---|
| **1** | **Push notifications (FCM) on new message + deep-link to room** | Without push, the chat is useless in the field — drivers aren't watching the screen. The single biggest gap. | Uber, DoorDash, Talabat (all) |
| **2** | **Photo sharing** (proof-of-pickup, "which bin / where's the pile", gate access) | The #1 transferable feature. A driver photographing the waste pile so the supplier confirms volume/type replaces endless "where exactly?" text. Supplier photographs the gate/access. | DoorDash drop-off photos; Instacart replacement-item photos |
| **3** | **Order-state-aware quick replies** (not static) | Quick replies that change with order status collapse 80% of coordination into one tap: *Assigned* → "عنوان الموقع صحيح؟"; *En route* → "أنا في الطريق"; *Arrived* → "وصلت، أين الحاوية؟ / ما رمز الباب؟"; *Picked up* → "تم التحميل، شكراً". | Uber One-Click Chat (contextual ML); DoorDash one-tap replies |
| **4** | **Unread-count badge on every chat entry point** | `unreadCount()` already exists in the repo — just needs UI wiring on order cards, tracking screen, and a future inbox. | Every chat app |
| **5** | **Order-context card pinned at top of thread** (waste type, volume, pickup address, scheduled window) | Both parties coordinate *about the order*; surfacing it in-chat stops "what did I order again?" and back-and-forth. | Instacart (chat on Order Status page); DoorDash (chat tied to order) |

### Tier 2 — ship next (high value, moderate effort)

| # | Feature | Why | Proven in |
|---|---|---|---|
| **6** | **"Share location / pin" as a special message type** | "I'm at the side gate, not on Maps" / "truck can't fit, meet me at the corner." A map-pin message beats prose. | WhatsApp live location; Uber pickup-point |
| **7** | **Typing indicator** (Supabase Realtime Broadcast, ephemeral) | Reduces "did they see it?" anxiety during time-sensitive gate-code exchanges. Low cost via Broadcast. | WhatsApp, iMessage |
| **8** | **Room locked / read-only after pickup completes** | Prevents post-job harassment; matches masked-number expiry norm. Cheap via RLS gated on `orders.status`. | Uber (number expires post-delivery) |
| **9** | **Auto-translate toggle (Arabic ↔ English)** | Jordan's driver pool includes expats; suppliers may prefer either language. One-tap translate per message. | Uber tap-to-translate |
| **10** | **Optimistic send + send-failure UI** | Sent message appears instantly; on failure shows a retry tap. Fixes the "vanishing message" feel on slow networks. | WhatsApp, Telegram |
| **11** | **Cursor pagination + virtualized reverse list** | Long/photо-heavy threads will lag the current plain `ListView`. Use keyset pagination on `sent_at`. | Supabase cursor pattern; DoorDash offline/sync |

### Tier 3 — polish / differentiation (lower priority, higher effort)

| # | Feature | Why | Proven in |
|---|---|---|---|
| **12** | **Voice messages (+ Arabic transcription)** | MENA drivers strongly prefer voice; Arabic typing is slow. Likely higher ROI than typing indicators for the driver demographic. | WhatsApp (7B/day) |
| **13** | **Per-message BiDi auto-direction** | An English message from an expat driver must render LTR inside an Arabic thread. Dwaar's own RTL plan already calls for this. | W3C BiDi; Dwaar `process-rtl-arabic-chat-1.md` |
| **14** | **Conversations list / inbox** | A driver juggling multiple pickups has no aggregate view — chat is only per-order. A "my active conversations" screen helps. | Uber, WhatsApp |
| **15** | **WhatsApp Business API bridge for notifications** (hybrid) | Jordanian users live on WhatsApp; a new-message template that deep-links back respects actual behavior rather than fighting it. | FedEx KSA; 8x8/LINK Mobility/Sinch patterns |

### Explicitly deferred / out of scope
- **In-app voice/video calling** (relay-number masking infra is heavy; in-app chat + external phone call is sufficient for v1).
- **Profanity/profanity filter** — defer until moderation complaints arise; the rating system is the first soft-moderation lever.
- **Emoji picker / rich text** — plain text + photos + voice covers the logistics use case.

---

## Architecture: the `ChatMessage` redesign (the cascade)

The **entity is the choke point.** Adding photo, location, voice, or system
messages all require a **message-kind** field + a payload. This cascades into
the schema, the serialization, and the bubble widget. Plan it first.

### New `ChatMessage` shape (additive — old text messages still work)

```dart
enum ChatMessageKind {
  text,       // existing
  image,      // photo attachment (storage URL + thumbnail)
  location,   // lat/lng pin + optional label
  system,     // order-state events ("Order accepted", "Driver arrived")
}

class ChatMessage {
  final String id;
  final String roomId;
  final String senderId;
  final String senderName;
  final UserRole senderRole;
  final String content;            // text body, OR caption for image/location
  final ChatMessageKind kind;      // NEW (default text)
  final String? attachmentUrl;     // NEW: image storage URL (image kind)
  final double? lat;               // NEW: location kind
  final double? lng;               // NEW: location kind
  final String? translationAr;     // NEW: cached Arabic translation (auto-translate)
  final String? translationEn;     // NEW: cached English translation
  final DateTime sentAt;
  final bool isRead;
  // future: replyToId, editedAt, deletedAt
}
```

### Schema migration (`00005_chat_media.sql`)

```sql
ALTER TABLE public.chat_messages
  ADD COLUMN IF NOT EXISTS kind           text NOT NULL DEFAULT 'text'
    CHECK (kind IN ('text','image','location','system')),
  ADD COLUMN IF NOT EXISTS attachment_url text,
  ADD COLUMN IF NOT EXISTS lat            double precision,
  ADD COLUMN IF NOT EXISTS lng            double precision,
  ADD COLUMN IF NOT EXISTS translation_ar text,
  ADD COLUMN IF NOT EXISTS translation_en text;

-- Lock the room when the order is terminal: only allow INSERTs while the order
-- is active. Cheapest fix for the "post-job harassment" gap.
CREATE OR REPLACE FUNCTION public.can_chat_in_order(p_order_id uuid)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.orders
    WHERE id = p_order_id
      AND status NOT IN ('completed', 'cancelled')
  );
$$;

-- Replace the INSERT policy to also require an active order.
DROP POLICY IF EXISTS "chat_participant_insert" ON public.chat_messages;
CREATE POLICY "chat_participant_insert" ON public.chat_messages
  FOR INSERT TO authenticated WITH CHECK (
    sender_id = public.current_user_id()
    AND public.current_user_is_order_participant(room_id)
    AND public.can_chat_in_order(room_id)
  );
```

### Storage bucket for chat images
```sql
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES ('chat-attachments', 'chat-attachments', false, 5242880,
        ARRAY['image/jpeg','image/png','image/webp'])
ON CONFLICT (id) DO NOTHING;
-- RLS: participants can write `{roomId}/{msgId}.<ext>`, participants can read.
```

### Typing indicator (ephemeral — NOT persisted)
Use **Supabase Realtime Broadcast** (not `postgres_changes`). Typing is
fire-and-forget over the channel `chat:{roomId}` with event `typing`. The DB
never stores it. Auto-dismiss after ~4s of no input. This is the documented
Supabase pattern and keeps the schema clean.

---

## Screen flow & UI structure

### Chat screen (redesigned `ChatView`)

```
┌─────────────────────────────────────────────────────┐
│ ← │ دردشة · #ORD-001                                │ ← AppBar: title + order#
│   │ خالد محمد (سائق) · في الطريق                     │ ← subtitle: other party + ETA/status
├─────────────────────────────────────────────────────┤
│ ┌─────────────────────────────────────────────────┐ │
│ │ 📦 بلاستيك · 15 كجم                              │ │ ← PINNED order-context card
│ │ 📍 عمان، طارق · رمز الباب: 1234                  │ │   (waste type, volume, address, gate code)
│ └─────────────────────────────────────────────────┘ │
│                                                      │
│  [خالد]: أنا في الطريق، أين الحاوية بالضبط؟          │ ← incoming bubble (LTR-auto if English)
│                                            [أنت]:   │ ← outgoing bubble (RTL)
│                                            2:15 PM ✓✓│ ← read receipts (sent ✓ / delivered ✓✓ / read ✓✓blue)
│                                                      │
│  ┌──────┐                                            │ ← image message (thumbnail, tap to enlarge)
│  │ 📷   │  هذه هي الحاوية الزرقاء                    │
│  └──────┘                                            │
│                                                      │
│  [خالد is typing...]                                │ ← typing indicator (ephemeral)
│                                                      │
│ ────────────────── اليوم ──────────────────          │ ← date separator (grouped messages)
├─────────────────────────────────────────────────────┤
│ [📷] [أنا في الطريق] [وصلت، أين الحاوية؟] [▶]        │ ← state-aware quick replies + attach + send
│ [اكتب رسالة...                                  ]   │
└─────────────────────────────────────────────────────┘
```

**Key UI changes from current:**
- AppBar gains a subtitle: other-party name + role + live order status/ETA.
- Pinned order-context card (collapsible) at the top of the list.
- Message bubbles render by `kind`: text (current), image (thumbnail + caption), location (mini-map + "open in Maps" button), system (centered, grey).
- Quick-reply chips change with order status (the `vm` exposes the order; chips are built from a status→chips map).
- Attach button (📷) in the input bar opens a sheet: photo / location / (future: voice).
- Typing indicator above the input.
- Date separators + message grouping.
- Per-message BiDi: detect Arabic script → RTL, else LTR.

---

## Implementation phases (in dependency order)

### Phase 1 — Backend: message-kind + schema + storage (no UX change)
1. **`00005_chat_media.sql`** migration: `kind`, `attachment_url`, `lat`, `lng`, `translation_ar/en` columns; `can_chat_in_order` function; lock-room-on-complete INSERT policy; `chat-attachments` storage bucket + RLS.
2. **`ChatMessage` entity**: add `kind`, `attachmentUrl`, `lat`, `lng`, `translationAr`, `translationEn` fields + `ChatMessageKind` enum. Additive — old text messages still parse.
3. **`chat_message_supabase_ext.dart`**: extend `toSupabaseMap`/`fromJson` for the new fields (tolerant defaults).
4. **`IChatRepository`**: add `Future<AppResult<void>> sendImage({orderId, sender..., File image, String? caption})` and `sendLocation({orderId, sender..., double lat, double lng, String? label})`. Both impls follow.
5. **`SupabaseChatRepository`**: implement `sendImage` (upload to `chat-attachments` → INSERT `kind=image`), `sendLocation` (INSERT `kind=location`).

### Phase 2 — Push notifications + unread badge (the biggest UX gap)
1. **FCM setup**: add `firebase_messaging` to pubspec (or use Supabase's push via Edge Function if FCM is too heavy). Create a `00006_chat_notifications.sql` trigger that fires a `send_push` Edge Function on `chat_messages` INSERT (new Edge Function — `send_chat_push`).
2. **`INotificationService`**: extend to handle chat deep-links (`orderId` payload → tap opens `ChatView`).
3. **Unread badge**: wire `unreadCount()` onto the chat buttons in `order_action_buttons.dart`, `order_customer_card.dart`, `order_driver_card.dart`, `order_tracking_card.dart`. A small `Badge` widget wrapping the chat icon.
4. **Remove `_frontendOnlyBanner`** — it's no longer frontend-only.

### Phase 3 — UI: order-context card + state-aware quick replies + optimistic send
1. **Pinned order-context card** at the top of `_MessageList`: waste types, weight, pickup address, (future: gate code from order notes). Collapsible.
2. **State-aware quick replies**: move from hardcoded `chat_view.dart:74-88` to a `quickRepliesForStatus(OrderStatus, UserRole)` builder. Localize via ARB.
3. **Optimistic send**: `chat_viewmodel.send()` inserts locally with a temp `sending` status, then reconciles on the realtime event. Surface failures with a retry tap.
4. **AppBar subtitle**: other-party name + role + current order status (reads from `AppOrderStore`).

### Phase 4 — UI: image + location messages
1. **Attach button** in `ChatInputBar`: opens a sheet (photo / location).
2. **`ChatBubble` renders by `kind`**: image (thumbnail + tap-to-enlarge via `cached_network_image`), location (mini-map via `google_maps_flutter` or a static-map thumbnail + "open in Maps").
3. **`sendImage` / `sendLocation`** wired from the input sheet.

### Phase 5 — Typing indicator + receipts + pagination
1. **Typing indicator**: Supabase Realtime Broadcast on channel `chat:{roomId}`; `ChatViewModel` exposes an `isTyping` stream; UI shows "يكتب الآن...".
2. **Receipts**: add "delivered" (grey ✓✓) between sent (✓) and read (blue ✓✓). Requires a `delivered_at` column or a realtime ack — or approximate via "the other party's app received the realtime event."
3. **Cursor pagination**: `watchMessages` takes a `cursor`/`limit`; `_MessageList` becomes reverse-ordered with `reverse: true`, loads older on scroll-to-top.

### Phase 6 — Localization + RTL + polish
1. Move the 7 quick replies + error strings to ARB (`app_ar.arb` + `app_en.arb`).
2. Per-message BiDi auto-direction (detect Arabic script → RTL).
3. Date separators + message grouping.
4. Remove dead `orderChatComingSoon` ARB string.
5. Empty-state first-message prompt ("قل مرحباً للسائق" + first quick-reply chip).

### Phase 7 — Differentiators (lower priority)
- **Auto-translate** (Gemini-powered, one-tap per message, cached in `translation_ar/en`).
- **Voice messages** (`record` package + storage bucket + Arabic transcription via Gemini).
- **Conversations inbox** (aggregate active rooms across orders).
- **WhatsApp Business API bridge** for notifications (strategic — needs a BSP like Unifonic/CEQUINS).

---

## Architecture decisions to make before coding

1. **FCM vs Supabase push**: adding `firebase_messaging` is the standard but adds Firebase setup (`google-services.json`, which the app currently lacks). Alternative: a Supabase Edge Function that calls FCM/APNs directly via the stored `fcm_token`. The Edge Function route avoids a Firebase dependency but needs a push provider account.

2. **Typing indicator channel**: Supabase Realtime Broadcast (ephemeral, no DB write) vs a `typing` table (persisted, more queryable). Broadcast is the documented pattern and keeps the schema clean — recommend Broadcast.

3. **Image storage**: dedicated `chat-attachments` bucket vs reusing `user-documents`. A dedicated bucket with participant-scoped RLS (room-scoped, not user-scoped) is cleaner — recommend new bucket.

4. **Location rendering**: full embedded `GoogleMap` (heavy, one per location message) vs a static-map thumbnail + "open in Maps" link. The thumbnail is lighter and sufficient for "here's the side gate" — recommend thumbnail + deep-link.

5. **Translation**: Gemini (already in the app for AI signup) vs Google Translate API. Gemini is already wired and free-tier-friendly — recommend Gemini with caching in the `translation_*` columns.

---

## What NOT to do (explicitly out of scope for v1)

- **In-app voice/video calling** — relay-number infra is heavy; in-app chat + the existing external "call" button suffices.
- **Profanity filter** — defer until moderation complaints arise; rating system is the soft-moderation lever.
- **Emoji/rich-text editor** — plain text + photos + voice covers the logistics use case.
- **Message editing** — a mistyped ETA is annoying but rare; delete-and-resend is sufficient for v1.

---

## Success metrics

- **Time-to-coordination drops**: median messages-per-order decreases because photo/location/state-replies collapse the "where exactly?" loop.
- **Push notification delivery rate** > 90% (FCM) on new messages.
- **Zero post-completion messages** (room-lock RLS enforced).
- **Chat works offline**: optimistic send queues; on reconnect, syncs.
- **All chat strings localized** (no hardcoded Arabic in the chat feature).

---

## Reference: research sources (key ones)

- **Uber One-Click Chat** (contextual quick replies): https://www.uber.com/us/en/blog/one-click-chat/
- **Uber seamless pickups** (auto-translate): https://www.uber.com/us/en/newsroom/seamless-pickups/
- **Careem call masking**: https://help.careem.com/hc/en-us/articles/360001609407
- **DoorDash Engineering – Building Chat** (in-app, order-scoped, offline sync): https://careersatdoordash.com/blog/building-chat-into-the-doordash-app/
- **DoorDash drop-off photos**: https://help.doordash.com/en-us/dashers/article/confirming-delivery-drop-off-photos
- **Instacart replacement-item photos** (closest analog to waste-pile confirmation): https://docs.instacart.com/connect/post-checkout_guide/concepts/replacement_flow/
- **WhatsApp 7B voice messages/day** (MENA voice preference): https://techcrunch.com/2022/03/30/people-are-sending-7-billion-voice-messages-on-whatsapp-every-day/
- **FedEx KSA WhatsApp last-mile** (MENA hybrid channel): https://www.itp.net/digital-culture/reimagining-the-last-mile-whatsapps-role-in-middle-easts-customer-experience-revolution
- **Supabase Flutter chat tutorial** (RLS + realtime patterns): https://supabase.com/blog/flutter-tutorial-building-a-chat-app
- **Supabase cursor pagination**: https://github.com/orgs/supabase/discussions/3938
- **WhatsApp typing indicator design** (ephemeral, XEP-0085): https://dev.to/gabrielanhaia/designing-whatsapps-typing-indicator-the-question-that-tests-your-real-time-skills-34k1

Full source list in the research notes.
