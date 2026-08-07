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

## 플랫폼 안정화 작업 (2026-08-08)
- `dart:io` import 6곳 제거 → web 빌드 crash 방지
- Conditional import platform helpers 생성 (`csv_export_*.dart`, `file_bytes_*.dart`)
- GitHub Actions R8/ProGuard 오류 수정 (play-core 의존성 추가)
- 로고 이미지 4종 앱 적용 (splash/login/signup/home)
- 웹 white screen 오류 수정 (bootstrap + splash + main)
- .env 파일 복원 및 메모장 연결
- dart analyze info 208건 → 0건 정리
