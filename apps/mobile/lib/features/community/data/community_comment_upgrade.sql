-- ================================================================
-- HealthON Community Comment Upgrade Migration v3
-- ================================================================
--
-- 기존 community_notifications 구조를 유지합니다:
--   id uuid, user_id uuid, type text, title text, body text,
--   data jsonb, is_read boolean, created_at timestamptz
--
-- 절대 DROP 없음. ADD IF NOT EXISTS / CREATE OR REPLACE 만 사용.
-- ================================================================

-- ================================================================
-- ① community_comments 컬럼 추가
-- ================================================================

ALTER TABLE public.community_comments
  ADD COLUMN IF NOT EXISTS mentions     JSONB       DEFAULT '[]'::jsonb;

ALTER TABLE public.community_comments
  ADD COLUMN IF NOT EXISTS images       JSONB       DEFAULT '[]'::jsonb;

ALTER TABLE public.community_comments
  ADD COLUMN IF NOT EXISTS gif_url      TEXT;

ALTER TABLE public.community_comments
  ADD COLUMN IF NOT EXISTS updated_at   TIMESTAMPTZ;

ALTER TABLE public.community_comments
  ADD COLUMN IF NOT EXISTS edited       BOOLEAN     DEFAULT false;

ALTER TABLE public.community_comments
  ADD COLUMN IF NOT EXISTS reply_count  INTEGER     DEFAULT 0;

COMMENT ON COLUMN public.community_comments.mentions    IS '멘션된 사용자 ID 목록';
COMMENT ON COLUMN public.community_comments.images      IS '첨부 이미지 URL 목록';
COMMENT ON COLUMN public.community_comments.gif_url     IS 'GIF URL';
COMMENT ON COLUMN public.community_comments.updated_at  IS '수정 시각';
COMMENT ON COLUMN public.community_comments.edited      IS '수정 여부 (트리거로 자동 설정)';
COMMENT ON COLUMN public.community_comments.reply_count IS '대댓글 개수 (트리거로 자동 집계)';

-- ================================================================
-- ② community_notifications — 기존 테이블 그대로 사용
--    (CREATE TABLE IF NOT EXISTS 없음 — 이미 운영 중)
-- ================================================================

-- ================================================================
-- ③ RPC — 멘션 알림
--    기존 community_notifications(user_id, type, title, body, data)
--    구조에 맞춰 INSERT
-- ================================================================

CREATE OR REPLACE FUNCTION public.create_mention_notification(
  p_user_id      UUID,
  p_from_user_id UUID,
  p_post_id      UUID,
  p_comment_id   UUID,
  p_from_name    TEXT DEFAULT '알 수 없음'
) RETURNS UUID AS $$
DECLARE
  v_id UUID := gen_random_uuid();
BEGIN
  INSERT INTO public.community_notifications (
    id, user_id, type, title, body, data, is_read
  ) VALUES (
    v_id,
    p_user_id,
    'mention',
    p_from_name || '님이 회원님을 멘션했습니다.',
    '댓글에서 회원님을 언급했습니다.',
    jsonb_build_object(
      'postId',    p_post_id,
      'commentId', p_comment_id,
      'fromUserId', p_from_user_id,
      'type',      'mention'
    ),
    false
  );

  RETURN v_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION public.create_mention_notification(
  UUID, UUID, UUID, UUID, TEXT
) IS '@멘션 알림 생성 — community_notifications 테이블에 INSERT';

-- ================================================================
-- ③ RPC — 답글 알림
-- ================================================================

CREATE OR REPLACE FUNCTION public.create_reply_notification(
  p_user_id      UUID,
  p_from_user_id UUID,
  p_post_id      UUID,
  p_comment_id   UUID,
  p_from_name    TEXT DEFAULT '알 수 없음'
) RETURNS UUID AS $$
DECLARE
  v_id UUID := gen_random_uuid();
BEGIN
  INSERT INTO public.community_notifications (
    id, user_id, type, title, body, data, is_read
  ) VALUES (
    v_id,
    p_user_id,
    'reply',
    p_from_name || '님이 댓글에 답글을 남겼습니다.',
    '회원님의 댓글에 새로운 답글이 달렸습니다.',
    jsonb_build_object(
      'postId',    p_post_id,
      'commentId', p_comment_id,
      'fromUserId', p_from_user_id,
      'type',      'reply'
    ),
    false
  );

  RETURN v_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION public.create_reply_notification(
  UUID, UUID, UUID, UUID, TEXT
) IS '댓글 답글 알림 생성';

-- ================================================================
-- ③ RPC — 댓글 좋아요 알림
-- ================================================================

CREATE OR REPLACE FUNCTION public.create_comment_like_notification(
  p_user_id      UUID,
  p_from_user_id UUID,
  p_post_id      UUID,
  p_comment_id   UUID,
  p_from_name    TEXT DEFAULT '알 수 없음'
) RETURNS UUID AS $$
DECLARE
  v_id UUID := gen_random_uuid();
BEGIN
  INSERT INTO public.community_notifications (
    id, user_id, type, title, body, data, is_read
  ) VALUES (
    v_id,
    p_user_id,
    'like',
    p_from_name || '님이 회원님의 댓글을 좋아합니다.',
    '회원님의 댓글에 좋아요가 추가되었습니다.',
    jsonb_build_object(
      'postId',    p_post_id,
      'commentId', p_comment_id,
      'fromUserId', p_from_user_id,
      'type',      'like'
    ),
    false
  );

  RETURN v_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION public.create_comment_like_notification(
  UUID, UUID, UUID, UUID, TEXT
) IS '댓글 좋아요 알림 생성';

-- ================================================================
-- ④ Trigger — 댓글 수정 시 updated_at + edited 자동 설정
-- ================================================================

