-- Phase 4 Admin CMS: admin_notices 테이블
CREATE TABLE IF NOT EXISTS public.admin_notices (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title        TEXT NOT NULL,
  content      TEXT NOT NULL DEFAULT '',
  category     TEXT NOT NULL DEFAULT 'notice',
  is_pinned    BOOLEAN NOT NULL DEFAULT false,
  is_published BOOLEAN NOT NULL DEFAULT false,
  scheduled_at TIMESTAMPTZ,
  published_at TIMESTAMPTZ,
  images       JSONB NOT NULL DEFAULT '[]'::jsonb,
  attachments  JSONB NOT NULL DEFAULT '[]'::jsonb,
  push_sent    BOOLEAN NOT NULL DEFAULT false,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
