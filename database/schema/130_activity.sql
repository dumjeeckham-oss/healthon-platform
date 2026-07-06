-- =====================================================
-- HealthON Platform
-- File : 130_activity.sql
-- Description : Activity Records & Daily Statistics
-- Version : 1.0
-- =====================================================

---------------------------------------------------------
-- activity_records
---------------------------------------------------------

create table if not exists public.activity_records (

    id uuid primary key default gen_random_uuid(),

    participant_id uuid
        not null
        references public.challenge_participants(id)
        on delete cascade,

    profile_id uuid
        not null
        references public.profiles(id)
        on delete cascade,

    challenge_id uuid
        not null
        references public.challenges(id)
        on delete cascade,

    activity_date date not null,

    activity_type activity_type not null,

    activity_source activity_source not null,

    sync_log_id uuid
        references public.health_sync_logs(id),

    steps integer default 0,

    distance numeric(10,2) default 0,

    calories numeric(10,2) default 0,

    duration_minutes integer default 0,

    floors integer default 0,

    average_speed numeric(6,2),

    payload jsonb,

    is_verified boolean default true,

    created_at timestamptz
        not null
        default timezone('Asia/Seoul', now()),

    updated_at timestamptz
        not null
        default timezone('Asia/Seoul', now()),

    deleted_at timestamptz

);

comment on table public.activity_records
is '활동 기록';

---------------------------------------------------------
-- daily_activity_summary
---------------------------------------------------------

create table if not exists public.daily_activity_summary (

    id uuid primary key default gen_random_uuid(),

    profile_id uuid
        references public.profiles(id)
        on delete cascade,

    challenge_id uuid
        references public.challenges(id)
        on delete cascade,

    activity_date date not null,

    total_steps integer default 0,

    total_distance numeric(10,2) default 0,

    total_calories numeric(10,2) default 0,

    total_duration integer default 0,

    sync_count integer default 0,

    created_at timestamptz
        default timezone('Asia/Seoul', now()),

    updated_at timestamptz
        default timezone('Asia/Seoul', now()),

    constraint uq_daily_summary
        unique(profile_id, challenge_id, activity_date)

);

comment on table public.daily_activity_summary
is '일별 활동 집계';

---------------------------------------------------------
-- weekly_activity_summary
---------------------------------------------------------

create table if not exists public.weekly_activity_summary (

    id uuid primary key default gen_random_uuid(),

    profile_id uuid
        references public.profiles(id),

    challenge_id uuid
        references public.challenges(id),

    year integer,

    week integer,

    total_steps bigint default 0,

    total_distance numeric(10,2) default 0,

    total_calories numeric(10,2) default 0,

    created_at timestamptz
        default timezone('Asia/Seoul', now()),

    constraint uq_weekly_summary
        unique(profile_id, challenge_id, year, week)

);

comment on table public.weekly_activity_summary
is '주간 활동 집계';

---------------------------------------------------------
-- monthly_activity_summary
---------------------------------------------------------

create table if not exists public.monthly_activity_summary (

    id uuid primary key default gen_random_uuid(),

    profile_id uuid
        references public.profiles(id),

    challenge_id uuid
        references public.challenges(id),

    year integer,

    month integer,

    total_steps bigint default 0,

    total_distance numeric(10,2) default 0,

    total_calories numeric(10,2) default 0,

    created_at timestamptz
        default timezone('Asia/Seoul', now()),

    constraint uq_monthly_summary
        unique(profile_id, challenge_id, year, month)

);

comment on table public.monthly_activity_summary
is '월간 활동 집계';
