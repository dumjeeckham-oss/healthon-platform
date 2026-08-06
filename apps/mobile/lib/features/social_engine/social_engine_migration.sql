-- ================================================================
-- HealthON Social Engine Migration
--
-- Activity Events / Feed / Social Graph / Notifications
-- ================================================================

-- ================================================================
-- 1. activity_events 테이블
-- ================================================================

CREATE TABLE IF NOT EXISTS public.activity_events (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  type        TEXT NOT NULL,
  data        JSONB NOT NULL DEFAULT '{}'::jsonb,
  dispatched  BOOLEAN NOT NULL DEFAULT false,
  feed_post_id UUID REFERENCES public.community_posts(id) ON DELETE SET NULL,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE public.activity_events IS '사용자 활동 이벤트 로그 (Social Engine)';

CREATE INDEX IF NOT EXISTS idx_activity_events_user
  ON public.activity_events(user_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_activity_events_undispatched
  ON public.activity_events(dispatched, created_at)
  WHERE dispatched = false;

-- RLS
ALTER TABLE public.activity_events ENABLE ROW LEVEL SECURITY;

CREATE POLICY "activity_events_select_own" ON public.activity_events
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "activity_events_insert_service" ON public.activity_events
  FOR INSERT WITH CHECK (true);

-- ================================================================
-- 2. social_graph 테이블 (친구/팔로우/가족)
-- ================================================================

CREATE TABLE IF NOT EXISTS public.social_graph (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  from_user_id  UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  to_user_id    UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  relation_type TEXT NOT NULL CHECK (relation_type IN ('follow', 'friend', 'family')),
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT uq_social_graph UNIQUE (from_user_id, to_user_id, relation_type)
);

COMMENT ON TABLE public.social_graph IS '소셜 관계 그래프';

CREATE INDEX IF NOT EXISTS idx_social_graph_from
  ON public.social_graph(from_user_id);

CREATE INDEX IF NOT EXISTS idx_social_graph_to
  ON public.social_graph(to_user_id);

ALTER TABLE public.social_graph ENABLE ROW LEVEL SECURITY;

CREATE POLICY "social_graph_select_own" ON public.social_graph
  FOR SELECT USING (auth.uid() = from_user_id OR auth.uid() = to_user_id);

CREATE POLICY "social_graph_insert_own" ON public.social_graph
  FOR INSERT WITH CHECK (auth.uid() = from_user_id);

CREATE POLICY "social_graph_delete_own" ON public.social_graph
  FOR DELETE USING (auth.uid() = from_user_id);

-- ================================================================
-- 3. feed_items 테이블 (타임라인용)
-- ================================================================

CREATE TABLE IF NOT EXISTS public.feed_items (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id       UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  actor_name    TEXT,
  type          TEXT NOT NULL DEFAULT 'normal',
  title         TEXT NOT NULL,
  body          TEXT,
  data          JSONB DEFAULT '{}'::jsonb,
  image_url     TEXT,
  post_id       UUID REFERENCES public.community_posts(id) ON DELETE SET NULL,
  like_count    INTEGER NOT NULL DEFAULT 0,
  comment_count INTEGER NOT NULL DEFAULT 0,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE public.feed_items IS '통합 타임라인 피드';

CREATE INDEX IF NOT EXISTS idx_feed_items_created
  ON public.feed_items(created_at DESC);

CREATE INDEX IF NOT EXISTS idx_feed_items_user
  ON public.feed_items(user_id);

ALTER TABLE public.feed_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "feed_items_select_all" ON public.feed_items
  FOR SELECT USING (true);

CREATE POLICY "feed_items_insert_service" ON public.feed_items
  FOR INSERT WITH CHECK (true);

-- ================================================================
-- 4. RPC: dispatch_activity_event
--    ActivityEvent → Feed + Notification 한 번에
-- ================================================================

CREATE OR REPLACE FUNCTION public.create_activity_feed(
  p_user_id      UUID,
  p_actor_name   TEXT,
  p_type         TEXT,
  p_title        TEXT,
  p_body         TEXT DEFAULT NULL,
  p_data         JSONB DEFAULT '{}'::jsonb,
  p_image_url    TEXT DEFAULT NULL,
  p_post_id      UUID DEFAULT NULL
) RETURNS UUID AS $$
DECLARE
  v_feed_id UUID := gen_random_uuid();
BEGIN
  INSERT INTO public.feed_items (
    id, user_id, actor_name, type, title, body, data, image_url, post_id
  ) VALUES (
    v_feed_id, p_user_id, p_actor_name, p_type, p_title, p_body, p_data, p_image_url, p_post_id
  );

  RETURN v_feed_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ================================================================
-- 5. user_ranking_cache (랭킹 변동 추적용)
-- ================================================================

CREATE TABLE IF NOT EXISTS public.user_ranking_cache (
  user_id       UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  weekly_rank   INTEGER NOT NULL DEFAULT 999,
  monthly_rank  INTEGER NOT NULL DEFAULT 999,
  alltime_rank  INTEGER NOT NULL DEFAULT 999,
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE public.user_ranking_cache IS '사용자별 마지막 랭킹 캐시 (변동 감지용)';

ALTER TABLE public.user_ranking_cache ENABLE ROW LEVEL SECURITY;

CREATE POLICY "ranking_cache_select_own" ON public.user_ranking_cache
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "ranking_cache_insert_service" ON public.user_ranking_cache
  FOR INSERT WITH CHECK (true);

CREATE POLICY "ranking_cache_update_service" ON public.user_ranking_cache
  FOR UPDATE USING (true);

-- ================================================================
-- 6. RPC: get_feed_candidates (타임라인 후보 조회)
-- ================================================================

CREATE OR REPLACE FUNCTION public.get_feed_candidates(
  p_viewer_id UUID DEFAULT NULL,
  p_limit     INTEGER DEFAULT 50,
  p_offset    INTEGER DEFAULT 0
) RETURNS SETOF JSONB AS $$
BEGIN
  RETURN QUERY
  SELECT
    to_jsonb(p) || jsonb_build_object('_source', 'post')
  FROM community_posts p
  WHERE p.created_at > NOW() - INTERVAL '30 days'
  UNION ALL
  SELECT
    to_jsonb(f) || jsonb_build_object('_source', 'feed')
  FROM feed_items f
  WHERE f.created_at > NOW() - INTERVAL '30 days'
  ORDER BY created_at DESC
  LIMIT p_limit
  OFFSET p_offset;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
