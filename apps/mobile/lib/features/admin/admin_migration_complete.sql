-- ================================================================
-- HealthON Admin CMS — Phase 4 Migration (CORRECTED)
-- 회원 테이블: public.users (NOT public.profiles)
-- 모든 FK: auth.users(id) 직접 참조
-- ================================================================

-- ================================================================
-- STEP 0: public.users 확장 (Admin CMS 필수 컬럼)
-- ================================================================

ALTER TABLE public.users ADD COLUMN IF NOT EXISTS is_suspended BOOLEAN NOT NULL DEFAULT false;
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS last_login_at TIMESTAMPTZ;

COMMENT ON COLUMN public.users.is_suspended IS '관리자 활동정지 여부';
COMMENT ON COLUMN public.users.last_login_at IS '마지막 로그인 일시';

-- ================================================================
-- STEP 1: admin_notices
-- ================================================================

CREATE TABLE IF NOT EXISTS public.admin_notices (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title           TEXT NOT NULL,
  content         TEXT NOT NULL DEFAULT '',
  category        TEXT NOT NULL DEFAULT 'notice'
                  CHECK (category IN ('notice','corporate_news','event','education','volunteer','training')),
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

CREATE INDEX IF NOT EXISTS idx_admin_notices_category ON public.admin_notices(category, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_admin_notices_pinned ON public.admin_notices(is_pinned DESC, created_at DESC);

ALTER TABLE public.admin_notices ENABLE ROW LEVEL SECURITY;

-- RLS: 모두 조회 가능
CREATE POLICY "notices_select_all" ON public.admin_notices
  FOR SELECT USING (true);

-- RLS: 관리자만 CUD (public.users.is_admin 체크)
CREATE POLICY "notices_mutate_admin" ON public.admin_notices
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM public.users
      WHERE id = auth.uid() AND is_admin = true
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.users
      WHERE id = auth.uid() AND is_admin = true
    )
  );

-- ================================================================
-- STEP 2: challenge_definitions
-- ================================================================

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

ALTER TABLE public.challenge_definitions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "challenge_def_select_all" ON public.challenge_definitions
  FOR SELECT USING (true);

CREATE POLICY "challenge_def_mutate_admin" ON public.challenge_definitions
  FOR ALL USING (
    EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND is_admin = true)
  )
  WITH CHECK (
    EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND is_admin = true)
  );

-- ================================================================
-- STEP 3: mission_definitions
-- ================================================================

CREATE TABLE IF NOT EXISTS public.mission_definitions (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title             TEXT NOT NULL,
  description       TEXT NOT NULL DEFAULT '',
  image_url         TEXT,
  period            TEXT NOT NULL DEFAULT 'daily'
                    CHECK (period IN ('daily','weekly','monthly','custom')),
  custom_days       INTEGER NOT NULL DEFAULT 1,
  target_steps      INTEGER NOT NULL DEFAULT 5000,
  target_distance_km DOUBLE PRECISION NOT NULL DEFAULT 3.5,
  condition         JSONB,
  reward_type       TEXT NOT NULL DEFAULT 'point',
  reward_value      INTEGER NOT NULL DEFAULT 10,
  is_repeatable     BOOLEAN NOT NULL DEFAULT false,
  is_active         BOOLEAN NOT NULL DEFAULT true,
  completion_count  INTEGER NOT NULL DEFAULT 0,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.mission_definitions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "mission_def_select_all" ON public.mission_definitions
  FOR SELECT USING (true);

CREATE POLICY "mission_def_mutate_admin" ON public.mission_definitions
  FOR ALL USING (
    EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND is_admin = true)
  )
  WITH CHECK (
    EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND is_admin = true)
  );

-- ================================================================
-- STEP 4: forest_seasons
-- ================================================================

