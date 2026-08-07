-- ================================================================
-- HealthON Phase 5 — Push Notification Migration (IDEMPOTENT)
-- ================================================================

-- ================================================================
-- 1. push_tokens
-- ================================================================

CREATE TABLE IF NOT EXISTS public.push_tokens (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  fcm_token       TEXT NOT NULL,
  platform        TEXT NOT NULL DEFAULT 'unknown'
                  CHECK (platform IN ('android','ios','web','unknown')),
  app_version     TEXT,
  is_active       BOOLEAN NOT NULL DEFAULT true,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(user_id, fcm_token)
);

CREATE INDEX IF NOT EXISTS idx_push_tokens_user ON public.push_tokens(user_id);
CREATE INDEX IF NOT EXISTS idx_push_tokens_active ON public.push_tokens(is_active) WHERE is_active = true;

ALTER TABLE public.push_tokens ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "push_tokens_select_own" ON public.push_tokens;
DROP POLICY IF EXISTS "push_tokens_insert_own" ON public.push_tokens;
DROP POLICY IF EXISTS "push_tokens_delete_own" ON public.push_tokens;

CREATE POLICY "push_tokens_select_own" ON public.push_tokens
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "push_tokens_insert_own" ON public.push_tokens
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "push_tokens_delete_own" ON public.push_tokens
  FOR DELETE USING (auth.uid() = user_id);

-- ================================================================
-- 2. push_notification_queue
-- ================================================================

CREATE TABLE IF NOT EXISTS public.push_notification_queue (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title           TEXT NOT NULL,
  body            TEXT,
  data            JSONB DEFAULT '{}'::jsonb,
  image_url       TEXT,
  category        TEXT NOT NULL DEFAULT 'general'
                  CHECK (category IN ('general','notice','challenge','mission','forest','community','reward','report','system')),
  status          TEXT NOT NULL DEFAULT 'pending'
                  CHECK (status IN ('pending','sent','failed','cancelled')),
  error_message   TEXT,
  sent_at         TIMESTAMPTZ,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_push_queue_pending ON public.push_notification_queue(status, created_at) WHERE status = 'pending';
CREATE INDEX IF NOT EXISTS idx_push_queue_user ON public.push_notification_queue(user_id, created_at DESC);

ALTER TABLE public.push_notification_queue ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "push_queue_select_own" ON public.push_notification_queue;
DROP POLICY IF EXISTS "push_queue_insert_service" ON public.push_notification_queue;

CREATE POLICY "push_queue_select_own" ON public.push_notification_queue
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "push_queue_insert_service" ON public.push_notification_queue
  FOR INSERT WITH CHECK (true);

-- ================================================================
-- 3. notification_settings
-- ================================================================

CREATE TABLE IF NOT EXISTS public.notification_settings (
  user_id                   UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  push_enabled              BOOLEAN NOT NULL DEFAULT true,
  notice_push               BOOLEAN NOT NULL DEFAULT true,
  challenge_push            BOOLEAN NOT NULL DEFAULT true,
  mission_push              BOOLEAN NOT NULL DEFAULT true,
  forest_push               BOOLEAN NOT NULL DEFAULT true,
  community_push            BOOLEAN NOT NULL DEFAULT true,
  reward_push               BOOLEAN NOT NULL DEFAULT true,
  report_push               BOOLEAN NOT NULL DEFAULT true,
  quiet_hours_enabled       BOOLEAN NOT NULL DEFAULT false,
  quiet_hours_start         TIME DEFAULT '22:00',
  quiet_hours_end           TIME DEFAULT '08:00',
  created_at                TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at                TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.notification_settings ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "notif_settings_select_own" ON public.notification_settings;
DROP POLICY IF EXISTS "notif_settings_upsert_own" ON public.notification_settings;
DROP POLICY IF EXISTS "notif_settings_update_own" ON public.notification_settings;

CREATE POLICY "notif_settings_select_own" ON public.notification_settings
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "notif_settings_upsert_own" ON public.notification_settings
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "notif_settings_update_own" ON public.notification_settings
  FOR UPDATE USING (auth.uid() = user_id);
