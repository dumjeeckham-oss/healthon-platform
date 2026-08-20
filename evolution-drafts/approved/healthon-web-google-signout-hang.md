# Evolution Proposal: HealthON 프로젝트에서 Web 환경 Google 로그아웃 hang 문제의 해결 규칙을 장기 기억에 남겨 향후 인증 작업 시 같은 문제를 반복하지 않기 위함.

- Proposal-ID: evo-2026-08-18-healthon-web-google-signout-hang
- Status: approved
- Signature: healthon-web-google-signout-hang
- Created-At: 2026-08-18 09:17
- Last-Seen-At: 2026-08-18 09:17
- Target-File: MEMORY.md
- Trigger-Type: preference
- Confidence: medium
- Payload-Hash: 90bb45d94095ce29072004fce4540ea6ce60825cf1e43ff1fd3820c65ea579dd
- Content-Hash: 7ae76ab79b265265b0be815baed434ac0130cb81fc7f7a891219ffe92b9a3aa5

## Why This Matters
- HealthON 프로젝트에서 Web 환경 Google 로그아웃 hang 문제의 해결 규칙을 장기 기억에 남겨 향후 인증 작업 시 같은 문제를 반복하지 않기 위함.

## Evidence
- Interactive proposal card was present in the session UI.
- Main recorded this pending draft before any approval action.
- Approval and rejection use the Main-owned proposal record, not a later renderer payload.

## Duplicate Check
- Checked: Main-owned proposal signature and immutable payload hash
- Result: pending authority record created
- Decision: only the recorded payload may transition this proposal

## Proposed Change
### MEMORY.md

# MEMORY.md - 장기 기억

## HealthON 프로젝트

### 인증 (Supabase) — 알려진 이슈와 확정 사항

- Web 환경에서는 `GoogleSignIn.signOut()` 호출 시 hang(멈춤) 문제가 발생한다.
- 해결 규칙: Web에서는 `GoogleSignIn.signOut()`을 SKIP하고 `Supabase.auth.signOut()`만 실행한다.
- 2026-08-18 기준 검증 완료: 이메일 로그인/로그아웃/재로그인/세션 복구 정상, Google 로그인 구조 존재, MyPageScreen 로그아웃 버튼 정상.

## Apply Plan
1. Keep this Main-owned draft as the approval artifact.
2. Apply exactly the payload bound to this draft after user approval.
3. Append an audit note after approval or rejection.

## User Approval
- Approve: 批准 evo-2026-08-18-healthon-web-google-signout-hang
- Reject: 拒绝 evo-2026-08-18-healthon-web-google-signout-hang

## Applied
- Resolved-At: 2026-08-18T00:39:02.175Z
- Payload-Hash: 90bb45d94095ce29072004fce4540ea6ce60825cf1e43ff1fd3820c65ea579dd
- Content-Hash: 7ae76ab79b265265b0be815baed434ac0130cb81fc7f7a891219ffe92b9a3aa5
- Transaction-ID: hermes_approval_msxxq1wf_ca2um8
