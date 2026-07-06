-- =====================================================
-- HealthON Platform
-- File : 002_types.sql
-- Description : PostgreSQL ENUM Types
-- Version : 1.0
-- =====================================================

-- =====================================================
-- 사용자 권한
-- =====================================================

create type user_role as enum (
    'user',
    'operator',
    'admin',
    'super_admin'
);

comment on type user_role is '사용자 권한';

-- =====================================================
-- 조합원 구분
-- =====================================================

create type member_type as enum (
    'member',
    'citizen'
);

comment on type member_type is '조합원 / 비조합원';

-- =====================================================
-- 성별
-- =====================================================

create type gender_type as enum (
    'male',
    'female',
    'unknown'
);

comment on type gender_type is '성별';

-- =====================================================
-- 챌린지 상태
-- =====================================================

create type challenge_status as enum (
    'draft',
    'recruiting',
    'active',
    'completed',
    'archived'
);

comment on type challenge_status is '챌린지 상태';

-- =====================================================
-- 챌린지 종류
-- =====================================================

create type challenge_type as enum (
    'walking',
    'nosmoking',
    'investment',
    'volunteer',
    'plogging',
    'health_check',
    'custom'
);

comment on type challenge_type is '챌린지 유형';

-- =====================================================
-- 활동 기록 종류
-- =====================================================

create type activity_type as enum (
    'walking',
    'manual',
    'nosmoking',
    'investment',
    'volunteer',
    'plogging'
);

comment on type activity_type is '활동 기록 종류';

-- =====================================================
-- 건강 데이터 출처
-- =====================================================

create type activity_source as enum (
    'healthkit',
    'health_connect',
    'manual',
    'admin'
);

comment on type activity_source is '데이터 출처';

-- =====================================================
-- 건강 데이터 동기화 상태
-- =====================================================

create type sync_status as enum (
    'success',
    'failed'
);

comment on type sync_status is '건강 데이터 동기화 결과';

-- =====================================================
-- 공지 상태
-- =====================================================

create type notice_status as enum (
    'draft',
    'published',
    'hidden'
);

comment on type notice_status is '공지 상태';

-- =====================================================
-- 게시글 상태
-- =====================================================

create type post_status as enum (
    'normal',
    'hidden',
    'deleted'
);

comment on type post_status is '게시글 상태';

-- =====================================================
-- 알림 종류
-- =====================================================

create type notification_type as enum (
    'system',
    'challenge',
    'community',
    'badge',
    'notice'
);

comment on type notification_type is '알림 종류';

-- =====================================================
-- 디바이스 플랫폼
-- =====================================================

create type device_platform as enum (
    'android',
    'ios',
    'web'
);

comment on type device_platform is '디바이스 플랫폼';

-- =====================================================
-- 앱 버전 상태
-- =====================================================

create type app_version_status as enum (
    'optional',
    'required'
);

comment on type app_version_status is '업데이트 정책';

-- =====================================================
-- 파일 종류
-- =====================================================

create type file_type as enum (
    'profile',
    'banner',
    'notice',
    'community',
    'badge'
);

comment on type file_type is '파일 업로드 종류';
