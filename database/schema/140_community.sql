-- =====================================================
-- HealthON Platform
-- File : 140_community.sql
-- Description : Community Domain
-- Version : 1.0
-- =====================================================

---------------------------------------------------------
-- community_categories
---------------------------------------------------------

create table if not exists public.community_categories (

    id uuid primary key default gen_random_uuid(),

    code text not null unique,

    name text not null,

    description text,

    sort_order integer default 0,

    is_active boolean default true,

    created_at timestamptz not null default timezone('Asia/Seoul', now()),

    updated_at timestamptz not null default timezone('Asia/Seoul', now())

);

comment on table public.community_categories
is '커뮤니티 게시판 분류';

---------------------------------------------------------
-- community_posts
---------------------------------------------------------

create table if not exists public.community_posts (

    id uuid primary key default gen_random_uuid(),

    category_id uuid
        references public.community_categories(id),

    profile_id uuid
        not null
        references public.profiles(id)
        on delete cascade,

    title text not null,

    content text not null,

    thumbnail_url text,

    view_count integer default 0,

    like_count integer default 0,

    comment_count integer default 0,

    status post_status default 'normal',

    is_notice boolean default false,

    created_at timestamptz
        not null
        default timezone('Asia/Seoul', now()),

    updated_at timestamptz
        not null
        default timezone('Asia/Seoul', now()),

    deleted_at timestamptz

);

comment on table public.community_posts
is '커뮤니티 게시글';

---------------------------------------------------------
-- community_comments
---------------------------------------------------------

create table if not exists public.community_comments (

    id uuid primary key default gen_random_uuid(),

    post_id uuid
        not null
        references public.community_posts(id)
        on delete cascade,

    profile_id uuid
        not null
        references public.profiles(id)
        on delete cascade,

    parent_comment_id uuid
        references public.community_comments(id),

    content text not null,

    like_count integer default 0,

    status post_status default 'normal',

    created_at timestamptz
        not null
        default timezone('Asia/Seoul', now()),

    updated_at timestamptz
        not null
        default timezone('Asia/Seoul', now()),

    deleted_at timestamptz

);

comment on table public.community_comments
is '댓글';

---------------------------------------------------------
-- community_post_likes
---------------------------------------------------------

create table if not exists public.community_post_likes (

    id uuid primary key default gen_random_uuid(),

    post_id uuid
        not null
        references public.community_posts(id)
        on delete cascade,

    profile_id uuid
        not null
        references public.profiles(id)
        on delete cascade,

    created_at timestamptz
        default timezone('Asia/Seoul', now()),

    constraint uq_post_like
        unique(post_id, profile_id)

);

comment on table public.community_post_likes
is '게시글 좋아요';

---------------------------------------------------------
-- community_comment_likes
---------------------------------------------------------

create table if not exists public.community_comment_likes (

    id uuid primary key default gen_random_uuid(),

    comment_id uuid
        not null
        references public.community_comments(id)
        on delete cascade,

    profile_id uuid
        not null
        references public.profiles(id)
        on delete cascade,

    created_at timestamptz
        default timezone('Asia/Seoul', now()),

    constraint uq_comment_like
        unique(comment_id, profile_id)

);

comment on table public.community_comment_likes
is '댓글 좋아요';

---------------------------------------------------------
-- community_attachments
---------------------------------------------------------

create table if not exists public.community_attachments (

    id uuid primary key default gen_random_uuid(),

    post_id uuid
        not null
        references public.community_posts(id)
        on delete cascade,

    file_url text not null,

    file_name text,

    file_size bigint,

    file_type file_type,

    created_at timestamptz
        default timezone('Asia/Seoul', now())

);

comment on table public.community_attachments
is '게시글 첨부파일';

---------------------------------------------------------
-- community_reports
---------------------------------------------------------

create table if not exists public.community_reports (

    id uuid primary key default gen_random_uuid(),

    post_id uuid
        references public.community_posts(id)
        on delete cascade,

    comment_id uuid
        references public.community_comments(id)
        on delete cascade,

    reporter_id uuid
        not null
        references public.profiles(id)
        on delete cascade,

    reason text not null,

    processed boolean default false,

    processed_by uuid
        references public.profiles(id),

    processed_at timestamptz,

    created_at timestamptz
        default timezone('Asia/Seoul', now())

);

comment on table public.community_reports
is '게시글/댓글 신고';
