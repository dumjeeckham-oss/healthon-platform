-- =============================================================
-- Phase 4 Admin CMS: analytics_cache 테이블
-- KPI 스냅샷 캐싱 + RPC 함수
-- =============================================================

-- 분석 캐시 테이블
CREATE TABLE IF NOT EXISTS public.analytics_cache (
  id          BIGSERIAL PRIMARY KEY,
  metric_key  TEXT NOT NULL UNIQUE,
  metric_value JSONB NOT NULL DEFAULT '{}'::jsonb,
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_analytics_cache_key ON public.analytics_cache (metric_key);

-- RLS: admin only
ALTER TABLE public.analytics_cache ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Admins can access analytics cache" ON public.analytics_cache;
CREATE POLICY "Admins can access analytics cache" ON public.analytics_cache
  FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.is_admin = true
    )
  );

-- =============================================================
-- RPC: 대시보드 통계 집계
-- =============================================================

CREATE OR REPLACE FUNCTION public.get_dashboard_stats()
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  today_str      TEXT;
  week_ago_str   TEXT;
  result         JSONB;
BEGIN
  today_str    := to_char(NOW(), 'YYYY-MM-DD');
  week_ago_str := to_char(NOW() - INTERVAL '7 days', 'YYYY-MM-DD');

  SELECT jsonb_build_object(
    'today_signups',
      (SELECT COUNT(*) FROM profiles WHERE created_at::date = today_str::date),
    'today_logins',
      (SELECT COUNT(*) FROM profiles WHERE last_login_at::date = today_str::date),
    'today_steps',
      COALESCE((SELECT SUM(steps) FROM health_daily WHERE date = today_str), 0),
    'today_forest_growth',
      COALESCE((SELECT COUNT(*) FROM activity_events WHERE type = 'forest_level_up' AND created_at::date = today_str::date), 0),
    'today_challenge_completions',
      COALESCE((SELECT COUNT(*) FROM activity_events WHERE type = 'challenge_completed' AND created_at::date = today_str::date), 0),
    'today_mission_completions',
      COALESCE((SELECT COUNT(*) FROM activity_events WHERE type = 'mission_completed' AND created_at::date = today_str::date), 0),
    'today_posts',
      COALESCE((SELECT COUNT(*) FROM community_posts WHERE created_at::date = today_str::date), 0),
    'today_comments',
      COALESCE((SELECT COUNT(*) FROM community_comments WHERE created_at::date = today_str::date), 0),
    'total_users',
      (SELECT COUNT(*) FROM profiles),
    'active_users',
      (SELECT COUNT(*) FROM profiles WHERE last_login_at >= week_ago_str),
    'suspended_users',
      COALESCE((SELECT COUNT(*) FROM profiles WHERE is_suspended = true), 0)
  ) INTO result;

  RETURN result;
END;
$$;

-- =============================================================
-- RPC: 주간 걸음 차트
-- =============================================================

CREATE OR REPLACE FUNCTION public.get_weekly_steps_chart()
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  d_date   DATE;
  d_label  TEXT;
  d_steps  BIGINT;
  labels   JSONB := '[]'::jsonb;
  values   JSONB := '[]'::jsonb;
BEGIN
  FOR i IN REVERSE 6..0 LOOP
    d_date  := CURRENT_DATE - i;
    d_label := to_char(d_date, 'MM/DD');
    d_steps := COALESCE(
      (SELECT SUM(steps) FROM health_daily WHERE date = to_char(d_date, 'YYYY-MM-DD')), 0
    );
    labels := labels || to_jsonb(d_label);
    values := values || to_jsonb(d_steps);
  END LOOP;
  RETURN jsonb_build_object('labels', labels, 'values', values);
END;
$$;

-- =============================================================
-- RPC: 일간 사용자 차트
-- =============================================================

CREATE OR REPLACE FUNCTION public.get_daily_users_chart()
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  d_date   DATE;
  d_label  TEXT;
  d_users  BIGINT;
  labels   JSONB := '[]'::jsonb;
  values   JSONB := '[]'::jsonb;
BEGIN
  FOR i IN REVERSE 6..0 LOOP
    d_date  := CURRENT_DATE - i;
    d_label := to_char(d_date, 'MM/DD');
    d_users := COALESCE(
      (SELECT COUNT(DISTINCT user_id) FROM health_daily WHERE date = to_char(d_date, 'YYYY-MM-DD')), 0
    );
    labels := labels || to_jsonb(d_label);
    values := values || to_jsonb(d_users);
  END LOOP;
  RETURN jsonb_build_object('labels', labels, 'values', values);
END;
$$;

-- =============================================================
-- RPC: DAU 차트 (N일)
-- =============================================================

CREATE OR REPLACE FUNCTION public.get_dau_chart(p_days INT DEFAULT 7)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  d_date   DATE;
  d_label  TEXT;
  d_count  BIGINT;
  labels   JSONB := '[]'::jsonb;
  values   JSONB := '[]'::jsonb;
BEGIN
  FOR i IN REVERSE (p_days - 1)..0 LOOP
    d_date  := CURRENT_DATE - i;
    d_label := to_char(d_date, 'MM/DD');
    d_count := COALESCE(
      (SELECT COUNT(DISTINCT user_id) FROM health_daily WHERE date = to_char(d_date, 'YYYY-MM-DD')), 0
    );
    labels := labels || to_jsonb(d_label);
    values := values || to_jsonb(d_count);
  END LOOP;
  RETURN jsonb_build_object('labels', labels, 'values', values);
END;
$$;

-- =============================================================
-- 추가 인덱스 (대시보드 쿼리 최적화)
-- =============================================================

CREATE INDEX IF NOT EXISTS idx_health_daily_date      ON public.health_daily (date);
CREATE INDEX IF NOT EXISTS idx_health_daily_user_date  ON public.health_daily (user_id, date);
CREATE INDEX IF NOT EXISTS idx_activity_events_type_date ON public.activity_events (type, created_at);
CREATE INDEX IF NOT EXISTS idx_community_posts_date    ON public.community_posts (created_at);
CREATE INDEX IF NOT EXISTS idx_community_comments_date ON public.community_comments (created_at);
CREATE INDEX IF NOT EXISTS idx_profiles_last_login     ON public.profiles (last_login_at);
CREATE INDEX IF NOT EXISTS idx_profiles_is_suspended   ON public.profiles (is_suspended);
CREATE INDEX IF NOT EXISTS idx_profiles_is_admin       ON public.profiles (is_admin);
