# 건강ON(HealthON) 개발 운영 규칙

> 최종 갱신: 2026-08-12
> 이 문서는 건강ON 프로젝트의 모든 개발 작업에 적용되는 최상위 규칙이다.

---

## 1. 최우선 개발 원칙

반드시 다음 우선순위를 지켜라.

1. 기존 동작하는 기능을 보존한다.
2. 실제 사용 중인 코드와 dead code를 구분한다.
3. 한 번에 하나의 문제만 해결한다.
4. 수정 범위를 최소화한다.
5. 수정 전에 반드시 현재 코드를 읽고 실제 호출 흐름을 추적한다.
6. 추측으로 코드를 수정하지 않는다.
7. 기존 구조를 임의로 리팩터링하지 않는다.
8. 작업 완료 후 반드시 analyze/test 결과를 확인한다.
9. 오류가 발생하면 새로운 코드를 추가하기 전에 원인을 먼저 확정한다.
10. 사용자가 명시적으로 요청하지 않은 기능은 추가하지 않는다.

---

## 2. 작업 시작 전 반드시 해야 하는 것

어떤 작업을 받더라도 바로 코드를 수정하지 마라.

먼저 다음을 수행한다.

1. 사용자가 요청한 기능과 문제를 한 문장으로 정의한다.
2. 관련 파일을 실제로 검색한다.
3. 호출 흐름을 추적한다: Screen → Provider → Repository → Service → Supabase/API → DB
4. 실제로 사용되는 파일과 dead code를 구분한다.
5. 수정 대상 파일을 최소 범위로 결정한다.
6. 수정 전에 [작업 사전 보고]를 작성하고 사용자 승인 전에는 대규모 수정하지 않는다.

---

## 3. 절대 금지 사항

- ❌ 여러 기능을 한 번에 수정
- ❌ 관련 없어 보이는 파일까지 리팩터링
- ❌ 폴더 구조 변경
- ❌ 파일 이름 변경
- ❌ 기존 Router 교체
- ❌ Provider 구조 교체
- ❌ Repository 구조 교체
- ❌ 패키지 버전 대규모 업데이트
- ❌ pubspec.yaml 대규모 변경
- ❌ dead code 삭제
- ❌ 기존 API 변경
- ❌ DB schema 변경
- ❌ Supabase RLS 정책 변경
- ❌ 인증 방식을 임의로 변경
- ❌ Web/Android/iOS 동작을 하나로 통합
- ❌ 테스트가 실패한 상태에서 다음 기능으로 이동

특히 패키지 업데이트는 사용자가 명시적으로 요청하지 않는 한 하지 않는다.

---

## 4. 현재 프로젝트의 실제 구조

### 실제 사용 파일 (auth)

| 파일 | 역할 |
|------|------|
| `lib/core/bootstrap/bootstrap.dart` | Supabase 초기화 |
| `lib/app/router.dart` | GoRouter |
| `lib/features/auth/domain/auth_repository.dart` | Auth interface |
| `lib/features/auth/data/supabase_auth_repository.dart` | Auth 구현 |
| `lib/features/auth/presentation/providers/auth_provider.dart` | AuthNotifier + onAuthStateChange |
| `lib/features/auth/presentation/screens/login_screen.dart` | 로그인 화면 |
| `lib/features/auth/presentation/screens/signup_screen.dart` | 회원가입 화면 |
| `lib/features/splash/presentation/splash_screen.dart` | 스플래시 |

### Dead code (수정/삭제 금지)

- `lib/features/auth/data/auth_repository.dart`
- `lib/features/auth/application/auth_controller.dart`
- `lib/core/router/app_router.dart`
- `lib/infra/supabase/supabase_client.dart`

---

## 5. 인증 시스템 규칙

- `Bootstrap.supabaseInitialized == true` → Supabase.instance.client 접근 가능
- `Bootstrap.supabaseInitialized == false` → Supabase client 접근 금지, 진단 로그 출력
- 인증 상태는 Supabase auth state 기준으로 관리
- `onAuthStateChange` 임의 제거 금지. INITIAL_SESSION, SIGNED_IN, SIGNED_OUT 보존
- 이메일 인증 callback 및 Google OAuth redirect 후 세션 감지 필수

---

## 6. Web / Native 분리 원칙

- Google 로그인: Web → Supabase OAuth redirect, Native → GoogleSignIn + ID Token
- Health API: Web에서 Android/iOS Health API 호출 금지 (`kIsWeb` 가드)
- `Platform._operatingSystem`, `Unsupported operation` 등 오류 발생 금지

---

## 7. Supabase 규칙

- Auth User (Supabase Authentication) 와 public.users (앱 프로필) 구분
- 회원가입: Auth User 생성과 public.users 저장은 별개 단계
- `user.toJson()` 전체 저장 금지, DB schema 기반 최소 payload 사용
- RLS 정책 임의 변경 금지

---

## 8. 회원가입 규칙

- 이메일 인증 활성화 시: `signUp()` → user 생성 → session == null → 이메일 인증 필요 → UI 안내
- 이 상황을 오류로 취급하지 않는다
- `EmailConfirmationRequiredException` 사용 시 기존 흐름 유지
- 이메일 인증 링크 클릭 후: session 복구 → auth state listener 감지 → 로그인 상태 갱신

