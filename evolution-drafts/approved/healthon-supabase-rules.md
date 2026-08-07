# Evolution Proposal: HealthON 프로젝트의 Supabase DB/Storage 규칙 3가지를 MEMORY.md에 기록

- Proposal-ID: evo-2026-08-08-healthon-supabase-rules
- Status: approved
- Signature: healthon-supabase-rules
- Created-At: 2026-08-08 00:21
- Last-Seen-At: 2026-08-08 00:21
- Target-File: MEMORY.md
- Trigger-Type: preference
- Confidence: medium

## Why This Matters
- HealthON 프로젝트의 Supabase DB/Storage 규칙 3가지를 MEMORY.md에 기록

## Evidence
- Interactive proposal card was present in the session UI.
- The original pending draft file was unavailable at approval time.
- AutoClaw reconstructed this draft from the proposal payload so the review result can still be recorded.

## Duplicate Check
- Checked: pending draft path + signature/proposal fallback
- Result: original draft file missing
- Decision: create surrogate draft from proposal payload

## Proposed Change
### MEMORY.md - HealthON Supabase 규칙

# MEMORY.md - HealthON 프로젝트 규칙

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
- Approve: 批准 evo-2026-08-08-healthon-supabase-rules
- Reject: 拒绝 evo-2026-08-08-healthon-supabase-rules