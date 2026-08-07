-- ================================================================
-- HealthON Admin CMS — Phase 4 Migration (RLS FIXED)
--
-- public.users 참조 제거. RLS는 auth.users.raw_user_meta_data 사용.
-- public.users 테이블은 여기서 명시적으로 생성.
-- ================================================================

-- ================================================================
-- STEP 0: public.users 생성 (Flutter AuthUser ↔ Supabase 매핑)
-- ================================================================

CREATE TABLE IF NOT EXISTS public.users (
  id                  UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email               TEXT,
  name                TEXT,
  photo_url           TEXT,
  nickname            TEXT,
  phone               TEXT,
  family_id           TEXT,
  is_admin            BOOLEAN NOT NULL DEFAULT false,
  is_profile_completed BOOLEAN NOT NULL DEFAULT false,
  is_suspended        BOOLEAN NOT NULL DEFAULT false,
  last_login_at       TIMESTAMPTZ,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "users_select_own" ON public.users
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "users_insert_own" ON public.users
  FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "users_update_own" ON public.users
  FOR UPDATE USING (auth.uid() = id);

-- 관리자 전용: 모든 사용자 조회
CREATE POLICY "users_select_admin" ON public.users
  FOR SELECT USING (
    auth.uid() IS NOT NULL AND (
      auth.jwt()->>'role' = 'service_role'
      OR EXISTS (SELECT 1 FROM auth.users WHERE id = auth.uid() AND raw_user_meta_data->>'role' = 'admin')
    )
  );

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

CREATE POLICY "notices_select_all" ON public.admin_notices
  FOR SELECT USING (true);

-- 관리자만 CUD (auth.users.raw_user_meta_data->>'role' = 'admin')
CREATE POLICY "notices_mutate_admin" ON public.admin_notices
  FOR ALL USING (
    auth.uid() IS NOT NULL AND (
      auth.jwt()->>'role' = 'service_role'
      OR EXISTS (
        SELECT 1 FROM auth.users
        WHERE id = auth.uid() AND raw_user_meta_data->>'role' = 'admin'
      )
    )
  )
  WITH CHECK (
    auth.uid() IS NOT NULL AND (
      auth.jwt()->>'role' = 'service_role'
      OR EXISTS (
        SELECT 1 FROM auth.users
        WHERE id = auth.uid() AND raw_user_meta_data->>'role' = 'admin'
      )
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
    auth.uid() IS NOT NULL AND (
      auth.jwt()->>'role' = 'service_role'
      OR EXISTS (SELECT 1 FROM auth.users WHERE id = auth.uid() AND raw_user_meta_data->>'role' = 'admin')
    )
  )
  WITH CHECK (
    auth.uid() IS NOT NULL AND (
      auth.jwt()->>'role' = 'service_role'
      OR EXISTS (SELECT 1 FROM auth.users WHERE id = auth.uid() AND raw_user_meta_data->>'role' = 'admin')
    )
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
    auth.uid() IS NOT NULL AND (
      auth.jwt()->>'role' = 'service_role'
      OR EXISTS (SELECT 1 FROM auth.users WHERE id = auth.uid() AND raw_user_meta_data->>'role' = 'admin')
    )
  )
  WITH CHECK (
    auth.uid() IS NOT NULL AND (
      auth.jwt()->>'role' = 'service_role'
      OR EXISTS (SELECT 1 FROM auth.users WHERE id = auth.uid() AND raw_user_meta_data->>'role' = 'admin')
    )
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
    auth.uid() IS NOT NULL AND (
      auth.jwt()->>'role' = 'service_role'
      OR EXISTS (SELECT 1 FROM auth.users WHERE id = auth.uid() AND raw_user_meta_data->>'role' = 'admin')
    )
  )
  WITH CHECK (
    auth.uid() IS NOT NULL AND (
      auth.jwt()->>'role' = 'service_role'
      OR EXISTS (SELECT 1 FROM auth.users WHERE id = auth.uid() AND raw_user_meta_data->>'role' = 'admin')
    )
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
    auth.uid() IS NOT NULL AND (
      auth.jwt()->>'role' = 'service_role'
      OR EXISTS (SELECT 1 FROM auth.users WHERE id = auth.uid() AND raw_user_meta_data->>'role' = 'admin')
    )
  )
  WITH CHECK (
    auth.uid() IS NOT NULL AND (
      auth.jwt()->>'role' = 'service_role'
      OR EXISTS (SELECT 1 FROM auth.users WHERE id = auth.uid() AND raw_user_meta_data->>'role' = 'admin')
    )
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

CREATE POLICY "audit_log_select_admin" ON public.audit_log
  FOR SELECT USING (
    auth.uid() IS NOT NULL AND (
      auth.jwt()->>'role' = 'service_role'
      OR EXISTS (SELECT 1 FROM auth.users WHERE id = auth.uid() AND raw_user_meta_data->>'role' = 'admin')
    )
  );

CREATE POLICY "audit_log_insert_authenticated" ON public.audit_log
  FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

-- ================================================================
-- STEP 7: community_reports 확장 + RLS 수정
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

-- RLS: 기존 정책 교체
DROP POLICY IF EXISTS "Only admins can read reports" ON public.community_reports;
DROP POLICY IF EXISTS "only_admins_select_reports" ON public.community_reports;
DROP POLICY IF EXISTS "admins_update_reports" ON public.community_reports;

CREATE POLICY "reports_select_admin" ON public.community_reports
  FOR SELECT USING (
    auth.uid() IS NOT NULL AND (
      auth.jwt()->>'role' = 'service_role'
      OR EXISTS (SELECT 1 FROM auth.users WHERE id = auth.uid() AND raw_user_meta_data->>'role' = 'admin')
    )
  );

CREATE POLICY "reports_update_admin" ON public.community_reports
  FOR UPDATE USING (
    auth.uid() IS NOT NULL AND (
      auth.jwt()->>'role' = 'service_role'
      OR EXISTS (SELECT 1 FROM auth.users WHERE id = auth.uid() AND raw_user_meta_data->>'role' = 'admin')
    )
  );

-- 신고 접수는 인증된 사용자 누구나
CREATE POLICY "reports_insert_auth" ON public.community_reports
  FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);
