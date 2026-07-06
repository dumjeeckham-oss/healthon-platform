# 🗄️ 건강ON 데이터베이스 설계 (ERD)

> Version 2.0
>
> Last Updated : 2026-07-01

---

# 1. 설계 목표

건강ON은 단순한 걷기 앱이 아니다.

건강ON은 다양한 건강 챌린지를 운영할 수 있는 플랫폼이다.

따라서 데이터베이스는

- 확장성
- 유지보수
- 통계
- AI 분석

을 고려하여 설계한다.

---

# 2. 설계 원칙

## 하나의 사용자

↓

여러 개의 챌린지 참여 가능

---

## 하나의 챌린지

↓

여러 명의 참가자 가능

---

## 하나의 참가자

↓

여러 개의 활동 기록 보유

---

## 모든 기록은 삭제하지 않는다.

삭제 대신

Status를 변경한다.

---

# 3. ERD 구조

```

Users

↓

Membership

↓

Challenge

↓

Challenge Participant

↓

Activity Record

↓

Statistics

```

---

# 4. users

회원 기본 정보

|컬럼|설명|
|------|------|
|id|UUID|
|name|이름|
|birth|생년(동명이인 구분)|
|phone|전화번호|
|email|이메일|
|profile_image|프로필|
|member_type|조합원/비조합원|
|join_date|가입일|
|last_login|마지막 로그인|
|status|활성/탈퇴|

---

# 5. organizations

조직 정보

현재는

부천의료복지사회적협동조합

향후 여러 기관 운영 가능

|컬럼|설명|
|------|------|
|id|UUID|
|name|기관명|
|logo|로고|
|homepage|홈페이지|

---

# 6. challenges

챌린지 정보

|컬럼|설명|
|------|------|
|id|UUID|
|title|챌린지명|
|type|walking / nosmoking / investment / volunteer / custom|
|description|설명|
|goal_value|목표|
|unit|km / step / day / point|
|start_date|시작|
|end_date|종료|
|banner|배너|
|status|진행/종료|

---

# 7. challenge_participants

참가 정보

|컬럼|설명|
|------|------|
|id|UUID|
|challenge_id|챌린지|
|user_id|회원|
|join_date|참가일|
|current_value|현재기록|
|rank|순위|
|completed|완주여부|

---

# 8. activity_records

활동 기록

건강ON의 핵심 테이블

|컬럼|설명|
|------|------|
|id|UUID|
|participant_id|참가자|
|record_date|날짜|
|activity_type|walking|
|steps|걸음수|
|distance|거리|
|calories|칼로리|
|duration|운동시간|
|source|HealthKit / Health Connect / Manual|
|verified|검증여부|

향후

activity_type

으로

금연

봉사

출자금

등을 추가한다.

---

# 9. badges

배지

|컬럼|설명|
|------|------|
|id|UUID|
|title|배지명|
|image|아이콘|
|condition|획득조건|

---

# 10. user_badges

회원 배지

|컬럼|설명|
|------|------|
|user_id|회원|
|badge_id|배지|
|earned_at|획득일|

---

# 11. notices

공지사항

|컬럼|설명|
|------|------|
|id|UUID|
|title|제목|
|content|내용|
|image|이미지|
|created_at|작성일|

---

# 12. community_posts

커뮤니티

|컬럼|설명|
|------|------|
|id|UUID|
|user_id|작성자|
|title|제목|
|content|내용|
|image|사진|
|like_count|좋아요|

---

# 13. comments

댓글

|컬럼|설명|
|------|------|
|id|UUID|
|post_id|게시글|
|user_id|작성자|
|content|내용|

---

# 14. notifications

푸시 알림

|컬럼|설명|
|------|------|
|id|UUID|
|user_id|회원|
|title|제목|
|message|내용|
|read|읽음|

---

# 15. cms_contents

CMS

운영자가 수정하는 화면

|컬럼|설명|
|------|------|
|key|HOME_BANNER|
|title|제목|
|content|내용|
|image|이미지|

---

# 16. statistics_daily

일별 통계

|컬럼|설명|
|------|------|
|date|날짜|
|participants|참가자|
|steps|걸음|
|distance|거리|
|completion|완주율|

---

# 17. audit_logs

관리자 로그

|컬럼|설명|
|------|------|
|id|UUID|
|admin_id|관리자|
|action|수정내용|
|created_at|시간|

---

# 18. 관계도

```
Users
│
├──── ChallengeParticipants
│           │
│           ├──── ActivityRecords
│           │
│           └──── Challenges
│
├──── CommunityPosts
│          │
│          └──── Comments
│
├──── Notifications
│
└──── UserBadges
            │
            └──── Badges
```

---

# 19. 인덱스

생성 권장

- phone
- email
- challenge_id
- user_id
- record_date
- activity_type

---

# 20. Row Level Security

사용자

본인 데이터만 조회

관리자

전체 조회 가능

운영자

관리 기능 접근

---

# 21. 데이터 삭제 정책

물리 삭제하지 않는다.

Status를 변경한다.

Audit Log를 남긴다.

---

# 22. 백업

매일

Database Backup

주간

CSV Export

월간

SQL Dump

GitHub Backup

---

# 23. 향후 추가 예정

wearable_devices

health_sync_logs

missions

mission_rewards

groups

events

AI_health_report

hospital_connections

---

# 24. CTO Notes

건강ON은

Walking App이 아니다.

Challenge Platform이다.

따라서

Walking 전용 테이블을 많이 만드는 것보다

Challenge 중심으로 설계하였다.

새로운 챌린지가 추가되어도

DB 수정 없이

Challenge Type만 추가하여

확장 가능하도록 설계하였다.

또한 모든 건강 데이터는

자동

수동

둘 다 지원하도록 설계하였다.

향후 AI 건강 리포트와 스마트워치 연동도

기존 구조를 유지하면서 추가 가능하다.

---

# 다음 문서

IA.md
