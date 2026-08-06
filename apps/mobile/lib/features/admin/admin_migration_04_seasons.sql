-- Phase 4 Admin CMS: forest_seasons (확장판 - 시즌 타입, 테마, 트리 카운트)
CREATE TABLE IF NOT EXISTS public.forest_seasons (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name        TEXT NOT NULL,
  season_type TEXT NOT NULL DEFAULT 'spring',
  theme       JSONB NOT NULL DEFAULT '{}'::jsonb,
  description TEXT NOT NULL DEFAULT '',
  start_date  DATE NOT NULL,
  end_date    DATE,
  is_active   BOOLEAN NOT NULL DEFAULT true,
  tree_count  INTEGER NOT NULL DEFAULT 0,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
