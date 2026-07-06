-- =====================================================
-- HealthON Platform
-- File : 100_users.sql
-- Description : User & Organization Tables
-- Version : 1.0
-- =====================================================

---------------------------------------------------------
-- organizations
---------------------------------------------------------

create table if not exists public.organizations (

    id uuid primary key default gen_random_uuid(),

    name text not null,

    description text,

    logo_url text,

    homepage_url text,

    phone text,

    email citext,

    address text,

    is_active boolean not null default true,

    created_at timestamptz not null default timezone('Asia/Seoul', now()),

    updated_at timestamptz not null default timezone('Asia/Seoul', now()),

    deleted_at timestamptz

);

comment on table public.organizations
is '기관 정보';

---------------------------------------------------------
-- profiles
---------------------------------------------------------

create table if not exists public.profiles (

    id uuid primary key references auth.users(id) on delete cascade,

    organization_id uuid references public.organizations(id),

    role user_role not null default 'user',

    member_type member_type not null default 'citizen',

    name text not null,

    nickname text,

    birth_year smallint not null,

    gender gender_type default 'unknown',

    phone text,

    email citext,

    profile_image_url text,

    marketing_agree boolean default false,

    privacy_agree boolean default true,

    terms_agree boolean default true,

    last_login_at timestamptz,

    last_sync_at timestamptz,

    is_active boolean not null default true,

    created_at timestamptz not null default timezone('Asia/Seoul', now()),

    updated_at timestamptz not null default timezone('Asia/Seoul', now()),

    deleted_at timestamptz

);

comment on table public.profiles
is '회원 프로필';

---------------------------------------------------------
-- join_requests
---------------------------------------------------------

create table if not exists public.join_requests (

    id uuid primary key default gen_random_uuid(),

    profile_id uuid
        references public.profiles(id),

    organization_id uuid
        references public.organizations(id),

    memo text,

    status text default 'pending',

    created_at timestamptz default timezone('Asia/Seoul', now()),

    updated_at timestamptz default timezone('Asia/Seoul', now())

);

comment on table public.join_requests
is '조합 가입 신청';

---------------------------------------------------------
-- user_badges
---------------------------------------------------------

create table if not exists public.user_badges (

    id uuid primary key default gen_random_uuid(),

    profile_id uuid
        references public.profiles(id)
        on delete cascade,

    badge_id uuid,

    earned_at timestamptz default timezone('Asia/Seoul', now()),

    created_at timestamptz default timezone('Asia/Seoul', now())

);

comment on table public.user_badges
is '회원 배지';