---

## 9. Router 규칙

- 실제 사용 Router: `lib/app/router.dart`
- dead Router: `lib/core/router/app_router.dart`
- Router가 여러 개 발견돼도 임의로 합치거나 교체하지 않는다
- Router redirect와 화면 내부 navigation을 임의로 동시에 추가하지 않는다

---

## 10. 로그 규칙

진단 로그 접두사:

```
[DIAG][BOOTSTRAP]  [DIAG][SUPABASE]  [DIAG][MAIN]
[DIAG][ROOT]       [DIAG][SPLASH]    [DIAG][AUTH]
[DIAG][AUTH][SIGNUP]  [DIAG][AUTH][EMAIL]
[DIAG][AUTH][GOOGLE]  [DIAG][AUTH][STATE]
```

새 로그도 기존 형식 유지. 중복 로그 발생 시 원인 확인 후 기능 수정. 로그 임의 삭제 금지.

---

## 11. 한 작업 = 한 목적

Health Sync Web 오류 해결 요청 → 인증 시스템 수정하지 않음. Google Web 로그인 해결 요청 → Health Sync 리팩터링하지 않음. 하나의 작업에서 변경 목적을 하나로 유지.

---

## 12. 작업 단위 규칙

가능하면 다음 단위로 작업한다:

1. Supabase 초기화 → analyze → test → 실행 확인
2. 이메일 회원가입 → analyze → test → 실행 확인
3. 이메일 인증 callback → analyze → test → 실행 확인
4. Google Web OAuth → analyze → test → 실행 확인
5. Health Sync Web guard → analyze → test → 실행 확인
6. 로그아웃 → analyze → test → 실행 확인
7. 세션 유지 → analyze → test → 실행 확인

절대로 전체를 한 번에 수정하지 않는다.

---

## 13. 수정 후 검증 규칙

- `dart analyze`: Errors = 0, Warnings = 0 목표
- 기존 Info (dart:html deprecated, withOpacity 등)는 현재 작업과 관계 없으면 건드리지 않음

---

## 14. 실패했을 때 규칙

1. 실패 로그 수집 → 2. 최초 오류 확인 → 3. 오류 발생 파일 확인 → 4. 호출 흐름 확인 → 5. 원인 확정 → 6. 최소 수정 → 7. analyze → 8. test → 9. 재실행

에러를 숨기기 위해 try/catch 추가 금지. 로그 삭제 금지. UI에서만 숨기는 방식 금지.

---

## 15. Git 규칙

작업 단위 종료 시 `git status` 확인. 예상치 못한 변경 파일 발견 시 중단 후 원인 확인.
Commit 메시지: `fix(auth): ...`, `fix(web): ...` 형식. `refactor:`는 실제 리팩터링에서만 사용.

---

## 16. DB 변경 규칙

DB schema 변경 시 Flutter 코드를 먼저 수정하지 않는다. 현재 schema 확인 → 변경 필요성 설명 → migration 작성 → RLS 영향 확인 → 적용 → DB 검증 → Flutter 코드 수정 순서.

---

## 17. 요청하지 않은 개선 금지

작업 범위를 벗어난 개선 후보는 "[추가 개선 후보]"로 기록만 한다.

---

## 18. 작업 완료 보고 형식

```
# 작업 완료 보고
## 1. 작업 목적
## 2. 실제 원인
## 3. 수정 파일
## 4. 수정하지 않은 파일
## 5. 실제 변경 내용
## 6. 테스트
## 7. 실행 결과
## 8. 남은 문제
## 9. 다음 작업
## 10. Git 변경 파일
```

---

## 19. 건강ON 인증 안정화 우선순위

인증 안정화가 끝나기 전에는 챌린지/랭킹/가족/관리자 기능 대규모 수정 금지.

### Phase 1 — 인증 안정화
- [x] ① Supabase Bootstrap
- [x] ② 이메일 회원가입
- [x] ③ 이메일 인증 메일 발송
- [ ] ④ 이메일 인증 후 로그인 (검증 필요)
- [x] ⑤ 이메일 로그인
- [x] ⑥ Auth State Listener
- [ ] ⑦ 로그아웃
- [ ] ⑧ 새로고침 세션 유지
- [ ] ⑨ Google Web OAuth
- [ ] ⑩ Google Native

### Phase 2 — Web 환경 안정화
- [ ] ① Health Sync Web guard
- [ ] ② Web 전용 API 분리
- [ ] ③ 모바일 Health API와 Web API 분리
- [ ] ④ Web 새로고침/세션 테스트

---

## 20. 최종 원칙

> "코드를 많이 수정하는 것이 좋은 개발이 아니다."

```
현재 코드 읽기
↓ 실제 흐름 추적
↓ 원인 확정
↓ 수정 범위 결정
↓ 사전 보고
↓ 최소 수정
↓ analyze / test
↓ 실행 / 로그 확인
↓ Git diff 확인
↓ 작업 완료 보고
↓ 다음 작업 대기
```

기존 코드를 충분히 읽지 않고 새로운 파일이나 구조를 만들어 해결하려 하지 않는다. 이미 동작하는 구조를 최대한 보존한다.
