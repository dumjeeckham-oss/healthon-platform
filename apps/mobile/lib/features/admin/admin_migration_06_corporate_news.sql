-- =============================================================
-- Phase 4 Admin CMS: corporate_news (법인소식) 테이블
-- =============================================================

CREATE TABLE IF NOT EXISTS public.corporate_news (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title         TEXT NOT NULL,
  content       TEXT NOT NULL DEFAULT '',
  category      TEXT NOT NULL DEFAULT 'notice'
                CHECK (category IN ('event', 'education', 'training', 'notice', 'volunteer')),
  author_name   TEXT,
  is_published  BOOLEAN NOT NULL DEFAULT false,
  is_pinned     BOOLEAN NOT NULL DEFAULT false,
  scheduled_at  TIMESTAMPTZ,
  published_at  TIMESTAMPTZ,
  images        JSONB NOT NULL DEFAULT '[]'::jsonb,
  attachments   JSONB NOT NULL DEFAULT '[]'::jsonb,
  auto_feed     BOOLEAN NOT NULL DEFAULT true,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 인덱스
CREATE INDEX IF NOT EXISTS idx_corporate_news_category   ON public.corporate_news (category);
CREATE INDEX IF NOT EXISTS idx_corporate_news_published   ON public.corporate_news (is_published);
CREATE INDEX IF NOT EXISTS idx_corporate_news_pinned      ON public.corporate_news (is_pinned);
CREATE INDEX IF NOT EXISTS idx_corporate_news_created_at  ON public.corporate_news (created_at);

-- updated_at 트리거
CREATE OR REPLACE FUNCTION public.corporate_news_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS set_corporate_news_updated_at ON public.corporate_news;
CREATE TRIGGER set_corporate_news_updated_at
  BEFORE UPDATE ON public.corporate_news
  FOR EACH ROW
  EXECUTE FUNCTION public.corporate_news_updated_at();

-- 발행 시 published_at 자동 설정
CREATE OR REPLACE FUNCTION public.corporate_news_set_published()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.is_published = true AND OLD.is_published = false THEN
    NEW.published_at = NOW();
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS set_corporate_news_published ON public.corporate_news;
CREATE TRIGGER set_corporate_news_published
  BEFORE UPDATE ON public.corporate_news
  FOR EACH ROW
  EXECUTE FUNCTION public.corporate_news_set_published();

-- RLS: public 읽기 가능 (Published only)
ALTER TABLE public.corporate_news ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public can read published corporate news" ON public.corporate_news;
CREATE POLICY "Public can read published corporate news" ON public.corporate_news
  FOR SELECT
  USING (is_published = true);

-- RLS: admin 모든 작업 가능
DROP POLICY IF EXISTS "Admins can manage corporate news" ON public.corporate_news;
CREATE POLICY "Admins can manage corporate news" ON public.corporate_news
  FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.is_admin = true
    )
  );
