-- Phase 4 Admin CMS: challenge_definitions (확장판)
CREATE TABLE IF NOT EXISTS public.challenge_definitions (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title               TEXT NOT NULL,
  description         TEXT NOT NULL DEFAULT '',
  image_url           TEXT,
  target_steps        INTEGER NOT NULL DEFAULT 100000,
  target_distance_km  DOUBLE PRECISION NOT NULL DEFAULT 100,
  reward              TEXT NOT NULL DEFAULT '',
  badge_name          TEXT,
  badge_image_url     TEXT,
  forest_bonus        INTEGER NOT NULL DEFAULT 0,
  participation_limit INTEGER NOT NULL DEFAULT 0,
  auto_start          BOOLEAN NOT NULL DEFAULT false,
  auto_end            BOOLEAN NOT NULL DEFAULT false,
  start_date          DATE NOT NULL,
  end_date            DATE NOT NULL,
  is_active           BOOLEAN NOT NULL DEFAULT true,
  participant_count   INTEGER NOT NULL DEFAULT 0,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
