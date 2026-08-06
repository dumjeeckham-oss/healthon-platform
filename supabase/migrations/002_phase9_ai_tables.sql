-- ===============================================================
-- HealthON Phase 9 — AI Data Tables Migration
--
-- AI 인사이트, 리포트, 챗봇 대화, 알림 설정 저장
-- ===============================================================

-- 1. AI 인사이트 저장 테이블
CREATE TABLE IF NOT EXISTS public.ai_insights (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  type TEXT NOT NULL CHECK (type IN ('pattern', 'recommendation', 'warning', 'celebration', 'prediction')),
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  action_text TEXT,
  action_route TEXT,
  confidence DOUBLE PRECISION DEFAULT 0.8,
  metadata JSONB DEFAULT '{}',
  is_read BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_ai_insights_user_id ON ai_insights(user_id);
CREATE INDEX IF NOT EXISTS idx_ai_insights_created_at ON ai_insights(created_at DESC);

-- RLS
ALTER TABLE ai_insights ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can read own ai_insights" ON ai_insights
  FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Service can insert ai_insights" ON ai_insights
  FOR INSERT WITH CHECK (true);
CREATE POLICY "Users can update own ai_insights" ON ai_insights
  FOR UPDATE USING (auth.uid() = user_id);

-- 2. AI 주간 리포트 저장
CREATE TABLE IF NOT EXISTS public.ai_weekly_reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  week_start DATE NOT NULL,
  total_steps INTEGER DEFAULT 0,
  total_distance_km DOUBLE PRECISION DEFAULT 0,
  avg_daily_steps INTEGER DEFAULT 0,
  best_day_steps INTEGER DEFAULT 0,
  best_day_name TEXT DEFAULT '',
  vs_last_week DOUBLE PRECISION DEFAULT 0,
  missions_completed INTEGER DEFAULT 0,
  challenges_progress INTEGER DEFAULT 0,
  personalized_tip TEXT,
  insights_json JSONB DEFAULT '[]',
  activity_score INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(user_id, week_start)
);

CREATE INDEX IF NOT EXISTS idx_ai_reports_user_id ON ai_weekly_reports(user_id);

ALTER TABLE ai_weekly_reports ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can read own reports" ON ai_weekly_reports
  FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Service can insert reports" ON ai_weekly_reports
  FOR INSERT WITH CHECK (true);

-- 3. AI 챗봇 대화 기록
CREATE TABLE IF NOT EXISTS public.ai_chat_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  message TEXT NOT NULL,
  is_user BOOLEAN DEFAULT true,
  message_type TEXT DEFAULT 'text' CHECK (message_type IN ('text', 'insight', 'recommendation', 'report')),
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_ai_chat_user_id ON ai_chat_history(user_id);
CREATE INDEX IF NOT EXISTS idx_ai_chat_created_at ON ai_chat_history(created_at DESC);

ALTER TABLE ai_chat_history ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can read own chat" ON ai_chat_history
  FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own chat" ON ai_chat_history
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- 4. AI 알림 설정
CREATE TABLE IF NOT EXISTS public.ai_notification_settings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
  morning_motivation BOOLEAN DEFAULT true,
  goal_achieved BOOLEAN DEFAULT true,
  churn_risk_warning BOOLEAN DEFAULT true,
  streak_milestone BOOLEAN DEFAULT true,
  forest_growth BOOLEAN DEFAULT true,
  weekly_report BOOLEAN DEFAULT true,
  challenge_reminder BOOLEAN DEFAULT true,
  health_tips BOOLEAN DEFAULT false,
  quiet_hours_start INTEGER DEFAULT 22,
  quiet_hours_end INTEGER DEFAULT 7,
  updated_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE ai_notification_settings ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can read own settings" ON ai_notification_settings
  FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can upsert own settings" ON ai_notification_settings
  FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own settings" ON ai_notification_settings
  FOR UPDATE USING (auth.uid() = user_id);

-- 5. 활동 프로필 스냅샷 (주 1회 저장)
CREATE TABLE IF NOT EXISTS public.ai_activity_snapshots (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  snapshot_date DATE NOT NULL DEFAULT CURRENT_DATE,
  avg_daily_steps INTEGER DEFAULT 0,
  avg_weekly_steps INTEGER DEFAULT 0,
  max_daily_steps INTEGER DEFAULT 0,
  consistency_score DOUBLE PRECISION DEFAULT 0,
  current_streak INTEGER DEFAULT 0,
  longest_streak INTEGER DEFAULT 0,
  weekly_trend DOUBLE PRECISION DEFAULT 0,
  activity_level TEXT DEFAULT 'light',
  activity_score INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(user_id, snapshot_date)
);

CREATE INDEX IF NOT EXISTS idx_ai_snapshots_user_id ON ai_activity_snapshots(user_id);

ALTER TABLE ai_activity_snapshots ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can read own snapshots" ON ai_activity_snapshots
  FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Service can insert snapshots" ON ai_activity_snapshots
  FOR INSERT WITH CHECK (true);

-- 6. Forest 성장 예측 저장
CREATE TABLE IF NOT EXISTS public.ai_forest_predictions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  current_level INTEGER DEFAULT 1,
  current_progress DOUBLE PRECISION DEFAULT 0,
  estimated_days_to_next INTEGER DEFAULT 7,
  steps_needed INTEGER DEFAULT 0,
  steps_per_day_needed DOUBLE PRECISION DEFAULT 0,
  prediction_date TEXT DEFAULT '',
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(user_id)
);

ALTER TABLE ai_forest_predictions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can read own predictions" ON ai_forest_predictions
  FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Service can upsert predictions" ON ai_forest_predictions
  FOR INSERT WITH CHECK (true);
CREATE POLICY "Service can update predictions" ON ai_forest_predictions
  FOR UPDATE USING (true);

-- 트리거: ai_notification_settings 자동 생성 (회원가입 시)
CREATE OR REPLACE FUNCTION create_default_ai_settings()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.ai_notification_settings (user_id) VALUES (NEW.id)
  ON CONFLICT (user_id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 기존 트리거가 없으면 생성
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_create_ai_settings') THEN
    CREATE TRIGGER trg_create_ai_settings
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION create_default_ai_settings();
  END IF;
END $$;
