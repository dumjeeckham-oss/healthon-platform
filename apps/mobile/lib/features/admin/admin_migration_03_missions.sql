-- Phase 4 Admin CMS: mission_definitions
CREATE TABLE IF NOT EXISTS public.mission_definitions (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title             TEXT NOT NULL,
  description       TEXT NOT NULL DEFAULT '',
  period            TEXT NOT NULL DEFAULT 'daily',
  target_steps      INTEGER NOT NULL DEFAULT 5000,
  target_distance_km DOUBLE PRECISION NOT NULL DEFAULT 3.5,
  reward_type       TEXT NOT NULL DEFAULT 'point',
  reward_value      INTEGER NOT NULL DEFAULT 10,
  is_active         BOOLEAN NOT NULL DEFAULT true,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
