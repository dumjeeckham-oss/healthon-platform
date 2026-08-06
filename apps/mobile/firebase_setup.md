# ================================================================
# HealthON — Firebase Setup Guide
# ================================================================

## 1. Firebase Console

https://console.firebase.google.com

### 프로젝트 생성
- 프로젝트 이름: "HealthON" (또는 "건강ON")

### Android 앱 등록
1. 프로젝트 설정 → 앱 추가 → Android
2. Android 패키지 이름: `com.healthon.app`
3. SHA-1 인증서:
   ```bash
   # 디버그
   keytool -list -v -keystore %USERPROFILE%\.android\debug.keystore -alias androiddebugkey -storepass android -keypass android
   # 릴리즈
   keytool -list -v -keystore android\healthon-release.keystore -alias healthon
   ```
4. `google-services.json` 다운로드 → `android/app/google-services.json` 배치

### iOS 앱 등록
1. 프로젝트 설정 → 앱 추가 → iOS
2. Bundle ID: `com.healthon.app`
3. `GoogleService-Info.plist` 다운로드 → `ios/Runner/` 배치

## 2. Firebase 서비스 활성화

다음 서비스를 Firebase Console에서 활성화:

- [ ] Cloud Messaging (FCM)
- [ ] Authentication → Google 로그인
- [ ] Authentication → Apple 로그인 (Sign in with Apple)

## 3. Android project-level build.gradle.kts

```kotlin
plugins {
    id("com.google.gms.google-services") version "4.4.2" apply false
}
```

## 4. Edge Function Secrets

Supabase Dashboard → Edge Functions → send-push → Secrets:

| Key | Value |
|-----|-------|
| FCM_PROJECT_ID | Firebase 프로젝트 ID |
| FCM_CLIENT_EMAIL | Firebase 서비스 계정 이메일 |
| FCM_PRIVATE_KEY | Firebase 서비스 계정 Private Key |
| SUPABASE_URL | Supabase Project URL |
| SUPABASE_SERVICE_ROLE_KEY | Supabase Service Role Key |

## 5. Cron Job 설정

Supabase Dashboard → Database → Cron:

```sql
SELECT cron.schedule('send-push-cron', '* * * * *', $$
  SELECT net.http_post(
    url:='https://[PROJECT_REF].supabase.co/functions/v1/send-push',
    headers:='{"Authorization": "Bearer [SUPABASE_ANON_KEY]"}'::jsonb
  );
$$);
```
