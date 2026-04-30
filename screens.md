# 더그아웃(DUGOUT) — 화면 목록

> 작성: 2026-04-30 · 입력자료: `prd.md` · `기능.pdf` · `ia.md`

## 표기 규약

- **ID**: `S-도메인-번호` (예: `S-AUTH-03`)
- **Priority**: `P0` (MVP 필수) · `P1` (출시 직후) · `P2` (확장)
- **Status**: `TODO` · `WIP` · `REVIEW` · `DONE`
- **Spec**: 기능명세서 상세번호 (예: `2.4.3`)
- 디바이스는 별도 표기 없으면 **Mobile Web / iOS / Android 공통**

---

## 1. 인증 · 온보딩

> 비로그인 접근 가능. 회원가입 후 응원팀 선택 필수.

| ID | 화면명 | 라우트 | 사용 API | Spec | Priority | Owner | Status |
|----|--------|--------|----------|------|----------|-------|--------|
| S-AUTH-01 | 스플래시 / 앱 진입 | `/` | A-AUTH-01 | 6 | P0 | | TODO |
| S-AUTH-02 | 로그인·회원가입 진입 | `/auth` | — | 6.1 | P0 | | TODO |
| S-AUTH-03 | 회원가입 폼 | `/auth/signup` | A-AUTH-02, A-AUTH-03 | 6.1.1, 6.1.2, 9.1 | P0 | | TODO |
| S-AUTH-04 | 응원팀 선택 | `/auth/team` | A-TEAM-01, A-USER-02 | 1.1 | P0 | | TODO |
| S-AUTH-05 | 이메일 로그인 | `/auth/login` | A-AUTH-04 | 6.1 | P0 | | TODO |
| S-AUTH-06 | 비밀번호 재설정 요청 | `/auth/reset` | A-AUTH-05 | 6.2 | P1 | | TODO |
| S-AUTH-07 | 비밀번호 재설정 완료 | `/auth/reset/confirm` | A-AUTH-06 | 6.2.1 | P1 | | TODO |

---

## 2. 홈 · 오늘의 시리즈

> 로그인 필수. 경기일/비경기일 분기 처리.

| ID | 화면명 | 라우트 | 사용 API | Spec | Priority | Owner | Status |
|----|--------|--------|----------|------|----------|-------|--------|
| S-HOME-01 | 마이 더그아웃(홈) | `/home` | A-HOME-01 | 1.2, 1.2.1 | P0 | | TODO |
| S-SERIES-01 | 오늘의 시리즈 상세 | `/series/today` | A-SERIES-01 | 7.1, 7.1.1 | P0 | | TODO |
| S-SERIES-02 | 라이벌 팬 비교 (오늘 매치업) | `/series/rivalry` | A-SERIES-02, A-FAN-04 | 4.1, 7.1.2 | P1 | | TODO |

---

## 3. 출정

> 경기일 1일 1회. 비경기일 비활성.

| ID | 화면명 | 라우트 | 사용 API | Spec | Priority | Owner | Status |
|----|--------|--------|----------|------|----------|-------|--------|
| S-SORTIE-01 | 출정 모달 | `/sortie` | A-SORTIE-01, A-SORTIE-02 | 2.1, 2.1.1, 2.1.2, 2.1.3 | P0 | | TODO |

---

## 4. 퀘스트

> 일일 / 경기일 / 라이벌전 / 시리즈 / 직관 5개 유형.

| ID | 화면명 | 라우트 | 사용 API | Spec | Priority | Owner | Status |
|----|--------|--------|----------|------|----------|-------|--------|
| S-QUEST-01 | 퀘스트 목록 | `/quests` | A-QUEST-01 | 2.2, 2.2.1 | P0 | | TODO |
| S-QUEST-02 | 퀘스트 상세 | `/quests/:id` | A-QUEST-02, A-QUEST-03 | 2.2.2 | P0 | | TODO |

---

## 5. 예측

> 자유 환금 정책 (법무 자문 의존). EPIC 10 정산 로직과 연계.

| ID | 화면명 | 라우트 | 사용 API | Spec | Priority | Owner | Status |
|----|--------|--------|----------|------|----------|-------|--------|
| S-PRED-01 | 예측 항목 목록 | `/predictions` | A-PRED-01 | 2.4, 2.4.1, 2.4.3 | P0 | | TODO |
| S-PRED-02 | 예측 참여 상세 | `/predictions/:id` | A-PRED-02, A-PRED-03 | 2.4.2, 10.1.1 | P0 | | TODO |
| S-PRED-03 | 예측 정산 내역 [법무 검토] | `/predictions/history` | A-PRED-04 | 10.1.3 | P1 | | TODO |

---

## 6. 퀴즈

