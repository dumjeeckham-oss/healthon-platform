# 🔌 건강ON API 설계

> Version 1.0
>
> Last Updated : 2026-07-01

---

# 1. 목적

본 문서는 Flutter App과 Supabase Backend 간 통신 규칙을 정의한다.

모든 기능은 본 문서를 기준으로 구현한다.

---

# 2. API 설계 원칙

- Flutter는 직접 SQL을 실행하지 않는다.
- Repository Pattern을 통해 데이터에 접근한다.
- 모든 요청은 인증된 사용자만 수행한다.
- Row Level Security(RLS)를 적용한다.
- 응답 형식은 통일한다.

---

# 3. 시스템 구조

```
Flutter App
      │
      ▼
Repository
      │
      ▼
Service
      │
      ▼
Supabase SDK
      │
      ▼
PostgreSQL
```

---

# 4. 인증(Authentication)

지원 로그인

- Google
- Kakao
- Apple

인증은 Supabase Auth를 사용한다.

최초 로그인 이후 Refresh Token을 이용하여 자동 로그인 상태를 유지한다.

---

# 5. 권한(Role)

## Guest

로그인 전

가능

- 공지 조회

---

## User

가능

- 챌린지 참여
- 기록 조회
- 커뮤니티 작성
- 댓글 작성

---

## Admin

가능

- 전체 회원 조회
- 통계
- CMS
- 공지
- 챌린지 관리

---

# 6. 응답 형식

성공

```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

실패

```json
{
  "success": false,
  "message": "Error",
  "code": "AUTH_001"
}
```

---

# 7. 로그인 API

## Google Login

Request

```
signInWithGoogle()
```

Response

```
User Session
```

---

## Kakao Login

```
signInWithKakao()
```

---

## Apple Login

```
signInWithApple()
```

---

## Logout

```
signOut()
```

---

# 8. 회원 API

조회

```
getMyProfile()
```

수정

```
updateProfile()
```

탈퇴

```
deleteAccount()
```

---

# 9. 챌린지 API

목록

```
getChallenges()
```

상세

```
getChallenge(id)
```

참여

```
joinChallenge()
```

종료

```
leaveChallenge()
```

---

# 10. 걸음 기록 API

오늘 기록

```
getTodayRecord()
```

누적 기록

```
getTotalRecord()
```

수동 입력

```
insertManualRecord()
```

자동 동기화

```
syncHealthData()
```

---

# 11. Health API

Android

Health Connect

↓

HealthService

↓

Repository

↓

Supabase

---

iPhone

HealthKit

↓

HealthService

↓

Repository

↓

Supabase

---

동기화는 하루 여러 번 가능하다.

동일 날짜 데이터는 중복 저장하지 않는다.

---

# 12. Ranking API

전체 순위

```
getRanking()
```

내 순위

```
getMyRanking()
```

---

# 13. Community API

목록

```
getPosts()
```

상세

```
getPost()
```

작성

```
createPost()
```

수정

```
updatePost()
```

삭제

```
deletePost()
```

댓글

```
createComment()
```

---

# 14. Notice API

목록

```
getNotices()
```

상세

```
getNotice()
```

---

# 15. Notification API

목록

```
getNotifications()
```

읽음 처리

```
readNotification()
```

---

# 16. Badge API

획득 목록

```
getBadges()
```

내 배지

```
getMyBadges()
```

---

# 17. 관리자 API

Dashboard

```
getDashboard()
```

회원 조회

```
getUsers()
```

챌린지 생성

```
createChallenge()
```

챌린지 수정

```
updateChallenge()
```

통계

```
getStatistics()
```

CSV 다운로드

```
exportCsv()
```

---

# 18. CMS API

메인 배너

```
getHomeBanner()
```

메인 문구

```
getHomeMessage()
```

수정

```
updateCMS()
```

---

# 19. Storage API

업로드

```
uploadImage()
```

삭제

```
deleteImage()
```

프로필

게시글

배너

공지 이미지

---

# 20. 에러 코드

|코드|설명|
|------|------|
|AUTH_001|로그인 실패|
|AUTH_002|권한 없음|
|USER_001|회원 없음|
|CHALLENGE_001|참여 실패|
|HEALTH_001|건강 데이터 권한 거부|
|HEALTH_002|동기화 실패|
|COMMUNITY_001|게시글 없음|
|NOTICE_001|공지 없음|
|SERVER_001|서버 오류|

---

# 21. 보안 정책

모든 API는 HTTPS를 사용한다.

JWT 기반 인증을 사용한다.

Row Level Security(RLS)를 적용한다.

관리자 API는 관리자 Role만 접근 가능하다.

---

# 22. 로그 정책

기록

- 로그인
- 로그아웃
- 건강 동기화
- 게시글 작성
- 관리자 작업

Audit Log를 남긴다.

---

# 23. 성능 목표

API 평균 응답

500ms 이하

홈 화면

2초 이내

통계

3초 이내

---

# 24. 향후 추가 예정 API

- AI 건강 리포트
- 스마트워치 연동
- Wear OS
- Apple Watch
- 미션 API
- 그룹 챌린지
- 병원 연계 API

---

# 25. CTO Notes

Flutter는 Database를 직접 호출하지 않는다.

항상

UI

↓

Repository

↓

Service

↓

Supabase

순서를 따른다.

API 이름은 기능 중심으로 작성한다.

예)

좋음

getChallenge()

나쁨

selectChallengeTable()

비즈니스 로직은 Service에서 처리한다.

Repository는 데이터 접근만 담당한다.

향후 자체 서버로 이전하더라도

Flutter 코드는 변경하지 않는 것을 목표로 한다.

---

# 다음 문서

DATABASE_SCHEMA.sql
