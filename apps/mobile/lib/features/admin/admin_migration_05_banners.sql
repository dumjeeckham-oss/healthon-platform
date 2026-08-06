-- Phase 4 Admin CMS: admin_banners (확장판 - 타이틀, 링크 타입, 클릭 카운트)
CREATE TABLE IF NOT EXISTS public.admin_banners (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title       TEXT NOT NULL DEFAULT '',
  image_url   TEXT NOT NULL,
  link_value  TEXT,
  link_type   TEXT NOT NULL DEFAULT 'none',
  sort_order  INTEGER NOT NULL DEFAULT 0,
  start_date  DATE NOT NULL,
  end_date    DATE NOT NULL,
  is_active   BOOLEAN NOT NULL DEFAULT true,
  click_count INTEGER NOT NULL DEFAULT 0,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
