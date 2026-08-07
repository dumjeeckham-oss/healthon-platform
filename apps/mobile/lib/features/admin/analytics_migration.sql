-- ================================================================
-- HealthON Phase 8 — Analytics Migration (FIXED)
-- public.users 참조 제거 → auth.users.raw_user_meta_data 사용
-- ================================================================

-- ================================================================
-- 1. daily_stats
-- ================================================================

CREATE TABLE IF NOT EXISTS public.daily_stats (
  date              DATE PRIMARY KEY,
  dau               INTEGER NOT NULL DEFAULT 0,
  new_users         INTEGER NOT NULL DEFAULT 0,
  total_steps       BIGINT NOT NULL DEFAULT 0,
  total_distance_km DOUBLE PRECISION NOT NULL DEFAULT 0,
  active_challenges INTEGER NOT NULL DEFAULT 0,
  completed_challenges INTEGER NOT NULL DEFAULT 0,
  completed_missions INTEGER NOT NULL DEFAULT 0,
  new_posts         INTEGER NOT NULL DEFAULT 0,
  new_comments      INTEGER NOT NULL DEFAULT 0,
  new_likes         INTEGER NOT NULL DEFAULT 0,
  cheers_sent       INTEGER NOT NULL DEFAULT 0,
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.daily_stats ENABLE ROW LEVEL SECURITY;

CREATE POLICY "daily_stats_select_admin" ON public.daily_stats
  FOR SELECT USING (
    auth.uid() IS NOT NULL
    AND (auth.jwt()->>'role' = 'service_role'
      OR auth.uid() IN (
        SELECT id FROM auth.users WHERE raw_user_meta_data->>'role' = 'admin'
      ))
  );

-- ================================================================
-- 2. weekly_retention
-- ================================================================

CREATE TABLE IF NOT EXISTS public.weekly_retention (
  cohort_week       DATE NOT NULL,
  week_number       INTEGER NOT NULL,
  cohort_size       INTEGER NOT NULL DEFAULT 0,
  retained          INTEGER NOT NULL DEFAULT 0,
  retention_rate    DOUBLE PRECISION NOT NULL DEFAULT 0,
  PRIMARY KEY(cohort_week, week_number)
);

ALTER TABLE public.weekly_retention ENABLE ROW LEVEL SECURITY;

CREATE POLICY "retention_select_admin" ON public.weekly_retention
  FOR SELECT USING (
    auth.uid() IS NOT NULL
    AND (auth.jwt()->>'role' = 'service_role'
      OR auth.uid() IN (
        SELECT id FROM auth.users WHERE raw_user_meta_data->>'role' = 'admin'
      ))
  );

-- ================================================================
-- 3. challenge_funnel
-- ================================================================

CREATE TABLE IF NOT EXISTS public.challenge_funnel (
  challenge_id      UUID NOT NULL REFERENCES public.challenge_definitions(id),
  total_users       INTEGER NOT NULL DEFAULT 0,
  starters          INTEGER NOT NULL DEFAULT 0,
  halfway           INTEGER NOT NULL DEFAULT 0,
  completers        INTEGER NOT NULL DEFAULT 0,
  start_rate        DOUBLE PRECISION NOT NULL DEFAULT 0,
  completion_rate   DOUBLE PRECISION NOT NULL DEFAULT 0,
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY(challenge_id)
);

ALTER TABLE public.challenge_funnel ENABLE ROW LEVEL SECURITY;

CREATE POLICY "funnel_select_admin" ON public.challenge_funnel
  FOR SELECT USING (
    auth.uid() IS NOT NULL
    AND (auth.jwt()->>'role' = 'service_role'
      OR auth.uid() IN (
        SELECT id FROM auth.users WHERE raw_user_meta_data->>'role' = 'admin'
      ))
  );

-- ================================================================
-- 4. RPC: refresh_daily_stats (public.users → auth.users)
-- ================================================================

CREATE OR REPLACE FUNCTION public.refresh_daily_stats(
  p_date DATE DEFAULT CURRENT_DATE
) RETURNS VOID AS $$
DECLARE
  v_dau INTEGER; v_new INTEGER; v_steps BIGINT; v_dist DOUBLE PRECISION;
  v_active_c INTEGER; v_completed_c INTEGER; v_completed_m INTEGER;
  v_posts INTEGER; v_comments INTEGER; v_likes INTEGER; v_cheers INTEGER;
BEGIN
  SELECT COUNT(DISTINCT user_id) INTO v_dau
  FROM public.health_daily WHERE date = p_date;

  -- 신규 가입 (auth.users 기준)
  SELECT COUNT(*)::INTEGER INTO v_new
  FROM auth.users WHERE DATE(created_at) = p_date;

  SELECT COALESCE(SUM(steps), 0)::BIGINT, COALESCE(SUM(distance_km), 0)
  INTO v_steps, v_dist FROM public.health_daily WHERE date = p_date;

  SELECT COUNT(*) INTO v_active_c FROM public.challenge_definitions
  WHERE is_active = true AND p_date BETWEEN start_date AND end_date;

  SELECT COUNT(*) INTO v_completed_c FROM public.activity_events
  WHERE type = 'challenge_completed' AND DATE(created_at) = p_date;

  SELECT COUNT(*) INTO v_completed_m FROM public.activity_events
  WHERE type = 'mission_completed' AND DATE(created_at) = p_date;

  SELECT COUNT(*) INTO v_posts FROM public.community_posts WHERE DATE(created_at) = p_date;
  SELECT COUNT(*) INTO v_comments FROM public.community_comments WHERE DATE(created_at) = p_date;
  SELECT COUNT(*) INTO v_likes FROM public.community_post_likes WHERE DATE(created_at) = p_date;

  SELECT COUNT(*) INTO v_cheers FROM public.family_cheers WHERE DATE(created_at) = p_date;

  INSERT INTO public.daily_stats (date, dau, new_users, total_steps, total_distance_km,
    active_challenges, completed_challenges, completed_missions, new_posts, new_comments, new_likes, cheers_sent, updated_at)
  VALUES (p_date, v_dau, v_new, v_steps, v_dist, v_active_c, v_completed_c, v_completed_m, v_posts, v_comments, v_likes, v_cheers, NOW())
  ON CONFLICT (date) DO UPDATE SET
    dau = EXCLUDED.dau, new_users = EXCLUDED.new_users,
    total_steps = EXCLUDED.total_steps, total_distance_km = EXCLUDED.total_distance_km,
    active_challenges = EXCLUDED.active_challenges, completed_challenges = EXCLUDED.completed_challenges,
    completed_missions = EXCLUDED.completed_missions, new_posts = EXCLUDED.new_posts,
    new_comments = EXCLUDED.new_comments, new_likes = EXCLUDED.new_likes,
    cheers_sent = EXCLUDED.cheers_sent, updated_at = NOW();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ================================================================
-- 5. RPC: get_trend_data
-- ================================================================

CREATE OR REPLACE FUNCTION public.get_trend_data(
  p_days INTEGER DEFAULT 30
) RETURNS TABLE (
  d DATE, dau INTEGER, new_u INTEGER, steps BIGINT, posts INTEGER
) AS $$
BEGIN
  RETURN QUERY
  SELECT ds.date, ds.dau, ds.new_users, ds.total_steps, ds.new_posts
  FROM public.daily_stats ds
  WHERE ds.date >= CURRENT_DATE - p_days
  ORDER BY ds.date;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ================================================================
-- 6. RPC: get_category_distribution
-- ================================================================

CREATE OR REPLACE FUNCTION public.get_category_distribution()
RETURNS TABLE (category TEXT, cnt BIGINT) AS $$
BEGIN
  RETURN QUERY
  SELECT cp.category, COUNT(*)::BIGINT
  FROM public.community_posts cp
  WHERE cp.created_at >= CURRENT_DATE - INTERVAL '30 days'
  GROUP BY cp.category
  ORDER BY COUNT(*) DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
