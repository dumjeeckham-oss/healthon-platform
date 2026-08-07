-- ================================================================
-- HealthON Phase 6 — Family 고도화 Migration (FIXED)
-- 모든 CREATE TABLE 먼저 → 그 다음 RLS + 인덱스 + RPC
-- ================================================================

-- ================================================================
-- 1. families
-- ================================================================

CREATE TABLE IF NOT EXISTS public.families (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name              TEXT NOT NULL,
  description       TEXT DEFAULT '',
  invite_code       TEXT NOT NULL UNIQUE,
  leader_id         UUID NOT NULL REFERENCES auth.users(id),
  member_count      INTEGER NOT NULL DEFAULT 1,
  total_steps       BIGINT NOT NULL DEFAULT 0,
  total_distance_km DOUBLE PRECISION NOT NULL DEFAULT 0,
  forest_level      INTEGER NOT NULL DEFAULT 1,
  weekly_goal       INTEGER NOT NULL DEFAULT 70000,
  is_active         BOOLEAN NOT NULL DEFAULT true,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ================================================================
-- 2. family_members
-- ================================================================

CREATE TABLE IF NOT EXISTS public.family_members (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  family_id   UUID NOT NULL REFERENCES public.families(id) ON DELETE CASCADE,
  user_id     UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  role        TEXT NOT NULL DEFAULT 'member' CHECK (role IN ('leader','member')),
  status      TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('pending','active','declined','left')),
  joined_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(family_id, user_id)
);

-- ================================================================
-- 3. family_cheers
-- ================================================================

CREATE TABLE IF NOT EXISTS public.family_cheers (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  family_id     UUID NOT NULL REFERENCES public.families(id) ON DELETE CASCADE,
  from_user_id  UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  to_user_id    UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  message       TEXT DEFAULT '응원해요! 💪',
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ================================================================
-- 4. family_challenge_participation
-- ================================================================

CREATE TABLE IF NOT EXISTS public.family_challenge_participation (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  family_id     UUID NOT NULL REFERENCES public.families(id) ON DELETE CASCADE,
  challenge_id  UUID NOT NULL REFERENCES public.challenge_definitions(id) ON DELETE CASCADE,
  weekly_steps  INTEGER NOT NULL DEFAULT 0,
  progress      DOUBLE PRECISION NOT NULL DEFAULT 0,
  completed     BOOLEAN NOT NULL DEFAULT false,
  completed_at  TIMESTAMPTZ,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(family_id, challenge_id)
);

-- ================================================================
-- 5. INDEXES
-- ================================================================

CREATE UNIQUE INDEX IF NOT EXISTS idx_families_invite_code ON public.families(invite_code);
CREATE INDEX IF NOT EXISTS idx_families_leader ON public.families(leader_id);
CREATE INDEX IF NOT EXISTS idx_family_members_user ON public.family_members(user_id);
CREATE INDEX IF NOT EXISTS idx_family_members_family ON public.family_members(family_id);
CREATE INDEX IF NOT EXISTS idx_family_cheers_family ON public.family_cheers(family_id, created_at DESC);

-- ================================================================
-- 6. RLS (모든 테이블 생성 후)
-- ================================================================

ALTER TABLE public.families ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.family_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.family_cheers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.family_challenge_participation ENABLE ROW LEVEL SECURITY;

-- families
DROP POLICY IF EXISTS "families_select_members" ON public.families;
DROP POLICY IF EXISTS "families_insert_auth" ON public.families;
DROP POLICY IF EXISTS "families_update_leader" ON public.families;

CREATE POLICY "families_select_members" ON public.families
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.family_members fm
      WHERE fm.family_id = families.id AND fm.user_id = auth.uid()
    )
  );

CREATE POLICY "families_insert_auth" ON public.families
  FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "families_update_leader" ON public.families
  FOR UPDATE USING (leader_id = auth.uid());

-- family_members
DROP POLICY IF EXISTS "family_members_select" ON public.family_members;
DROP POLICY IF EXISTS "family_members_insert_auth" ON public.family_members;
DROP POLICY IF EXISTS "family_members_update_own" ON public.family_members;

CREATE POLICY "family_members_select" ON public.family_members
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "family_members_insert_auth" ON public.family_members
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "family_members_update_own" ON public.family_members
  FOR UPDATE USING (auth.uid() = user_id);

-- family_cheers
DROP POLICY IF EXISTS "family_cheers_select_members" ON public.family_cheers;
DROP POLICY IF EXISTS "family_cheers_insert_members" ON public.family_cheers;

CREATE POLICY "family_cheers_select_members" ON public.family_cheers
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM public.family_members fm WHERE fm.family_id = family_cheers.family_id AND fm.user_id = auth.uid())
  );

CREATE POLICY "family_cheers_insert_members" ON public.family_cheers
  FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM public.family_members fm WHERE fm.family_id = family_cheers.family_id AND fm.user_id = auth.uid())
  );

-- family_challenge_participation
DROP POLICY IF EXISTS "family_challenge_select" ON public.family_challenge_participation;

CREATE POLICY "family_challenge_select" ON public.family_challenge_participation
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM public.family_members fm WHERE fm.family_id = family_challenge_participation.family_id AND fm.user_id = auth.uid())
  );

-- ================================================================
-- 7. RPC: get_family_ranking
-- ================================================================

CREATE OR REPLACE FUNCTION public.get_family_ranking(
  p_family_id UUID
) RETURNS TABLE (
  user_id UUID,
  name TEXT,
  photo_url TEXT,
  today_steps BIGINT,
  weekly_steps BIGINT,
  forest_level INTEGER,
  streak INTEGER
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    u.id, u.name, u.photo_url,
    COALESCE(h.steps, 0)::BIGINT,
    COALESCE(w.total_weekly, 0)::BIGINT,
    1,
    0
  FROM public.family_members fm
  LEFT JOIN public.users u ON fm.user_id = u.id
  LEFT JOIN LATERAL (
    SELECT hd.steps FROM public.health_daily hd
    WHERE hd.user_id = fm.user_id AND hd.date = CURRENT_DATE
  ) h ON true
  LEFT JOIN LATERAL (
    SELECT COALESCE(SUM(hd2.steps), 0)::BIGINT AS total_weekly
    FROM public.health_daily hd2
    WHERE hd2.user_id = fm.user_id
      AND hd2.date >= CURRENT_DATE - INTERVAL '6 days'
  ) w ON true
  WHERE fm.family_id = p_family_id AND fm.status = 'active'
  ORDER BY COALESCE(h.steps, 0) DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ================================================================
-- 8. RPC: join_family_by_code
-- ================================================================

CREATE OR REPLACE FUNCTION public.join_family_by_code(
  p_code TEXT,
  p_user_id UUID
) RETURNS UUID AS $$
DECLARE
  v_family_id UUID;
BEGIN
  SELECT id INTO v_family_id FROM public.families WHERE invite_code = p_code AND is_active = true;
  IF v_family_id IS NULL THEN
    RAISE EXCEPTION 'Invalid invite code';
  END IF;

  IF EXISTS (SELECT 1 FROM public.family_members WHERE family_id = v_family_id AND user_id = p_user_id) THEN
    RAISE EXCEPTION 'Already a member';
  END IF;

  INSERT INTO public.family_members (family_id, user_id, role, status)
  VALUES (v_family_id, p_user_id, 'member', 'active');

  UPDATE public.families SET member_count = member_count + 1, updated_at = NOW()
  WHERE id = v_family_id;

  UPDATE public.users SET family_id = v_family_id::TEXT WHERE id = p_user_id;

  RETURN v_family_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
