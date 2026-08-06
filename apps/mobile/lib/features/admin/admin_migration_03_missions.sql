-- Phase 4 Admin CMS: mission_definitions (확장판)
CREATE TABLE IF NOT EXISTS public.mission_definitions (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title             TEXT NOT NULL,
  description       TEXT NOT NULL DEFAULT '',
  image_url         TEXT,
  period            TEXT NOT NULL DEFAULT 'daily',
  custom_days       INTEGER NOT NULL DEFAULT 1,
  target_steps      INTEGER NOT NULL DEFAULT 5000,
  target_distance_km DOUBLE PRECISION NOT NULL DEFAULT 3.5,
  condition         JSONB,
  reward_type       TEXT NOT NULL DEFAULT 'point',
  reward_value      INTEGER NOT NULL DEFAULT 10,
  is_repeatable     BOOLEAN NOT NULL DEFAULT false,
  is_active         BOOLEAN NOT NULL DEFAULT true,
  completion_count  INTEGER NOT NULL DEFAULT 0,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
