-- ================================================================
-- HealthON Health Sync Migration
--
-- Health Connect / Apple Health → Supabase 동기화 파이프라인
-- ================================================================

-- ================================================================
-- 1. health_daily — 일별 건강 데이터
-- ================================================================

CREATE TABLE IF NOT EXISTS public.health_daily (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  date DATE NOT NULL,
  steps INTEGER NOT NULL DEFAULT 0,
  distance_km DOUBLE PRECISION NOT NULL DEFAULT 0,
  calories DOUBLE PRECISION NOT NULL DEFAULT 0,
  exercise_minutes INTEGER NOT NULL DEFAULT 0,
  active_minutes INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ,
  CONSTRAINT uq_health_daily_user_date UNIQUE (user_id, date)
);

COMMENT ON TABLE public.health_daily IS '일별 건강 데이터 (Health Connect / Apple Health 동기화)';
COMMENT ON COLUMN public.health_daily.steps IS '걸음 수';
COMMENT ON COLUMN public.health_daily.distance_km IS '이동 거리 (km)';
COMMENT ON COLUMN public.health_daily.calories IS '소모 칼로리 (kcal)';
COMMENT ON COLUMN public.health_daily.exercise_minutes IS '운동 시간 (분)';
COMMENT ON COLUMN public.health_daily.active_minutes IS '활동 시간 (분)';

-- 인덱스
CREATE INDEX IF NOT EXISTS idx_health_daily_user_date
  ON public.health_daily(user_id, date DESC);

CREATE INDEX IF NOT EXISTS idx_health_daily_steps
  ON public.health_daily(steps DESC);

-- ================================================================
-- 2. health_sync_logs — 동기화 로그
-- ================================================================

CREATE TABLE IF NOT EXISTS public.health_sync_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  sync_started TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  sync_finished TIMESTAMPTZ,
  status TEXT NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending', 'running', 'success', 'failed')),
  device TEXT NOT NULL DEFAULT 'unknown'
    CHECK (device IN ('unknown', 'health_connect', 'apple_health')),
  synced_days INTEGER NOT NULL DEFAULT 0,
  error_message TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE public.health_sync_logs IS 'Health 데이터 동기화 로그';

CREATE INDEX IF NOT EXISTS idx_health_sync_logs_user
  ON public.health_sync_logs(user_id, sync_started DESC);

-- ================================================================
-- 3. RPC: upsert_health_daily — 중복 방지 UPSERT
-- ================================================================

CREATE OR REPLACE FUNCTION public.upsert_health_daily(
  p_user_id UUID,
  p_date DATE,
  p_steps INTEGER,
  p_distance_km DOUBLE PRECISION,
  p_calories DOUBLE PRECISION,
  p_exercise_minutes INTEGER,
  p_active_minutes INTEGER
) RETURNS UUID AS $$
DECLARE
  result_id UUID;
BEGIN
  INSERT INTO public.health_daily (
    user_id, date, steps, distance_km, calories,
    exercise_minutes, active_minutes, updated_at
  ) VALUES (
    p_user_id, p_date, p_steps, p_distance_km, p_calories,
    p_exercise_minutes, p_active_minutes, NOW()
  )
  ON CONFLICT (user_id, date) DO UPDATE SET
    steps = EXCLUDED.steps,
    distance_km = EXCLUDED.distance_km,
    calories = EXCLUDED.calories,
    exercise_minutes = EXCLUDED.exercise_minutes,
    active_minutes = EXCLUDED.active_minutes,
    updated_at = NOW()
  RETURNING id INTO result_id;

  RETURN result_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ================================================================
-- 4. RPC: get_health_weekly — 주간 합계
-- ================================================================

CREATE OR REPLACE FUNCTION public.get_health_weekly(
  p_user_id UUID,
  p_start_date DATE
) RETURNS TABLE (
  total_steps BIGINT,
  total_distance DOUBLE PRECISION,
  total_calories DOUBLE PRECISION,
  total_exercise_minutes INTEGER,
  total_active_minutes INTEGER
) AS $$
BEGIN
  RETURN QUERY
    SELECT
      COALESCE(SUM(hd.steps), 0)::BIGINT,
      COALESCE(SUM(hd.distance_km), 0),
      COALESCE(SUM(hd.calories), 0),
      COALESCE(SUM(hd.exercise_minutes), 0)::INTEGER,
      COALESCE(SUM(hd.active_minutes), 0)::INTEGER
    FROM public.health_daily hd
    WHERE hd.user_id = p_user_id
      AND hd.date >= p_start_date
      AND hd.date < (p_start_date + INTERVAL '7 days');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ================================================================
-- 5. RPC: get_health_monthly — 월간 합계
-- ================================================================

CREATE OR REPLACE FUNCTION public.get_health_monthly(
  p_user_id UUID,
  p_year INTEGER,
  p_month INTEGER
) RETURNS TABLE (
  total_steps BIGINT,
  total_distance DOUBLE PRECISION,
  total_calories DOUBLE PRECISION,
  total_exercise_minutes INTEGER,
  total_active_minutes INTEGER
) AS $$
BEGIN
  RETURN QUERY
    SELECT
      COALESCE(SUM(hd.steps), 0)::BIGINT,
      COALESCE(SUM(hd.distance_km), 0),
      COALESCE(SUM(hd.calories), 0),
      COALESCE(SUM(hd.exercise_minutes), 0)::INTEGER,
      COALESCE(SUM(hd.active_minutes), 0)::INTEGER
    FROM public.health_daily hd
    WHERE hd.user_id = p_user_id
      AND EXTRACT(YEAR FROM hd.date) = p_year
      AND EXTRACT(MONTH FROM hd.date) = p_month;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ================================================================
-- 6. RLS 정책
-- ================================================================

ALTER TABLE public.health_daily ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.health_sync_logs ENABLE ROW LEVEL SECURITY;

-- health_daily: 본인 데이터만 조회
CREATE POLICY "health_daily_select_own" ON public.health_daily
  FOR SELECT USING (auth.uid() = user_id);

-- health_daily: 시스템에서만 insert (RPC 통해)
CREATE POLICY "health_daily_insert_service" ON public.health_daily
  FOR INSERT WITH CHECK (true);

-- health_daily: 시스템에서만 update
CREATE POLICY "health_daily_update_service" ON public.health_daily
  FOR UPDATE USING (true);

-- health_sync_logs: 본인만 조회
CREATE POLICY "health_sync_logs_select_own" ON public.health_sync_logs
  FOR SELECT USING (auth.uid() = user_id);

-- health_sync_logs: 시스템 insert만
CREATE POLICY "health_sync_logs_insert_service" ON public.health_sync_logs
  FOR INSERT WITH CHECK (true);

-- ================================================================
-- 7. health_snapshots — Community Snapshot 생성용
-- ================================================================

CREATE TABLE IF NOT EXISTS public.health_snapshots (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  date DATE NOT NULL,
  snapshot_data JSONB NOT NULL DEFAULT '{}'::jsonb,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT uq_health_snapshots_user_date UNIQUE (user_id, date)
);

COMMENT ON TABLE public.health_snapshots IS '일별 건강 스냅샷 (Community 게시글 첨부용)';

ALTER TABLE public.health_snapshots ENABLE ROW LEVEL SECURITY;

CREATE POLICY "health_snapshots_select_own" ON public.health_snapshots
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "health_snapshots_insert_service" ON public.health_snapshots
  FOR INSERT WITH CHECK (true);

CREATE POLICY "health_snapshots_update_service" ON public.health_snapshots
  FOR UPDATE USING (true);
