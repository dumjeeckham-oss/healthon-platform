-- ===============================================================
-- HealthON Community Report SQL Migration
-- ===============================================================

-- community_reports
CREATE TABLE IF NOT EXISTS public.community_reports (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  reporter_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  target_type TEXT NOT NULL CHECK (target_type IN ('post', 'comment')),
  target_id   UUID NOT NULL,
  reason      TEXT NOT NULL DEFAULT 'other',
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_community_reports_target
  ON public.community_reports(target_type, target_id);
CREATE INDEX IF NOT EXISTS idx_community_reports_reporter
  ON public.community_reports(reporter_id);

-- RLS
ALTER TABLE public.community_reports ENABLE ROW LEVEL SECURITY;

-- 본인만 insert 가능
CREATE POLICY "Users can insert own reports"
  ON public.community_reports FOR INSERT
  WITH CHECK (auth.uid() = reporter_id);

-- 관리자만 read 가능 (일반 사용자는 조회 불가)
CREATE POLICY "Only admins can read reports"
  ON public.community_reports FOR SELECT
  USING (auth.uid() IN (
    SELECT id FROM auth.users WHERE raw_user_meta_data->>'role' = 'admin'
  ));
