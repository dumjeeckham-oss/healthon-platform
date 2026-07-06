-- =====================================================
-- HealthON Platform
-- File : 001_extensions.sql
-- Description : PostgreSQL Extensions & Base Functions
-- Version : 1.0
-- =====================================================

-- UUID 생성 확장
create extension if not exists "pgcrypto";

-- 대소문자 구분 없는 이메일 검색
create extension if not exists "citext";

-- UUID 생성 테스트
select gen_random_uuid();

-- =====================================================
-- updated_at 자동 갱신 함수
-- =====================================================

create or replace function public.update_updated_at_column()
returns trigger
language plpgsql
as $$
begin
    new.updated_at = timezone('Asia/Seoul', now());
    return new;
end;
$$;

comment on function public.update_updated_at_column()
is 'updated_at 컬럼 자동 갱신';

-- =====================================================
-- Soft Delete Helper (향후 사용)
-- =====================================================

create or replace function public.soft_delete()
returns trigger
language plpgsql
as $$
begin
    new.deleted_at = timezone('Asia/Seoul', now());
    return new;
end;
$$;

comment on function public.soft_delete()
is 'Soft Delete Helper';

-- =====================================================
-- Database 기본 확인
-- =====================================================

select current_database();

select version();
