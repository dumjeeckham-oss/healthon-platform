# ================================================================
# HealthON — DEPLOY.md (스토어 배포 체크리스트)
# ================================================================

## 📱 앱 정보

| 항목 | 값 |
|------|-----|
| 앱 이름 | 건강ON (HealthON) |
| 패키지명 | com.healthon.app |
| 버전 | 1.0.0 (build 1) |
| 최소 SDK | Android 26 (Android 8.0), iOS 15.0 |
| 타겟 SDK | Android 35 |

---

## 1. Firebase 설정

### Android
1. [Firebase Console](https://console.firebase.google.com) → 프로젝트 생성
2. Android 앱 추가 → 패키지명: `com.healthon.app`
3. `google-services.json` 다운로드 → `android/app/google-services.json` 에 배치
4. Cloud Messaging API 활성화

### iOS
1. iOS 앱 추가 → Bundle ID: `com.healthon.app`
2. `GoogleService-Info.plist` 다운로드 → `ios/Runner/` 에 배치
3. APNs 인증서 업로드

---

## 2. 앱 서명

### Android
```bash
# 키 생성
keytool -genkey -v -keystore android/healthon-release.keystore \
  -alias healthon -keyalg RSA -keysize 2048 -validity 10000

# android/key.properties 생성 (템플릿에서 복사)
cp android/key.properties.template android/key.properties
# 비밀번호 입력
```

### iOS
- Xcode → Signing & Capabilities → Automatically manage signing
- Apple Developer Program 등록 필요

---

## 3. 앱 아이콘 생성

```bash
# flutter_launcher_icons 실행
flutter pub run flutter_launcher_icons

# 수동: 1024x1024 PNG를 assets/icons/app_icon.png 에 배치 후 실행
```

---

## 4. 스플래시 화면

```bash
# flutter_native_splash 실행
flutter pub run flutter_native_splash:create

# 수정: assets/images/splash_logo.png 교체 후 실행
```

---

## 5. 환경 변수

```bash
# .env.sample → .env 복사
cp .env.sample .env
# Supabase URL & Key 입력
```

---

## 6. Supabase 설정

### Realtime 활성화
Database → Replication → 다음 테이블 ON:
- community_posts, community_comments, community_post_likes, community_bookmarks
- admin_notices, challenge_definitions, mission_definitions, forest_seasons, admin_banners
- push_notification_queue

### Storage Buckets
- community-images, banner-images, mission-images, challenge-images, forest-images → Public

### Edge Function 배포
```bash
supabase functions deploy send-push
# Secrets 설정:
# FCM_PROJECT_ID, FCM_CLIENT_EMAIL, FCM_PRIVATE_KEY, SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY
```

---

## 7. 빌드

```bash
# Android APK
flutter build apk --release --flavor production

# Android App Bundle (Play Store)
flutter build appbundle --release

# iOS
flutter build ios --release
# → Xcode에서 Archive → Distribute App
```

---

## 8. Play Store 제출 체크리스트

- [ ] 앱 아이콘 512x512
- [ ] 스크린샷 (최소 2장: 휴대폰, 태블릿) 
- [ ] 피처 그래픽 (1024x500)
- [ ] 개인정보처리방침 URL
- [ ] 콘텐츠 등급 설문
- [ ] 타겟 연령층 설정
- [ ] Health Connect 권한 선언 (Android 14+)

---

## 9. App Store 제출 체크리스트

- [ ] 앱 아이콘 1024x1024 (투명배경 없음)
- [ ] 스크린샷 (6.5인치, 5.5인치 필수)
- [ ] 개인정보처리방침 URL
- [ ] HealthKit 사용 목적 설명
- [ ] 수출 규정 준수
- [ ] 앱 심사 정보

---

## 10. 빠른 시작

```bash
cd apps/mobile

# 1. 의존성 설치
flutter pub get

# 2. 코드 생성
dart run build_runner build --delete-conflicting-outputs

# 3. 개발 실행
flutter run

# 4. 프로덕션 빌드
flutter build appbundle --release
```