| ID | 화면명 | 라우트 | 사용 API | Spec | Priority | Owner | Status |
|----|--------|--------|----------|------|----------|-------|--------|
| S-QUIZ-01 | 퀴즈 목록 | `/quizzes` | A-QUIZ-01 | 2.3 | P1 | | TODO |
| S-QUIZ-02 | 퀴즈 풀이 | `/quizzes/:id` | A-QUIZ-02 | 2.3.1 | P1 | | TODO |

---

## 7. 직관 체크인

> 위치 권한 필수. 권한 거부/구장 외부 시 안내 모달(`S-COMMON-02`).

| ID | 화면명 | 라우트 | 사용 API | Spec | Priority | Owner | Status |
|----|--------|--------|----------|------|----------|-------|--------|
| S-CHECKIN-01 | 직관 체크인 | `/checkin` | A-CHECKIN-01 | 2.5, 2.5.1 | P1 | | TODO |

---

## 8. 포인트 · 리워드

| ID | 화면명 | 라우트 | 사용 API | Spec | Priority | Owner | Status |
|----|--------|--------|----------|------|----------|-------|--------|
| S-POINT-01 | 포인트 잔액 / 내역(원장) | `/points` | A-POINT-01, A-POINT-02 | 3.1.1 | P0 | | TODO |
| S-REWARD-01 | 리워드샵 카테고리 | `/rewards` | A-REWARD-01 | 3.2, 3.2.1 | P0 | | TODO |
| S-REWARD-02 | 상품 상세 | `/rewards/:id` | A-REWARD-02, A-REWARD-03 | 3.2.2 | P0 | | TODO |
| S-REWARD-03 | 광고 시청 적립 | `/rewards/ad` | A-POINT-03 | 3 | P2 | | TODO |

---

## 9. 팬카드 · 팀 기여도

> 팀 기여도는 인앱 메트릭 (구단 연계 없음).

| ID | 화면명 | 라우트 | 사용 API | Spec | Priority | Owner | Status |
|----|--------|--------|----------|------|----------|-------|--------|
| S-FAN-01 | 팬카드 (프로필) | `/fancard` | A-FAN-01 | 4.3, 4.3.1 | P0 | | TODO |
| S-FAN-02 | 프로필 꾸미기 | `/fancard/customize` | A-FAN-02 | 4.3 | P1 | | TODO |
| S-FAN-03 | 팀 기여도 상세 | `/contribution` | A-FAN-03 | 4.2, 4.2.1 | P1 | | TODO |

---

## 10. 알림

| ID | 화면명 | 라우트 | 사용 API | Spec | Priority | Owner | Status |
|----|--------|--------|----------|------|----------|-------|--------|
| S-NOTI-01 | 알림 센터 (인박스) | `/notifications` | A-NOTI-01, A-NOTI-02 | 8 (보강) | P1 | | TODO |

---

## 11. 설정

| ID | 화면명 | 라우트 | 사용 API | Spec | Priority | Owner | Status |
|----|--------|--------|----------|------|----------|-------|--------|
| S-SETTING-01 | 설정 홈 | `/settings` | — | — | P0 | | TODO |
| S-SETTING-02 | 응원팀 변경 | `/settings/team` | A-USER-02 | 1.1.1 | P0 | | TODO |
| S-SETTING-03 | 알림 수신 설정 | `/settings/notifications` | A-NOTI-03 | 8.1, 8.1.1 | P1 | | TODO |
| S-SETTING-04 | 약관 / 개인정보 / 오픈소스 | `/settings/legal` | A-DOC-01 | 9.1 | P0 | | TODO |
| S-SETTING-05 | FAQ / 1:1 문의 | `/settings/support` | A-SUPPORT-01, A-SUPPORT-02 | 9.1 | P0 | | TODO |
| S-SETTING-06 | 회원탈퇴 | `/settings/withdraw` | A-AUTH-07 | 6.3, 6.3.1 | P0 | | TODO |

---

## 12. 비경기일 / 오프시즌

> 11~3월 스토브리그 콘텐츠.

| ID | 화면명 | 라우트 | 사용 API | Spec | Priority | Owner | Status |
|----|--------|--------|----------|------|----------|-------|--------|
| S-OFF-01 | 비경기일 / 오프시즌 홈 분기 | `/home` (조건부) | A-HOME-01 | 1.2.1 | P1 | | TODO |
| S-OFF-02 | 스토브리그 콘텐츠 허브 | `/offseason` | A-OFFSEASON-01 | 정책 결정 #4 | P2 | | TODO |

---

## 13. 공통 / 예외