CREATE TABLE IF NOT EXISTS public.forest_seasons (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name        TEXT NOT NULL,
  season_type TEXT NOT NULL DEFAULT 'spring'
              CHECK (season_type IN ('spring','summer','autumn','winter')),
  theme       JSONB NOT NULL DEFAULT '{}'::jsonb,
  description TEXT NOT NULL DEFAULT '',
  start_date  DATE NOT NULL,
  end_date    DATE,
  is_active   BOOLEAN NOT NULL DEFAULT true,
  tree_count  INTEGER NOT NULL DEFAULT 0,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.forest_seasons ENABLE ROW LEVEL SECURITY;

CREATE POLICY "forest_seasons_select_all" ON public.forest_seasons
  FOR SELECT USING (true);

CREATE POLICY "forest_seasons_mutate_admin" ON public.forest_seasons
  FOR ALL USING (
    EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND is_admin = true)
  )
  WITH CHECK (
    EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND is_admin = true)
  );

-- ================================================================
-- STEP 5: admin_banners
-- ================================================================

CREATE TABLE IF NOT EXISTS public.admin_banners (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title       TEXT NOT NULL DEFAULT '',
  image_url   TEXT NOT NULL,
  link_value  TEXT,
  link_type   TEXT NOT NULL DEFAULT 'none'
              CHECK (link_type IN ('none','external_url','internal_route')),
  sort_order  INTEGER NOT NULL DEFAULT 0,
  start_date  DATE NOT NULL,
  end_date    DATE NOT NULL,
  is_active   BOOLEAN NOT NULL DEFAULT true,
  click_count INTEGER NOT NULL DEFAULT 0,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.admin_banners ENABLE ROW LEVEL SECURITY;

CREATE POLICY "banners_select_all" ON public.admin_banners
  FOR SELECT USING (true);

CREATE POLICY "banners_mutate_admin" ON public.admin_banners
  FOR ALL USING (
    EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND is_admin = true)
  )
  WITH CHECK (
    EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND is_admin = true)
  );

-- ================================================================
-- STEP 6: audit_log
-- ================================================================

CREATE TABLE IF NOT EXISTS public.audit_log (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  admin_id    UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  admin_name  TEXT NOT NULL,
  action      TEXT NOT NULL,
  target_type TEXT NOT NULL,
  target_id   TEXT,
  target_name TEXT,
  changes     JSONB,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_audit_log_admin ON public.audit_log(admin_id);
CREATE INDEX IF NOT EXISTS idx_audit_log_created ON public.audit_log(created_at DESC);

ALTER TABLE public.audit_log ENABLE ROW LEVEL SECURITY;

-- audit_log: 관리자만 조회
CREATE POLICY "audit_log_select_admin" ON public.audit_log
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND is_admin = true)
  );

-- audit_log: 인증된 사용자면 insert 가능 (서비스 레이어에서 호출)
CREATE POLICY "audit_log_insert_authenticated" ON public.audit_log
  FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

-- ================================================================
-- STEP 7: community_reports 확장 (Admin CMS 필요 컬럼)
-- ================================================================

ALTER TABLE public.community_reports
  ADD COLUMN IF NOT EXISTS detail TEXT;

ALTER TABLE public.community_reports
  ADD COLUMN IF NOT EXISTS target_content TEXT;

ALTER TABLE public.community_reports
  ADD COLUMN IF NOT EXISTS target_author_id UUID REFERENCES auth.users(id);

ALTER TABLE public.community_reports
  ADD COLUMN IF NOT EXISTS status TEXT NOT NULL DEFAULT 'pending'
  CHECK (status IN ('pending','reviewed','deleted','hidden','warned','suspended'));

ALTER TABLE public.community_reports
  ADD COLUMN IF NOT EXISTS resolved_action TEXT;

ALTER TABLE public.community_reports
  ADD COLUMN IF NOT EXISTS resolved_by TEXT;

ALTER TABLE public.community_reports
  ADD COLUMN IF NOT EXISTS resolved_at TIMESTAMPTZ;

ALTER TABLE public.community_reports
  ADD COLUMN IF NOT EXISTS reporter_name TEXT;

-- community_reports RLS 수정 (auth.users.raw_user_meta_data → public.users.is_admin)
DROP POLICY IF EXISTS "Only admins can read reports" ON public.community_reports;
CREATE POLICY "only_admins_select_reports" ON public.community_reports
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND is_admin = true)
  );

-- 관리자가 신고 UPDATE 가능
CREATE POLICY "admins_update_reports" ON public.community_reports
  FOR UPDATE USING (
    EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND is_admin = true)
  );
