-- =====================================
-- HEALTHON DATABASE (PRODUCTION v1)
-- =====================================

-- USERS (Supabase Auth 기반 확장)
create table if not exists users (
  id uuid primary key,
  name text,
  email text,
  provider text,
  created_at timestamp default now()
);

-- STEP DAILY (핵심 데이터)
create table if not exists step_daily (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references users(id) on delete cascade,
  date date not null,
  steps int default 0,
  distance_km float default 0,
  updated_at timestamp default now(),
  unique(user_id, date)
);

-- CHALLENGES
create table if not exists challenges (
  id uuid default gen_random_uuid() primary key,
  title text,
  description text,
  start_date date,
  end_date date,
  target_km float,
  created_at timestamp default now()
);

-- USER CHALLENGES
create table if not exists user_challenges (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references users(id),
  challenge_id uuid references challenges(id),
  joined_at timestamp default now(),
  progress_km float default 0,
  status text default 'active'
);

-- CHALLENGE PROGRESS (캐시 테이블)
create table if not exists challenge_progress (
  id uuid default gen_random_uuid() primary key,
  user_id uuid,
  challenge_id uuid,
  current_km float default 0,
  percent float default 0,
  updated_at timestamp default now(),
  unique(user_id, challenge_id)
);

-- STREAKS
create table if not exists streaks (
  id uuid default gen_random_uuid() primary key,
  user_id uuid unique,
  current_streak int default 0,
  max_streak int default 0,
  last_active_date date
);

-- FOREST
create table if not exists forest (
  id uuid default gen_random_uuid() primary key,
  user_id uuid unique,
  total_km float default 0,
  tree_count int default 0,
  updated_at timestamp default now()
);

-- BADGES
create table if not exists badges (
  id uuid default gen_random_uuid() primary key,
  name text,
  condition_type text,
  condition_value int,
  icon text
);

-- USER BADGES
create table if not exists user_badges (
  id uuid default gen_random_uuid() primary key,
  user_id uuid,
  badge_id uuid,
  earned_at timestamp default now()
);

-- RANKINGS
create table if not exists rankings (
  id uuid default gen_random_uuid() primary key,
  user_id uuid,
  challenge_id uuid,
  score float default 0,
  rank int default 0,
  updated_at timestamp default now()
);