CREATE OR REPLACE FUNCTION public.community_comments_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  NEW.edited     = true;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 이미 트리거가 있을 수 있으므로 안전하게 처리
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger
    WHERE tgname = 'trg_community_comments_updated_at'
  ) THEN
    CREATE TRIGGER trg_community_comments_updated_at
      BEFORE UPDATE ON public.community_comments
      FOR EACH ROW
      EXECUTE FUNCTION public.community_comments_updated_at();
  END IF;
END;
$$;

COMMENT ON TRIGGER trg_community_comments_updated_at
  ON public.community_comments
  IS '댓글 UPDATE 시 updated_at=now(), edited=true 자동 설정';

-- ================================================================
-- ⑤ Trigger — reply_count 자동 증감
-- ================================================================

CREATE OR REPLACE FUNCTION public.community_comments_reply_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' AND NEW.parent_id IS NOT NULL THEN
    -- 대댓글 추가 → 부모 댓글 reply_count +1
    UPDATE public.community_comments
    SET reply_count = reply_count + 1
    WHERE id = NEW.parent_id;

  ELSIF TG_OP = 'DELETE' AND OLD.parent_id IS NOT NULL THEN
    -- 대댓글 삭제 → 부모 댓글 reply_count -1
    UPDATE public.community_comments
    SET reply_count = GREATEST(reply_count - 1, 0)
    WHERE id = OLD.parent_id;
  END IF;

  -- INSERT면 NEW, DELETE면 OLD 반환
  IF TG_OP = 'INSERT' THEN
    RETURN NEW;
  ELSE
    RETURN OLD;
  END IF;
END;
$$ LANGUAGE plpgsql;

-- INSERT 트리거
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger
    WHERE tgname = 'trg_community_comments_reply_count_ins'
  ) THEN
    CREATE TRIGGER trg_community_comments_reply_count_ins
      AFTER INSERT ON public.community_comments
      FOR EACH ROW
      EXECUTE FUNCTION public.community_comments_reply_count();
  END IF;
END;
$$;

-- DELETE 트리거
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger
    WHERE tgname = 'trg_community_comments_reply_count_del'
  ) THEN
    CREATE TRIGGER trg_community_comments_reply_count_del
      AFTER DELETE ON public.community_comments
      FOR EACH ROW
      EXECUTE FUNCTION public.community_comments_reply_count();
  END IF;
END;
$$;

COMMENT ON TRIGGER trg_community_comments_reply_count_ins
  ON public.community_comments
  IS '대댓글 INSERT 시 부모 reply_count +1';

COMMENT ON TRIGGER trg_community_comments_reply_count_del
  ON public.community_comments
  IS '대댓글 DELETE 시 부모 reply_count -1';

-- ================================================================
-- ⑥ 인덱스
-- ================================================================

-- created_at 정렬
CREATE INDEX IF NOT EXISTS idx_community_comments_created_at_asc
  ON public.community_comments(created_at ASC);

CREATE INDEX IF NOT EXISTS idx_community_comments_created_at_desc
  ON public.community_comments(created_at DESC);

-- updated_at 정렬 (수정된 댓글)
CREATE INDEX IF NOT EXISTS idx_community_comments_updated_at
  ON public.community_comments(updated_at DESC);

-- like_count (인기순)
CREATE INDEX IF NOT EXISTS idx_community_comments_like_count
  ON public.community_comments(like_count DESC);

-- reply_count (답글 많은 순)
CREATE INDEX IF NOT EXISTS idx_community_comments_reply_count
  ON public.community_comments(reply_count DESC);

-- mentions GIN 인덱스 (@멘션 검색)
CREATE INDEX IF NOT EXISTS idx_community_comments_mentions_gin
  ON public.community_comments USING gin (mentions);

-- ================================================================
-- ⑦ RLS 정책 — 기존 유지 + 필요시 보강
--    (기존 policy가 이미 존재하면 IF NOT EXISTS 불가 → DO 블록)
-- ================================================================

-- community_comments: 본인 댓글 수정 허용
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE policyname = 'Users can update own comments'
      AND tablename = 'community_comments'
  ) THEN
    CREATE POLICY "Users can update own comments"
      ON public.community_comments FOR UPDATE
      USING (auth.uid() = user_id);
  END IF;
END;
$$;

-- community_notifications: 기존 정책 그대로 — 수정하지 않음
-- (이미 notifications_select_own / notifications_insert_service / notifications_update_own 존재)

-- ================================================================
-- 실행 완료
-- ================================================================
-- 아래는 예상 결과입니다:
--
-- [실행 순서]
-- 1. 컬럼 6개 추가 (mentions, images, gif_url, updated_at, edited, reply_count)
-- 2. RPC 3개 생성 (create_mention_notification, create_reply_notification,
--    create_comment_like_notification)
-- 3. updated_at + edited 트리거 1개 생성
-- 4. reply_count 트리거 2개 생성 (INSERT, DELETE)
-- 5. 인덱스 6개 생성
-- 6. RLS 보강 (본인 댓글 수정 정책)
--
-- [예상 결과]
-- ✅ community_comments 에 6개 컬럼 추가됨
-- ✅ create_mention_notification(…) 호출 시
--    community_notifications 에 {user_id, type:'mention', title, body, data} INSERT
-- ✅ 댓글 UPDATE 시 updated_at=now(), edited=true 자동
-- ✅ 대댓글 INSERT 시 부모 reply_count +1
-- ✅ 대댓글 DELETE 시 부모 reply_count -1
-- ✅ 모든 인덱스 생성 완료
-- ✅ 기존 테이블/데이터/RPC/정책 전혀 손상 없음
-- ================================================================
