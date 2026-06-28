-- ─────────────────────────────────────────────────────────────────────────────
-- 00005_chat_media.sql — Rich chat: image / location / system messages + room lock
--
-- Adds a `kind` column to classify messages (text/image/location/system) and
-- payload columns for non-text kinds. Also locks the room when the order is
-- terminal (completed/cancelled) so neither party can message after the job
-- ends — matches the masked-number-expiry pattern from Uber/Careem/DoorDash.
--
-- See docs/chat-redesign-plan.md.
-- ─────────────────────────────────────────────────────────────────────────────

-- ── Message kind + payload columns ───────────────────────────────────────────
ALTER TABLE public.chat_messages
  ADD COLUMN IF NOT EXISTS kind           text NOT NULL DEFAULT 'text'
    CHECK (kind IN ('text', 'image', 'location', 'system')),
  ADD COLUMN IF NOT EXISTS attachment_url text,
  ADD COLUMN IF NOT EXISTS lat            double precision,
  ADD COLUMN IF NOT EXISTS lng            double precision,
  ADD COLUMN IF NOT EXISTS translation_ar text,
  ADD COLUMN IF NOT EXISTS translation_en text;

-- System messages (order-state events) don't have a real sender; relax the
-- NOT NULL on sender fields only for system messages via a CHECK.
-- (sender_id FK stays required for non-system rows; system rows use the
--  service-role to bypass RLS, so sender_id is set to a sentinel that satisfies
--  the FK. Simpler: keep sender_id NOT NULL and have the app/edge function
--  insert with a known system-actor id. We leave the column constraints as-is.)

-- Index for cursor pagination on (room_id, sent_at) already exists
-- (chat_messages_room_sent_idx from 00003). Add a covering index for image-
-- heavy rooms that frequently filter by kind.
CREATE INDEX IF NOT EXISTS chat_messages_room_kind_idx
  ON public.chat_messages (room_id, kind, sent_at DESC);

-- ── Lock the room when the order is terminal ─────────────────────────────────
-- Replaces the 00003 INSERT policy with one that also requires the order to be
-- active (not completed/cancelled). Prevents post-job messaging/harassment.
CREATE OR REPLACE FUNCTION public.can_chat_in_order(p_order_id uuid)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.orders
    WHERE id = p_order_id
      AND status NOT IN ('completed', 'cancelled')
  );
$$;

DROP POLICY IF EXISTS "chat_participant_insert" ON public.chat_messages;
CREATE POLICY "chat_participant_insert" ON public.chat_messages
  FOR INSERT TO authenticated WITH CHECK (
    sender_id = public.current_user_id()
    AND public.current_user_is_order_participant(room_id)
    AND public.can_chat_in_order(room_id)
  );

-- ── Storage bucket for chat image attachments ────────────────────────────────
-- Private; participants read/write via signed URLs (like user-documents).
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES ('chat-attachments', 'chat-attachments', false, 5242880,
        ARRAY['image/jpeg', 'image/png', 'image/webp'])
ON CONFLICT (id) DO NOTHING;

-- RLS: any order participant may read/write attachments for that order's room.
-- The object path convention is `{roomId}/{messageId}.<ext>`; we authorize by
-- checking the user is a participant of any order whose id matches the first
-- path segment. This is loose but safe (participants-only).
CREATE POLICY "chat_attachments_read_participant"
  ON storage.objects FOR SELECT
  USING (
    bucket_id = 'chat-attachments'
    AND public.current_user_is_order_participant(
      (storage.foldername(name))[1]::uuid
    )
  );

CREATE POLICY "chat_attachments_write_participant"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'chat-attachments'
    AND auth.uid() = public.current_user_id()
    AND public.current_user_is_order_participant(
      (storage.foldername(name))[1]::uuid
    )
  );
