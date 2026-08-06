-- Phase 4 Admin CMS: challenge_definitions
CREATE TABLE IF NOT EXISTS public.challenge_definitions (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title             TEXT NOT NULL,
  description       TEXT NOT NULL DEFAULT '',
  target_steps      INTEGER NOT NULL DEFAULT 100000,
  target_distance_km DOUBLE PRECISION NOT NULL DEFAULT 100,
  reward            TEXT NOT NULL DEFAULT '',
  image_url         TEXT,
  start_date        DATE NOT NULL,
  end_date          DATE NOT NULL,
  is_active         BOOLEAN NOT NULL DEFAULT true,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