| ID | 화면명 | 라우트 | 사용 API | Spec | Priority | Owner | Status |
|----|--------|--------|----------|------|----------|-------|--------|
| S-COMMON-01 | 4xx / 5xx 에러 페이지 | `*` | — | — | P0 | | TODO |
| S-COMMON-02 | 권한 거부 안내 (위치/알림) | 모달 | — | 2.5.1, 8.1.1 | P0 | | TODO |
| S-COMMON-03 | 어뷰징 제재 안내 | `/banned` | A-USER-03 | 5.3.2 | P1 | | TODO |

---

## 14. Admin · CMS

> Admin 권한 필수. 별도 도메인(예: `admin.dugout.app`) 또는 권한 분기 (잔여 Open Q).

| ID | 화면명 | 라우트 | 사용 API | Spec | Priority | Owner | Status |
|----|--------|--------|----------|------|----------|-------|--------|
| S-ADMIN-01 | 운영 대시보드 | `/admin` | A-ADMIN-DASH-01 | — | P0 | | TODO |
| S-ADMIN-02 | 퀘스트 관리 | `/admin/quests` | A-ADMIN-QUEST-01~04 | 5.1.1 | P0 | | TODO |
| S-ADMIN-03 | 퀴즈 관리 | `/admin/quizzes` | A-ADMIN-QUIZ-01~04 | 5.1.2 | P0 | | TODO |
| S-ADMIN-04 | 예측 항목 관리 | `/admin/predictions` | A-ADMIN-PRED-01~04 | 5.1.3, 10.1.1 | P0 | | TODO |
| S-ADMIN-05 | 예측 정산 관리 | `/admin/predictions/settle` | A-ADMIN-PRED-05, 06 | 10.1.2 | P1 | | TODO |
| S-ADMIN-06 | 리워드샵 관리 | `/admin/rewards` | A-ADMIN-REWARD-01~04 | 5.2.1 | P0 | | TODO |
| S-ADMIN-07 | 어뷰징 룰 관리 | `/admin/abuse/rules` | A-ADMIN-ABUSE-01~03 | 5.3.1 | P1 | | TODO |
| S-ADMIN-08 | 어뷰징 제재 집행 | `/admin/abuse/cases` | A-ADMIN-ABUSE-04, 05 | 5.3.2 | P1 | | TODO |
| S-ADMIN-09 | 포인트 원장 / 정정 | `/admin/points` | A-ADMIN-POINT-01, 02 | 11.1, 11.1.1 | P1 | | TODO |
| S-ADMIN-10 | 알림 발송 | `/admin/notifications` | A-ADMIN-NOTI-01~03 | 8.2, 8.2.1 | P1 | | TODO |
| S-ADMIN-11 | 사용자 조회 | `/admin/users` | A-ADMIN-USER-01, 02 | — | P2 | | TODO |

---

## 분담 가이드

### 추천 화면 분담

| 담당 | 도메인 | 화면 ID |
|------|--------|---------|
| FE A | 인증·홈·설정 | S-AUTH-*, S-HOME-01, S-SERIES-01~02, S-SETTING-* |
| FE B | 참여 핵심 | S-SORTIE-01, S-QUEST-*, S-PRED-*, S-QUIZ-*, S-CHECKIN-01 |
| FE C | 포인트·리워드·팬카드·알림 | S-POINT-01, S-REWARD-*, S-FAN-*, S-NOTI-01 |
| FE D | Admin | S-ADMIN-* |
| Designer | 화면 ID 단위 시안 | 모든 화면 (Figma 링크 추가 가능) |
| PM | Owner / Status 주간 갱신 | — |

### MVP 우선순위 (P0)

S-AUTH-01~05, S-HOME-01, S-SERIES-01, S-SORTIE-01, S-QUEST-01~02, S-PRED-01~02, S-POINT-01, S-REWARD-01~02, S-FAN-01, S-SETTING-01·02·04·05·06, S-COMMON-01·02, S-ADMIN-01~04·06

### P1 (출시 직후)

S-AUTH-06~07, S-SERIES-02, S-PRED-03, S-QUIZ-01~02, S-CHECKIN-01, S-FAN-02~03, S-NOTI-01, S-SETTING-03, S-OFF-01, S-COMMON-03, S-ADMIN-05·07~10

### P2 (확장)

S-REWARD-03, S-OFF-02, S-ADMIN-11

---

## 비고

- **S-PRED-03** — 자유 환금 정책 (정책 결정 #2). 출시 전 법무 자문 결과에 따라 카피·플로우 변경 가능.
- **S-CHECKIN-01** — 티켓 QR 연동 도입 시 별도 화면 추가 필요 (잔여 Open Q #5).
- **S-OFF-02** — 콘텐츠 종류·갯수 미확정 (정책 결정 #4 후속).
- **Admin 도메인** — 별도 앱 vs 권한 분기 미정 (잔여 Open Q #3).
