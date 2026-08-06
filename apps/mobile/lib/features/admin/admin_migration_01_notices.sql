-- Phase 4 Admin CMS: admin_notices (확장판 - 태그, 이미지 URL, 첨부파일, 조회수)
CREATE TABLE IF NOT EXISTS public.admin_notices (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title           TEXT NOT NULL,
  content         TEXT NOT NULL DEFAULT '',
  category        TEXT NOT NULL DEFAULT 'notice',
  tags            JSONB NOT NULL DEFAULT '[]'::jsonb,
  is_pinned       BOOLEAN NOT NULL DEFAULT false,
  is_published    BOOLEAN NOT NULL DEFAULT false,
  scheduled_at    TIMESTAMPTZ,
  published_at    TIMESTAMPTZ,
  image_urls      JSONB NOT NULL DEFAULT '[]'::jsonb,
  attachment_urls JSONB NOT NULL DEFAULT '[]'::jsonb,
  attachment_names JSONB NOT NULL DEFAULT '[]'::jsonb,
  push_sent       BOOLEAN NOT NULL DEFAULT false,
  view_count      INTEGER NOT NULL DEFAULT 0,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
