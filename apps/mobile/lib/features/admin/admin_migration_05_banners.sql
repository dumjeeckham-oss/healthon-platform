-- Phase 4 Admin CMS: admin_banners
CREATE TABLE IF NOT EXISTS public.admin_banners (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  image_url  TEXT NOT NULL,
  link_url   TEXT,
  sort_order INTEGER NOT NULL DEFAULT 0,
  start_date DATE NOT NULL,
  end_date   DATE NOT NULL,
  is_active  BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
