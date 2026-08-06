# Evolution Proposal: HealthON 프로젝트의 핵심 원칙: 기존 UI/Provider/구조 보존 규칙을 MEMORY.md에 기록

- Proposal-ID: evo-2026-08-06-healthon-preserve-existing
- Status: approved
- Signature: healthon-preserve-existing
- Created-At: 2026-08-06 10:44
- Last-Seen-At: 2026-08-06 10:44
- Target-File: MEMORY.md
- Trigger-Type: preference
- Confidence: medium

## Why This Matters
- HealthON 프로젝트의 핵심 원칙: 기존 UI/Provider/구조 보존 규칙을 MEMORY.md에 기록

## Evidence
- Interactive proposal card was present in the session UI.
- The original pending draft file was unavailable at approval time.
- AutoClaw reconstructed this draft from the proposal payload so the review result can still be recorded.

## Duplicate Check
- Checked: pending draft path + signature/proposal fallback
- Result: original draft file missing
- Decision: create surrogate draft from proposal payload

## Proposed Change
### MEMORY.md

# MEMORY.md — 건강ON Project Memory

## 프로젝트 개요

- **이름:** HealthON (건강ON)
- **소속:** 부천의료복지사회적협동조합
- **기술 스택:** Flutter + Riverpod + Supabase
- **주요 기능:** 부천100K 걷기 챌린지, Health Connect / Apple Health 자동 동기화
- **확장 계획:** 금연, 출자금 증좌, 건강검진, 봉사활동 등 참여형 챌린지

## 핵심 작업 원칙 (반드시 준수)

1. **기존 UI를 절대로 깨지 않는다.** 모든 화면은 이미 존재하며 운영 중이다.
2. **기존 Provider 이름을 절대로 변경하지 않는다.** Riverpod provider 이름은 불변으로 취급한다.
3. **기존 구조를 보존한다.** 새 기능은 기존 코드 옆에 추가하고, 기존 파일/클래스/함수 시그니처를 변경하지 않는다.
4. **Mock은 제거되었고, 모든 데이터는 Supabase 기반이다.** 모의 데이터를 재도입하지 않는다.

## 구현 완료된 기능

- Forest (산림 테마)
- Challenge (챌린지)
- Ranking (랭킹)
- Community (커뮤니티, Supabase 기반)
- Comment (댓글)
- Health Connect / Apple Health → Supabase 자동 동기화 파이프라인 (health_sync_service)
- Social Graph + Auto Feed (Phase3 진행 중)

## Apply Plan
1. Keep this reconstructed draft as the approval artifact.
2. Record the proposal content exactly as shown in the interactive card.
3. Append an audit note after approval or rejection.

## User Approval
- Approve: 批准 evo-2026-08-06-healthon-preserve-existing
- Reject: 拒绝 evo-2026-08-06-healthon-preserve-existing