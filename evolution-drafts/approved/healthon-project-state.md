# Evolution Proposal: HealthON 프로젝트 상태(Role, Phase, 규칙, 코드 품질)와 Supabase DB/Storage 규칙을 MEMORY.md에 통합 기록

- Proposal-ID: evo-2026-08-08-healthon-project-state
- Status: applied
- Signature: healthon-project-state
- Created-At: 2026-08-08 00:42
- Last-Seen-At: 2026-08-08 00:42
- Target-File: MEMORY.md
- Trigger-Type: preference
- Confidence: medium

## Why This Matters
- HealthON 프로젝트 상태(Role, Phase, 규칙, 코드 품질)와 Supabase DB/Storage 규칙을 MEMORY.md에 통합 기록

## Evidence
- Interactive proposal card was present in the session UI.
- The original pending draft file was unavailable at approval time.
- AutoClaw reconstructed this draft from the proposal payload so the review result can still be recorded.

## Duplicate Check
- Checked: pending draft path + signature/proposal fallback
- Result: original draft file missing
- Decision: create surrogate draft from proposal payload

## Proposed Change
### MEMORY.md - HealthON 프로젝트 상태 및 규칙

# MEMORY.md — HealthON Platform

## 내 역할
- HealthON Platform의 **Lead Flutter Architect**
- 부천의료복지사회적협동조합 건강 참여 플랫폼 (부천100K 걷기 챌린지 등)

## 프로젝트 현재 상태
- **Phase 4~10 구현 완료**
- 현재는 **프로덕션 안정화** 단계 (새 기능 개발 아님)
- `dart analyze`: Error 0, Warning 0, Info 0

## 적용된 아키텍처 규칙
- Bootstrap 규칙 적용 완료
- Riverpod 규칙 적용 완료
- public.users 구조 적용 완료
- Supabase Repository 구조 적용 완료

## Supabase DB 규칙

### 1. 회원 테이블
- 회원 정보는 **`public.users`** 테이블만 사용한다.
- `public.profiles` 테이블은 생성하지 않는다.

### 2. Auth ↔ Users 관계
- Supabase Auth의 `auth.users`와 `public.users`는 **1:1 구조**를 유지한다.
- `auth.users.id` = `public.users.id` 로 매핑한다.

### 3. Storage Bucket
- `banner-images` — 배너 이미지 저장
- `challenge-images` — 챌린지 이미지 저장

## Apply Plan
1. Keep this reconstructed draft as the approval artifact.
2. Record the proposal content exactly as shown in the interactive card.
3. Append an audit note after approval or rejection.

## User Approval
- Approve: 批准 evo-2026-08-08-healthon-project-state
- Reject: 拒绝 evo-2026-08-08-healthon-project-state