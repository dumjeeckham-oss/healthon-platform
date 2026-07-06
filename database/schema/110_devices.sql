-- =====================================================
-- HealthON Platform
-- File : 110_devices.sql
-- Description : User Devices & Health Sync
-- Version : 1.0
-- =====================================================

---------------------------------------------------------
-- user_devices
---------------------------------------------------------

create table if not exists public.user_devices (

    id uuid primary key default gen_random_uuid(),

    profile_id uuid
        not null
        references public.profiles(id)
        on delete cascade,

    platform device_platform not null,

    manufacturer text,

    device_model text,

    os_version text,

    app_version text,

    health_provider text,

    health_permission boolean default false,

    push_token text,

    device_identifier text,

    last_login_at timestamptz,

    last_sync_at timestamptz,

    is_active boolean default true,

    created_at timestamptz
        not null
        default timezone('Asia/Seoul', now()),

    updated_at timestamptz
        not null
        default timezone('Asia/Seoul', now()),

    deleted_at timestamptz

);

comment on table public.user_devices
is '사용자 디바이스';

---------------------------------------------------------
-- health_sync_logs
---------------------------------------------------------

create table if not exists public.health_sync_logs (

    id uuid primary key default gen_random_uuid(),

    profile_id uuid
        not null
        references public.profiles(id)
        on delete cascade,

    device_id uuid
        references public.user_devices(id),

    sync_date date not null,

    started_at timestamptz,

    finished_at timestamptz,

    status sync_status not null,

    activity_source activity_source,

    steps integer default 0,

    distance numeric(8,2) default 0,

    calories numeric(8,2) default 0,

    duration integer default 0,

    error_message text,

    raw_payload jsonb,

    created_at timestamptz
        default timezone('Asia/Seoul', now())

);

comment on table public.health_sync_logs
is '건강 데이터 동기화 로그';

---------------------------------------------------------
-- device_tokens
---------------------------------------------------------

create table if not exists public.device_tokens (

    id uuid primary key default gen_random_uuid(),

    profile_id uuid
        references public.profiles(id)
        on delete cascade,

    device_id uuid
        references public.user_devices(id)
        on delete cascade,

    token text not null,

    created_at timestamptz
        default timezone('Asia/Seoul', now())

);

comment on table public.device_tokens
is '푸시 토큰';

---------------------------------------------------------
-- health_permissions
---------------------------------------------------------

create table if not exists public.health_permissions (

    id uuid primary key default gen_random_uuid(),

    profile_id uuid
        references public.profiles(id)
        on delete cascade,

    device_id uuid
        references public.user_devices(id)
        on delete cascade,

    health_read boolean default false,

    health_write boolean default false,

    granted_at timestamptz,

    revoked_at timestamptz,

    created_at timestamptz
        default timezone('Asia/Seoul', now())

);

comment on table public.health_permissions
is '건강 권한';
