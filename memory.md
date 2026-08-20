# MEMORY.md - 장기 기억

## HealthON 프로젝트

### 인증 (Supabase) — 알려진 이슈와 확정 사항

- Web 환경에서는 `GoogleSignIn.signOut()` 호출 시 hang(멈춤) 문제가 발생한다.
- 해결 규칙: Web에서는 `GoogleSignIn.signOut()`을 SKIP하고 `Supabase.auth.signOut()`만 실행한다.
- 2026-08-18 기준 검증 완료: 이메일 로그인/로그아웃/재로그인/세션 복구 정상, Google 로그인 구조 존재, MyPageScreen 로그아웃 버튼 정상.