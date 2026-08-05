-- ================================================================
-- HealthON Community Comment Upgrade Migration v2
-- ================================================================
-- 이모지 / GIF / 이미지 첨부 / @멘션 / 알림 고도화

-- ================================================================
-- 1. community_comments 컬럼 추가
-- ================================================================

ALTER TABLE public.community_comments
  ADD COLUMN IF NOT EXISTS mentions JSONB DEFAULT '[]'::jsonb,
  ADD COLUMN IF NOT EXISTS images JSONB DEFAULT '[]'::jsonb,
  ADD COLUMN IF NOT EXISTS gif_url TEXT,
  ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ;

COMMENT ON COLUMN public.community_comments.mentions IS '멘션된 사용자 ID 목록';
COMMENT ON COLUMN public.community_comments.images IS '첨부 이미지 URL 목록';
COMMENT ON COLUMN public.community_comments.gif_url IS 'GIF URL';
COMMENT ON COLUMN public.community_comments.updated_at IS '수정 시각';

-- ================================================================
-- 2. community_notifications 테이블 생성
-- ================================================================

CREATE TABLE IF NOT EXISTS public.community_notifications (
  id BIGSERIAL PRIMARY KEY,
  from_user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  to_user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  post_id UUID REFERENCES public.community_posts(id) ON DELETE CASCADE,
  comment_id UUID REFERENCES public.community_comments(id) ON DELETE CASCADE,
  type TEXT NOT NULL CHECK (type IN ('mention', 'reply', 'like', 'follow')),
  is_read BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE public.community_notifications IS '커뮤니티 알림 (멘션, 답글, 좋아요, 팔로우)';

-- 인덱스
CREATE INDEX IF NOT EXISTS idx_notifications_to_user_unread
  ON public.community_notifications(to_user_id, is_read);

CREATE INDEX IF NOT EXISTS idx_notifications_created_at
  ON public.community_notifications(created_at DESC);

-- ================================================================
-- 3. community_notifications RLS
-- ================================================================

ALTER TABLE public.community_notifications ENABLE ROW LEVEL SECURITY;

-- 수신자만 읽기 가능
CREATE POLICY "notifications_select_own" ON public.community_notifications
  FOR SELECT USING (auth.uid() = to_user_id);

-- 시스템만 insert (RPC 통해)
CREATE POLICY "notifications_insert_service" ON public.community_notifications
  FOR INSERT WITH CHECK (true);

-- 수신자만 update (읽음 처리)
CREATE POLICY "notifications_update_own" ON public.community_notifications
  FOR UPDATE USING (auth.uid() = to_user_id);

-- ================================================================
-- 4. 멘션 알림 생성 RPC
-- ================================================================

CREATE OR REPLACE FUNCTION public.create_mention_notification(
  p_from_user_id UUID,
  p_to_user_id UUID,
  p_post_id UUID,
  p_comment_id UUID,
  p_type TEXT DEFAULT 'mention'
) RETURNS void AS $$
BEGIN
  INSERT INTO public.community_notifications (from_user_id, to_user_id, post_id, comment_id, type)
  VALUES (p_from_user_id, p_to_user_id, p_post_id, p_comment_id, p_type);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ================================================================
-- 5. community_comments 인덱스
-- ================================================================

CREATE INDEX IF NOT EXISTS idx_community_comments_like_count
  ON public.community_comments(like_count DESC);

CREATE INDEX IF NOT EXISTS idx_community_comments_created_at_asc
  ON public.community_comments(created_at ASC);

CREATE INDEX IF NOT EXISTS idx_community_comments_created_at_desc
  ON public.community_comments(created_at DESC);

CREATE INDEX IF NOT EXISTS idx_community_comment_likes_user_comment
  ON public.community_comment_likes(user_id, comment_id);

-- ================================================================
-- 6. Storage bucket (Supabase Dashboard에서 수동 생성 권장)
-- ================================================================
-- bucket name: community-comment-images
-- public access: true
-- RLS policy: authenticated SELECT, authenticated INSERT
