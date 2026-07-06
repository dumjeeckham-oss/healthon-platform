-- =====================================================
-- HealthON Platform
-- File : 120_challenges.sql
-- Description : Challenge Domain
-- Version : 1.0
-- =====================================================

---------------------------------------------------------
-- challenge_categories
---------------------------------------------------------

create table if not exists public.challenge_categories (

    id uuid primary key default gen_random_uuid(),

    code text not null unique,

    name text not null,

    description text,

    icon text,

    color text,

    sort_order integer default 0,

    is_active boolean default true,

    created_at timestamptz not null default timezone('Asia/Seoul', now()),

    updated_at timestamptz not null default timezone('Asia/Seoul', now())

);

comment on table public.challenge_categories
is '챌린지 분류';

---------------------------------------------------------
-- challenges
---------------------------------------------------------

create table if not exists public.challenges (

    id uuid primary key default gen_random_uuid(),

    category_id uuid
        references public.challenge_categories(id),

    organization_id uuid
        references public.organizations(id),

    title text not null,

    description text,

    banner_image text,

    challenge_type challenge_type not null,

    status challenge_status not null default 'draft',

    goal_value numeric(10,2) not null,

    unit text not null,

    start_date date not null,

    end_date date not null,

    max_participants integer,

    is_public boolean default true,

    created_by uuid
        references public.profiles(id),

    created_at timestamptz not null default timezone('Asia/Seoul', now()),

    updated_at timestamptz not null default timezone('Asia/Seoul', now()),

    deleted_at timestamptz

);

comment on table public.challenges
is '챌린지';

---------------------------------------------------------
-- challenge_participants
---------------------------------------------------------

create table if not exists public.challenge_participants (

    id uuid primary key default gen_random_uuid(),

    challenge_id uuid
        not null
        references public.challenges(id)
        on delete cascade,

    profile_id uuid
        not null
        references public.profiles(id)
        on delete cascade,

    joined_at timestamptz default timezone('Asia/Seoul', now()),

    current_value numeric(10,2) default 0,

    goal_percent numeric(5,2) default 0,

    ranking integer,

    completed boolean default false,

    completed_at timestamptz,

    last_activity_at timestamptz,

    created_at timestamptz default timezone('Asia/Seoul', now()),

    updated_at timestamptz default timezone('Asia/Seoul', now()),

    deleted_at timestamptz,

    constraint uq_challenge_participant
        unique (challenge_id, profile_id)

);

comment on table public.challenge_participants
is '챌린지 참가자';

---------------------------------------------------------
-- challenge_rewards
---------------------------------------------------------

create table if not exists public.challenge_rewards (

    id uuid primary key default gen_random_uuid(),

    challenge_id uuid
        references public.challenges(id)
        on delete cascade,

    title text not null,

    description text,

    badge_image text,

    reward_point integer default 0,

    created_at timestamptz default timezone('Asia/Seoul', now())

);

comment on table public.challenge_rewards
is '챌린지 보상';

---------------------------------------------------------
-- challenge_announcements
---------------------------------------------------------

create table if not exists public.challenge_announcements (

    id uuid primary key default gen_random_uuid(),

    challenge_id uuid
        references public.challenges(id)
        on delete cascade,

    title text not null,

    content text,

    image_url text,

    created_by uuid
        references public.profiles(id),

    created_at timestamptz default timezone('Asia/Seoul', now())

);

comment on table public.challenge_announcements
is '챌린지 공지';

---------------------------------------------------------
-- challenge_statistics
---------------------------------------------------------

create table if not exists public.challenge_statistics (

    id uuid primary key default gen_random_uuid(),

    challenge_id uuid
        references public.challenges(id)
        on delete cascade,

    statistic_date date not null,

    participant_count integer default 0,

    completed_count integer default 0,

    total_steps bigint default 0,

    total_distance numeric(12,2) default 0,

    average_distance numeric(10,2) default 0,

    created_at timestamptz default timezone('Asia/Seoul', now()),

    constraint uq_challenge_statistics
        unique (challenge_id, statistic_date)

);

comment on table public.challenge_statistics
is '챌린지 일별 통계';
