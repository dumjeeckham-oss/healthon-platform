# Evolution Proposal: Flutter/Dart 코드 수정 시 반드시 실제 파일을 읽고 코드 흐름을 추적한 후 수정하는 워크플로우 규칙 추가

- Proposal-ID: evo-2026-08-12-flutter-read-before-modify
- Status: approved
- Signature: flutter-read-before-modify
- Created-At: 2026-08-12 09:35
- Last-Seen-At: 2026-08-12 09:35
- Target-File: MEMORY.md
- Trigger-Type: preference
- Confidence: medium

## Why This Matters
- Flutter/Dart 코드 수정 시 반드시 실제 파일을 읽고 코드 흐름을 추적한 후 수정하는 워크플로우 규칙 추가

## Evidence
- Interactive proposal card was present in the session UI.
- The original pending draft file was unavailable at approval time.
- AutoClaw reconstructed this draft from the proposal payload so the review result can still be recorded.

## Duplicate Check
- Checked: pending draft path + signature/proposal fallback
- Result: original draft file missing
- Decision: create surrogate draft from proposal payload

## Proposed Change
### MEMORY.md — Flutter/Dart 코드 수정 원칙

# MEMORY.md — HealthON Platform

## 내 역할
- HealthON Platform의 **Lead Flutter Architect**
- 부천의료복지사회적협동조합 건강 참여 플랫폼 (부천100K 걷기 챌린지 등)

## 프로젝트 현재 상태
- **Phase 4~10 구현 완료**
- 현재는 **프로덕션 안정화** 단계 (새 기능 개발 아님)
- `dart analyze`: Error 0, Warning 0, Info 0 → 9 info (dart:html deprecated 등 기존 lint)

## 적용된 아키텍처 규칙
- Bootstrap 규칙 적용 완료 (dotenv + Supabase.initialize() 만 수행)
- Riverpod 규칙 적용 완료 (WidgetRef/Ref 캐스팅 금지, Service Provider 저장 금지)
- public.users 구조 적용 완료
- Supabase Repository 구조 적용 완료

## Supabase DB/Storage 규칙

### 1. 회원 테이블
- 회원 정보는 **`public.users`** 테이블만 사용
- `public.profiles` 테이블은 생성하지 않음

### 2. Auth ↔ Users 관계
- `auth.users`와 `public.users`는 **1:1 구조**
- `auth.users.id` = `public.users.id` 로 매핑

### 3. Storage Bucket
- `banner-images` — 배너 이미지
- `challenge-images` — 챌린지 이미지
- `mission-images` — 미션 이미지
- `forest-images` — 숲 이미지
- `community-images` — 커뮤니티 이미지

### 4. Provider 패턴
- `StateNotifierProvider` 기본 사용
- `FutureProvider` 남발 금지

### 5. 데이터 흐름
- Widget → Provider → Repository → Supabase (단방향)
- Widget은 Supabase 직접 호출 금지
- Repository에서만 Supabase 접근

### 6. Service 규칙
- Service는 Provider를 몰라야 함 (콜백 패턴)
- Widget만 Provider를 앎

## Flutter/Dart 코드 수정 원칙
- **추측으로 수정하지 말 것**: 사용자가 Flutter/Dart 코드 수정에 익숙하지 않으므로, 추측이나 가정에 기반한 코드 수정은 절대 금지
- **반드시 실제 파일을 먼저 읽을 것**: 수정 전 해당 파일과 연관된 파일들을 `read` 도구로 직접 읽어 현재 상태를 확인
- **코드 흐름을 추적한 후 수정할 것**: import 체인, Provider 의존성, Repository 호출 구조 등 전체 흐름을 파악한 뒤에만 수정 진행
- **수정 후 검증**: `dart analyze`로 정적 분석 통과 확인, 가능하면 `flutter build` 또는 테스트 실행

## 플랫폼 안정화 작업 (2026-08-08)
- `dart:io` import 6곳 제거 → web 빌드 crash 방지
- Conditional import platform helpers 생성 (`csv_export_*.dart`, `file_bytes_*.dart`)
- GitHub Actions R8/ProGuard 오류 수정 (play-core 의존성 추가)
- 로고 이미지 4종 앱 적용 (splash/login/signup/home)
- 웹 white screen 오류 수정 (bootstrap + splash + main)
- .env 파일 복원 및 메모장 연결
- dart analyze info 208건 → 0건 정리

## Apply Plan
1. Keep this reconstructed draft as the approval artifact.
2. Record the proposal content exactly as shown in the interactive card.
3. Append an audit note after approval or rejection.

## User Approval
- Approve: 批准 evo-2026-08-12-flutter-read-before-modify
- Reject: 拒绝 evo-2026-08-12-flutter-read-before-modify