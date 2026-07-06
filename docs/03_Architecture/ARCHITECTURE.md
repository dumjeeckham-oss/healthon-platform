# 🏗️ 건강ON 플랫폼 아키텍처

> Version 1.0
>
> Last Updated : 2026-07-01

---

# 1. 아키텍처 목표

건강ON은 단순한 모바일 앱이 아닌 **건강 챌린지 플랫폼**이다.

첫 번째 서비스는 **부천100K 걷기 챌린지**이며,
향후 금연, 건강검진, 출자금 증좌, 플로깅 등 다양한 챌린지를 추가할 수 있도록 설계한다.

본 문서는 시스템 전체 구조와 기술 원칙을 정의한다.

---

# 2. 핵심 설계 원칙

## 2.1 Mobile First

모든 기능은 모바일 사용성을 최우선으로 설계한다.

---

## 2.2 AI Native

모든 문서와 코드는 AI(Cursor, Codex, ChatGPT)가 이해하고 유지보수할 수 있도록 작성한다.

---

## 2.3 Documentation First

기능 구현 전에 반드시 설계 문서를 작성한다.

---

## 2.4 Data First

가장 중요한 자산은 데이터이다.

- 사용자 데이터
- 걷기 기록
- 챌린지 기록
- 통계

데이터는 언제든 백업 및 복구가 가능해야 한다.

---

## 2.5 Expandable

걷기 챌린지 외에도 새로운 챌린지를 추가할 수 있도록 설계한다.

예)

- 걷기
- 금연
- 출자금 증좌
- 건강검진
- 봉사활동
- 플로깅

---

# 3. 시스템 구성도

```

Flutter Mobile App

(Android / iOS)

↓

Authentication

↓

Business Layer

↓

Repository Layer

↓

Supabase

↓

PostgreSQL

↓

Storage

↓

Realtime

↓

Flutter Web Admin

```

---

# 4. 기술 스택

## Mobile

Flutter

---

## Language

Dart

---

## State Management

Riverpod

---

## Backend

Supabase

---

## Database

PostgreSQL

---

## Authentication

Supabase Auth

지원

- Kakao
- Google
- Apple

---

## Storage

Supabase Storage

---

## Push

Firebase Cloud Messaging

---

## Health

Android

Health Connect

iPhone

Apple HealthKit

---

## Source

GitHub

---

## Design

Figma

---

# 5. Flutter 프로젝트 구조

```

apps/mobile/lib/

core/

features/

shared/

services/

repositories/

models/

widgets/

```

---

## Core

공통 기능

- Theme
- Routing
- Constants
- Utils

---

## Features

기능별 개발

예)

auth

challenge

community

statistics

notification

admin

---

## Shared

공통 Widget

---

## Services

외부 서비스

- Health
- Push
- Storage

---

## Repository

모든 DB 접근

UI는 직접 DB를 호출하지 않는다.

---

# 6. Clean Architecture

```

Presentation

↓

Application

↓

Domain

↓

Repository

↓

Data Source

↓

Supabase

```

모든 기능은 이 구조를 따른다.

---

# 7. Repository Pattern

UI는 Repository만 호출한다.

예)

ChallengeRepository

↓

SupabaseChallengeRepository

↓

Supabase

이 구조를 사용하면

향후 Supabase를 Firebase나 자체 서버로 변경해도
UI 수정 없이 교체가 가능하다.

---

# 8. 인증 구조

지원

- 카카오 로그인
- Google 로그인
- Apple 로그인

사용자는 최초 로그인 이후 자동 로그인 상태를 유지한다.

Refresh Token을 이용하여 장기간 로그인 상태를 유지한다.

---

# 9. Health 구조

Android

Health Connect

↓

Health Service

↓

Repository

↓

Challenge Service

↓

Database

---

iPhone

Apple HealthKit

↓

Health Service

↓

Repository

↓

Database

---

수동 입력도 동일한 Repository를 사용한다.

---

# 10. 챌린지 구조

Challenge는 플랫폼의 핵심이다.

Challenge Type

- Walking
- NoSmoking
- Investment
- Volunteer
- Custom

모든 Challenge는 동일한 구조를 사용한다.

---

# 11. 관리자 구조

Flutter Web

↓

Dashboard

↓

CMS

↓

Statistics

↓

Participants

↓

Challenge Management

↓

Notice

↓

Community

---

# 12. CMS

운영자는 개발자 도움 없이

- 홈 배너
- 공지
- 이벤트
- 메인 문구
- 이미지

를 수정할 수 있어야 한다.

---

# 13. 백업 전략

## GitHub

- 문서
- 코드
- SQL

---

## Supabase

- Database Backup

---

## Storage

- Image Backup

---

## CSV Export

관리자는 언제든

- 참가자
- 통계
- 챌린지

를 CSV로 다운로드할 수 있다.

---

# 14. 보안

모든 API는 인증을 요구한다.

Row Level Security(RLS)를 적용한다.

사용자는 자신의 데이터만 조회할 수 있다.

관리자는 관리자 권한을 가진 사용자만 접근한다.

개인정보는 최소한으로 저장한다.

---

# 15. 로그

기록

- 로그인
- 챌린지 참여
- 기록 수정
- 관리자 작업

모든 관리자 작업은 Audit Log를 남긴다.

---

# 16. 확장 전략

향후 추가 가능한 기능

- Wear OS
- Apple Watch
- AI 건강리포트
- 스마트워치 자동연동
- 건강점수
- 미션형 챌린지

기존 구조 변경 없이 Feature만 추가한다.

---

# 17. GitHub 운영 원칙

main

항상 배포 가능한 상태

develop

개발 브랜치

feature/*

기능 개발

모든 설계 문서는 docs에서 관리한다.

---

# 18. AI 개발 원칙

ChatGPT

- 기획
- 설계
- 리뷰

Cursor

- 구현
- 수정

Codex

- 코드 생성
- 문서 생성

GitHub를 프로젝트의 단일 진실(Single Source of Truth)로 사용한다.

---

# 19. CTO Notes

건강ON은 이벤트 앱이 아니다.

건강ON은 부천의료복지사회적협동조합의 디지털 플랫폼이다.

따라서

- 유지보수
- 확장성
- 데이터 안정성
- 관리자 편의성

을 최우선 가치로 둔다.

새로운 챌린지는 기존 코드를 수정하는 것이 아니라
Feature를 추가하는 방식으로 개발한다.

Supabase는 MVP를 위한 선택이며,
향후 Docker 기반 자체 서버로 이전 가능한 구조를 유지한다.

---

# 다음 문서

ERD.md
