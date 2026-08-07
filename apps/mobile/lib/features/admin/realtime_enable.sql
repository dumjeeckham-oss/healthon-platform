-- ================================================================
-- HealthON — Realtime Publication 등록
--
-- admin_migration_complete.sql + push_migration.sql 실행 후 실행.
-- community 테이블은 community_migration.sql 실행 후 별도 등록.
-- ================================================================

-- 관리자 CMS 테이블
ALTER PUBLICATION supabase_realtime ADD TABLE public.admin_notices;
ALTER PUBLICATION supabase_realtime ADD TABLE public.challenge_definitions;
ALTER PUBLICATION supabase_realtime ADD TABLE public.mission_definitions;
ALTER PUBLICATION supabase_realtime ADD TABLE public.forest_seasons;
ALTER PUBLICATION supabase_realtime ADD TABLE public.admin_banners;

-- 푸시 알림 큐
ALTER PUBLICATION supabase_realtime ADD TABLE public.push_notification_queue;
