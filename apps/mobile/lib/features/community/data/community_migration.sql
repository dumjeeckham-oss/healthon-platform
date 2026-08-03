-- ===============================================================
-- HealthON Community Supabase SQL Migration
-- ===============================================================
-- 실행 순서대로 기재. Supabase SQL Editor 에서 순차 실행.

-- ===============================================================
-- 1. community_posts
-- ===============================================================

CREATE TABLE IF NOT EXISTS public.community_posts (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id       UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  category      TEXT NOT NULL DEFAULT 'free'
                CHECK (category IN ('notice','challenge','walking','forest','health','photo','free','question','event')),
  title         TEXT NOT NULL,
  content       TEXT NOT NULL DEFAULT '',
  images        JSONB DEFAULT '[]'::jsonb,
  video_url     TEXT,
  forest_snapshot  JSONB,
  walking_snapshot JSONB,
  badge_snapshot   JSONB,
  location      TEXT,
  latitude      DOUBLE PRECISION,
  longitude     DOUBLE PRECISION,
  visibility    TEXT NOT NULL DEFAULT 'public'
                CHECK (visibility IN ('public','followers','private')),
  like_count    INTEGER NOT NULL DEFAULT 0,
  comment_count INTEGER NOT NULL DEFAULT 0,
  bookmark_count INTEGER NOT NULL DEFAULT 0,
  report_count  INTEGER NOT NULL DEFAULT 0,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_community_posts_user_id    ON public.community_posts(user_id);
CREATE INDEX IF NOT EXISTS idx_community_posts_category   ON public.community_posts(category);
CREATE INDEX IF NOT EXISTS idx_community_posts_created_at ON public.community_posts(created_at DESC);

-- updated_at trigger
CREATE OR REPLACE FUNCTION public.community_posts_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_community_posts_updated_at ON public.community_posts;
CREATE TRIGGER trg_community_posts_updated_at
  BEFORE UPDATE ON public.community_posts
  FOR EACH ROW EXECUTE FUNCTION public.community_posts_updated_at();

-- RLS
ALTER TABLE public.community_posts ENABLE ROW LEVEL SECURITY;

-- 누구나 읽기 가능 (visibility=public 인 글은)
CREATE POLICY "Anyone can read public posts"
  ON public.community_posts FOR SELECT
  USING (visibility = 'public' OR auth.uid() = user_id);

-- 본인 글만 작성
CREATE POLICY "Users can insert own posts"
  ON public.community_posts FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- 본인 글만 수정
CREATE POLICY "Users can update own posts"
  ON public.community_posts FOR UPDATE
  USING (auth.uid() = user_id);

-- 본인 글만 삭제
CREATE POLICY "Users can delete own posts"
  ON public.community_posts FOR DELETE
  USING (auth.uid() = user_id);


-- ===============================================================
-- 2. community_comments
-- ===============================================================

CREATE TABLE IF NOT EXISTS public.community_comments (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id    UUID NOT NULL REFERENCES public.community_posts(id) ON DELETE CASCADE,
  user_id    UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  parent_id  UUID REFERENCES public.community_comments(id) ON DELETE CASCADE,
  content    TEXT NOT NULL DEFAULT '',
  like_count INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_community_comments_post_id    ON public.community_comments(post_id);
CREATE INDEX IF NOT EXISTS idx_community_comments_parent_id   ON public.community_comments(parent_id);
CREATE INDEX IF NOT EXISTS idx_community_comments_created_at  ON public.community_comments(created_at);

-- RLS
ALTER TABLE public.community_comments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can read comments"
  ON public.community_comments FOR SELECT
  USING (true);

CREATE POLICY "Users can insert own comments"
  ON public.community_comments FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own comments"
  ON public.community_comments FOR DELETE
  USING (auth.uid() = user_id);


-- ===============================================================
-- 3. community_post_likes
-- ===============================================================

CREATE TABLE IF NOT EXISTS public.community_post_likes (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  post_id    UUID NOT NULL REFERENCES public.community_posts(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(user_id, post_id)
);

CREATE INDEX IF NOT EXISTS idx_community_post_likes_post_id ON public.community_post_likes(post_id);
CREATE INDEX IF NOT EXISTS idx_community_post_likes_user_id ON public.community_post_likes(user_id);

ALTER TABLE public.community_post_likes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can read likes"
  ON public.community_post_likes FOR SELECT
  USING (true);

CREATE POLICY "Users can like posts"
  ON public.community_post_likes FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can unlike own likes"
  ON public.community_post_likes FOR DELETE
  USING (auth.uid() = user_id);


-- ===============================================================
-- 4. community_bookmarks
-- ===============================================================

CREATE TABLE IF NOT EXISTS public.community_bookmarks (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  post_id    UUID NOT NULL REFERENCES public.community_posts(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(user_id, post_id)
);

CREATE INDEX IF NOT EXISTS idx_community_bookmarks_user_id ON public.community_bookmarks(user_id);

ALTER TABLE public.community_bookmarks ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own bookmarks"
  ON public.community_bookmarks FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own bookmarks"
  ON public.community_bookmarks FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own bookmarks"
  ON public.community_bookmarks FOR DELETE
  USING (auth.uid() = user_id);


-- ===============================================================
-- 5. community_comment_likes
-- ===============================================================

CREATE TABLE IF NOT EXISTS public.community_comment_likes (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  comment_id UUID NOT NULL REFERENCES public.community_comments(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(user_id, comment_id)
);

CREATE INDEX IF NOT EXISTS idx_community_comment_likes_comment_id ON public.community_comment_likes(comment_id);

ALTER TABLE public.community_comment_likes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can read comment likes"
  ON public.community_comment_likes FOR SELECT
  USING (true);

CREATE POLICY "Users can like comments"
  ON public.community_comment_likes FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can unlike own comment likes"
  ON public.community_comment_likes FOR DELETE
  USING (auth.uid() = user_id);


-- ===============================================================
-- 6. RPC Functions — Count Increment/Decrement
-- ===============================================================

-- comment_count 증가
CREATE OR REPLACE FUNCTION public.increment_comment_count(p_post_id UUID)
RETURNS void AS $$
BEGIN
  UPDATE public.community_posts
  SET comment_count = comment_count + 1
  WHERE id = p_post_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- comment_count 감소
CREATE OR REPLACE FUNCTION public.decrement_comment_count(p_post_id UUID)
RETURNS void AS $$
BEGIN
  UPDATE public.community_posts
  SET comment_count = GREATEST(comment_count - 1, 0)
  WHERE id = p_post_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- like_count 증가
CREATE OR REPLACE FUNCTION public.increment_like_count(p_post_id UUID)
RETURNS void AS $$
BEGIN
  UPDATE public.community_posts
  SET like_count = like_count + 1
  WHERE id = p_post_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- like_count 감소
CREATE OR REPLACE FUNCTION public.decrement_like_count(p_post_id UUID)
RETURNS void AS $$
BEGIN
  UPDATE public.community_posts
  SET like_count = GREATEST(like_count - 1, 0)
  WHERE id = p_post_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- bookmark_count 증가
CREATE OR REPLACE FUNCTION public.increment_bookmark_count(p_post_id UUID)
RETURNS void AS $$
BEGIN
  UPDATE public.community_posts
  SET bookmark_count = bookmark_count + 1
  WHERE id = p_post_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- bookmark_count 감소
CREATE OR REPLACE FUNCTION public.decrement_bookmark_count(p_post_id UUID)
RETURNS void AS $$
BEGIN
  UPDATE public.community_posts
  SET bookmark_count = GREATEST(bookmark_count - 1, 0)
  WHERE id = p_post_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- comment_like_count 증가
CREATE OR REPLACE FUNCTION public.increment_comment_like_count(p_comment_id UUID)
RETURNS void AS $$
BEGIN
  UPDATE public.community_comments
  SET like_count = like_count + 1
  WHERE id = p_comment_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- comment_like_count 감소
CREATE OR REPLACE FUNCTION public.decrement_comment_like_count(p_comment_id UUID)
RETURNS void AS $$
BEGIN
  UPDATE public.community_comments
  SET like_count = GREATEST(like_count - 1, 0)
  WHERE id = p_comment_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- ===============================================================
-- 7. Storage Bucket (수동 생성 필요)
-- ===============================================================
-- Supabase Dashboard → Storage → New Bucket
-- Name: community-images
-- Public bucket: YES (또는 정책 설정)
-- 권한: 인증된 사용자가 읽기/쓰기 가능

-- (선택) Storage 정책 SQL
-- CREATE POLICY "Public read community images"
--   ON storage.objects FOR SELECT
--   USING (bucket_id = 'community-images');
--
-- CREATE POLICY "Auth users can upload community images"
--   ON storage.objects FOR INSERT
--   WITH CHECK (bucket_id = 'community-images' AND auth.role() = 'authenticated');
