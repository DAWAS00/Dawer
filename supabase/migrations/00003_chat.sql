-- ─────────────────────────────────────────────────────────────────────────────
-- 00003_chat.sql — Order-scoped chat messages
--
-- One chat room per order (room_id = orders.id). All participants of an order
-- (supplier, driver, recycling company) share the room. Mirrors the `ChatMessage`
-- domain entity in lib/domain/chat/entities/chat_message.dart.
--
-- Realtime: added to the `supabase_realtime` publication so `watchMessages`
-- (`.stream(primaryKey: ['id']).eq('room_id', orderId)`) lights up live.
-- ─────────────────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS public.chat_messages (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  -- room_id = orders.id. UUID to match orders.id; the mock's 'ORD-S01' is
  -- dev-only and the live Order.id is a UUID string.
  room_id      uuid NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
  -- sender_id = public.profiles.auth_id (the app's user id = auth.uid(), as
  -- surfaced by IAuthRepository.currentSession.userId / AuthSession.userId).
  sender_id    uuid NOT NULL REFERENCES public.profiles(auth_id) ON DELETE CASCADE,
  -- Denormalized display name + role so a client can render a message without
  -- an extra users join; kept in sync by the app at insert time.
  sender_name  text NOT NULL,
  sender_role  user_role NOT NULL,
  content      text NOT NULL CHECK (char_length(content) > 0),
  sent_at      timestamptz NOT NULL DEFAULT now(),
  is_read      boolean NOT NULL DEFAULT false,
  created_at   timestamptz NOT NULL DEFAULT now()
);

-- watchMessages: ordered by sent_at within a room.
CREATE INDEX IF NOT EXISTS chat_messages_room_sent_idx
  ON public.chat_messages (room_id, sent_at);

-- unreadCount / markRead: filter by room + recipient (everyone but sender) + unread.
CREATE INDEX IF NOT EXISTS chat_messages_unread_idx
  ON public.chat_messages (room_id, sender_id, is_read)
  WHERE is_read = false;

-- ── Row-Level Security ───────────────────────────────────────────────────────
-- A participant may read / write in a room iff they are a party to that order:
--   supplier_id, driver_id (→ drivers.user_id), or company_id.
--
-- NOTE on id spaces: the app's `sender_id` / `AuthSession.userId` is
-- `public.users.id`, NOT `auth.users.id`. So RLS resolves the caller via the
-- existing `current_user_id()` helper (defined in 00001_initial_schema.sql),
-- which maps `auth.uid()` → `public.users.id`. This matches the RLS pattern
-- already used on `orders` (`supplier_id = current_user_id()`).
ALTER TABLE public.chat_messages ENABLE ROW LEVEL SECURITY;

-- Helper: is the given user (public.profiles.auth_id = auth.uid()) a participant
-- of the given order? orders.{supplier,driver,company}_id all reference
-- profiles(auth_id), so a direct equality check is sufficient.
CREATE OR REPLACE FUNCTION public.is_order_participant(
  p_order_id uuid,
  p_user_id uuid
) RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.orders o
    WHERE o.id = p_order_id
      AND (
        o.supplier_id = p_user_id
        OR o.company_id = p_user_id
        OR o.driver_id = p_user_id
      )
  );
$$;

-- Convenience: participant check for the CURRENT caller.
CREATE OR REPLACE FUNCTION public.current_user_is_order_participant(
  p_order_id uuid
) RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER AS $$
  SELECT public.is_order_participant(p_order_id, public.current_user_id());
$$;

CREATE POLICY "chat_participant_read" ON public.chat_messages
  FOR SELECT TO authenticated
  USING (public.current_user_is_order_participant(room_id));

CREATE POLICY "chat_participant_insert" ON public.chat_messages
  FOR INSERT TO authenticated WITH CHECK (
    -- The sender must be a participant, and the row's sender_id must be them.
    sender_id = public.current_user_id()
    AND public.current_user_is_order_participant(room_id)
  );

-- Only a participant may update rows (used for markRead on the recipient side).
CREATE POLICY "chat_recipient_update_read" ON public.chat_messages
  FOR UPDATE TO authenticated
  USING (public.current_user_is_order_participant(room_id))
  WITH CHECK (public.current_user_is_order_participant(room_id));

-- ── Realtime ─────────────────────────────────────────────────────────────────
-- Add to the realtime publication so `.stream(...)` pushes INSERT/UPDATE/DELETE
-- events to subscribed clients.
ALTER PUBLICATION supabase_realtime ADD TABLE public.chat_messages;
