-- ================================================================
-- HealthON — Realtime Publication 등록 (IDEMPOTENT)
-- 이미 등록된 테이블은 자동 건너뜀
-- ================================================================

DO $$ BEGIN ALTER PUBLICATION supabase_realtime ADD TABLE public.admin_notices; EXCEPTION WHEN duplicate_object THEN NULL; END; $$;
DO $$ BEGIN ALTER PUBLICATION supabase_realtime ADD TABLE public.challenge_definitions; EXCEPTION WHEN duplicate_object THEN NULL; END; $$;
DO $$ BEGIN ALTER PUBLICATION supabase_realtime ADD TABLE public.mission_definitions; EXCEPTION WHEN duplicate_object THEN NULL; END; $$;
DO $$ BEGIN ALTER PUBLICATION supabase_realtime ADD TABLE public.forest_seasons; EXCEPTION WHEN duplicate_object THEN NULL; END; $$;
DO $$ BEGIN ALTER PUBLICATION supabase_realtime ADD TABLE public.admin_banners; EXCEPTION WHEN duplicate_object THEN NULL; END; $$;
DO $$ BEGIN ALTER PUBLICATION supabase_realtime ADD TABLE public.push_notification_queue; EXCEPTION WHEN duplicate_object THEN NULL; END; $$;
