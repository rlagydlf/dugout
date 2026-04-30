# 더그아웃(DUGOUT) — API 명세서

> 작성: 2026-04-30 · 입력자료: `prd.md` · `기능.pdf` · `ia.md` · `screens.md`

## 표기 규약

- **ID**: `A-도메인-번호` (예: `A-PRED-03`)
- **Priority**: `P0` (MVP 필수) · `P1` (출시 직후) · `P2` (확장)
- **Status**: `TODO` · `WIP` · `REVIEW` · `DONE`
- **Spec**: 기능명세서 상세번호
- 모든 응답은 JSON · 시간은 ISO-8601 (KST)

## 공통 규약

| 항목 | 값 |
|------|-----|
| Base URL | `https://api.dugout.app/v1` |
| Admin Base | `https://api.dugout.app/v1/admin` (또는 별도 도메인) |
| 인증 | `Authorization: Bearer <accessToken>` (JWT) |
| Refresh | `POST /auth/refresh` (HttpOnly cookie) |
| 페이지네이션 | `?cursor=<id>&limit=20` → `{items, nextCursor}` |
| 성공 응답 | `{ "data": { ... } }` |
| 에러 응답 | `{ "error": { "code": "...", "message": "..." } }` |

---

## 1. Auth · 인증

| ID | Method · Path | 설명 | Req → Res | 화면 | Spec | Priority | Owner | Status |
|----|---------------|------|-----------|------|------|----------|-------|--------|
| A-AUTH-01 | GET `/auth/me` | 현재 세션 확인 | — → `{user, team}` | S-AUTH-01 | 6 | P0 | | TODO |
| A-AUTH-02 | POST `/auth/check-duplicate` | 이메일·휴대폰 중복 체크 | `{email}` → `{exists}` | S-AUTH-03 | 6.1.2 | P0 | | TODO |
| A-AUTH-03 | POST `/auth/signup` | 회원가입 | `{email, password, terms[]}` → `{userId, accessToken}` | S-AUTH-03 | 6.1.1, 9.1 | P0 | | TODO |
| A-AUTH-04 | POST `/auth/login` | 이메일 로그인 | `{email, password}` → `{accessToken, refreshToken}` | S-AUTH-05 | 6.1 | P0 | | TODO |
| A-AUTH-05 | POST `/auth/password/reset-request` | 재설정 메일 발송 | `{email}` → `{ok}` | S-AUTH-06 | 6.2 | P1 | | TODO |
| A-AUTH-06 | POST `/auth/password/reset-confirm` | 새 비밀번호 설정 | `{token, newPassword}` → `{ok}` | S-AUTH-07 | 6.2.1 | P1 | | TODO |
| A-AUTH-07 | POST `/auth/withdraw` | 회원탈퇴 | `{reason?}` → `{ok}` | S-SETTING-06 | 6.3, 6.3.1 | P0 | | TODO |
| A-AUTH-08 | POST `/auth/refresh` | 토큰 갱신 | refresh cookie → `{accessToken}` | (전역) | 6 | P0 | | TODO |
| A-AUTH-09 | POST `/auth/logout` | 로그아웃 | — → `{ok}` | (전역) | 6.3 | P0 | | TODO |

---

## 2. User · Team

| ID | Method · Path | 설명 | Req → Res | 화면 | Spec | Priority | Owner | Status |
|----|---------------|------|-----------|------|------|----------|-------|--------|
| A-TEAM-01 | GET `/teams` | KBO 10팀 목록 | — → `[{id, name, color, logoUrl}]` | S-AUTH-04, S-SETTING-02 | 1.1 | P0 | | TODO |
| A-USER-01 | GET `/users/me` | 내 프로필·요약 | — → `{user, team, summary}` | S-FAN-01, S-HOME-01 | 1.2 | P0 | | TODO |
| A-USER-02 | PATCH `/users/me/team` | 응원팀 변경 | `{teamId}` → `{team, policy}` | S-SETTING-02 | 1.1.1 | P0 | | TODO |
| A-USER-03 | GET `/users/me/status` | 제재·이용 가능 여부 | — → `{banned, reason?}` | S-COMMON-03 | 5.3.2 | P1 | | TODO |

---

## 3. Home · Series

| ID | Method · Path | 설명 | Req → Res | 화면 | Spec | Priority | Owner | Status |
|----|---------------|------|-----------|------|------|----------|-------|--------|
| A-HOME-01 | GET `/home` | 홈 위젯 일괄 | `?date=` → `{series, sortie, quests, predictions, quizzes, point, contribution, rivalry, isGameDay, isOffseason}` | S-HOME-01, S-OFF-01 | 1.2, 1.2.1 | P0 | | TODO |
| A-SERIES-01 | GET `/series/today` | 오늘의 시리즈 상세 | `?teamId=` → `{matchup, parkInfo, quests, predictions}` | S-SERIES-01 | 7.1, 7.1.1 | P0 | | TODO |
| A-SERIES-02 | GET `/series/today/rivalry` | 매치업 상대 비교 지표 | — → `{home, away, metrics}` | S-SERIES-02 | 4.1, 7.1.2 | P1 | | TODO |

---

## 4. Sortie · 출정

> 에러 코드: `NOT_GAME_DAY`(2.1.1) · `ALREADY_SORTIED`(2.1.2)

| ID | Method · Path | 설명 | Req → Res | 화면 | Spec | Priority | Owner | Status |
|----|---------------|------|-----------|------|------|----------|-------|--------|
| A-SORTIE-01 | POST `/sortie` | 출정하기 | `{gameId}` → `{ok, pointAwarded, sortieId}` | S-SORTIE-01 | 2.1.1, 2.1.2, 2.1.3 | P0 | | TODO |
| A-SORTIE-02 | GET `/sortie/today` | 오늘 출정 상태 | — → `{sortied, sortieId?}` | S-HOME-01 | 2.1 | P0 | | TODO |

---

## 5. Quest · 퀘스트

| ID | Method · Path | 설명 | Req → Res | 화면 | Spec | Priority | Owner | Status |
|----|---------------|------|-----------|------|------|----------|-------|--------|
| A-QUEST-01 | GET `/quests` | 진행 가능 퀘스트 목록 | `?type=` → `[{id, type, title, reward, progress, deadline}]` | S-QUEST-01 | 2.2, 2.2.1 | P0 | | TODO |
| A-QUEST-02 | GET `/quests/:id` | 퀘스트 상세 | — → `{...}` | S-QUEST-02 | 2.2 | P0 | | TODO |
| A-QUEST-03 | POST `/quests/:id/complete` | 완료 처리 | `{evidence?}` → `{ok, pointAwarded}` | S-QUEST-02 | 2.2.2 | P0 | | TODO |

---

## 6. Prediction · 예측

> 에러 코드: `PREDICTION_CLOSED`(2.4.3) · `POINT_INSUFFICIENT` · `ALREADY_ENTERED`
> A-PRED-04: 자유 환금 정책 (법무 자문 의존)

| ID | Method · Path | 설명 | Req → Res | 화면 | Spec | Priority | Owner | Status |
|----|---------------|------|-----------|------|------|----------|-------|--------|
| A-PRED-01 | GET `/predictions` | 예측 항목 목록 | `?gameId=&type=` → `[{id, type, options, fixedOdds, deadline, status}]` | S-PRED-01 | 2.4, 10.1.1 | P0 | | TODO |
| A-PRED-02 | GET `/predictions/:id` | 예측 항목 상세 | — → `{..., myEntry?}` | S-PRED-02 | 2.4 | P0 | | TODO |
| A-PRED-03 | POST `/predictions/:id/entries` | 예측 참여 | `{optionId, mode, stake?}` → `{ok, entryId, expectedPayout}` | S-PRED-02 | 2.4.2, 2.4.3 | P0 | | TODO |
| A-PRED-04 | GET `/predictions/me/history` | 내 예측 내역 [법무 검토] | `?status=` → `[{...}]` | S-PRED-03 | 10.1.3 | P1 | | TODO |

---

## 7. Quiz · 퀴즈

| ID | Method · Path | 설명 | Req → Res | 화면 | Spec | Priority | Owner | Status |
|----|---------------|------|-----------|------|------|----------|-------|--------|
| A-QUIZ-01 | GET `/quizzes` | 활성 퀴즈 목록 | — → `[{id, title, reward, status}]` | S-QUIZ-01 | 2.3 | P1 | | TODO |
| A-QUIZ-02 | POST `/quizzes/:id/answer` | 정답 제출 | `{answer}` → `{correct, pointAwarded}` | S-QUIZ-02 | 2.3.1 | P1 | | TODO |

---

## 8. Check-in · 직관 체크인

> 에러 코드: `LOCATION_OUT_OF_RANGE` (위치 권한 거부는 클라이언트 처리)

| ID | Method · Path | 설명 | Req → Res | 화면 | Spec | Priority | Owner | Status |
|----|---------------|------|-----------|------|------|----------|-------|--------|
| A-CHECKIN-01 | POST `/checkins` | 직관 체크인 (위치 기반) | `{lat, lng, gameId}` → `{ok, pointAwarded, questCompleted?}` | S-CHECKIN-01 | 2.5, 2.5.1 | P1 | | TODO |
| A-CHECKIN-02 | GET `/checkins/me` | 내 체크인 내역 | `?cursor=&limit=` → `[{...}]` | S-FAN-01 | 4.3.1 | P1 | | TODO |

---

## 9. Point · 포인트 원장

| ID | Method · Path | 설명 | Req → Res | 화면 | Spec | Priority | Owner | Status |
|----|---------------|------|-----------|------|------|----------|-------|--------|
| A-POINT-01 | GET `/points/balance` | 잔액 | — → `{balance}` | S-HOME-01, S-POINT-01 | 3.1.1 | P0 | | TODO |
| A-POINT-02 | GET `/points/ledger` | 적립·사용 내역 | `?cursor=&type=` → `[{id, type, amount, reason, refType, refId, createdAt}]` | S-POINT-01 | 3.1.1, 11 | P0 | | TODO |
| A-POINT-03 | POST `/points/ad-reward` | 광고 시청 적립 | `{adId, signature}` → `{ok, pointAwarded}` | S-REWARD-03 | 3 | P2 | | TODO |

---

## 10. Reward · 리워드샵

> 에러 코드: `OUT_OF_STOCK` · `POINT_INSUFFICIENT`

| ID | Method · Path | 설명 | Req → Res | 화면 | Spec | Priority | Owner | Status |
|----|---------------|------|-----------|------|------|----------|-------|--------|
| A-REWARD-01 | GET `/rewards` | 카테고리·상품 목록 | `?category=` → `[{id, category, name, price, stock, imageUrl}]` | S-REWARD-01 | 3.2, 3.2.1 | P0 | | TODO |
| A-REWARD-02 | GET `/rewards/:id` | 상품 상세 | — → `{...}` | S-REWARD-02 | 3.2 | P0 | | TODO |
| A-REWARD-03 | POST `/rewards/:id/exchange` | 교환 | `{quantity?}` → `{ok, exchangeId, couponCode?}` | S-REWARD-02 | 3.2.2 | P0 | | TODO |
| A-REWARD-04 | GET `/rewards/me/exchanges` | 내 교환 내역 | `?cursor=` → `[{...}]` | S-FAN-01 | 3.2 | P1 | | TODO |

---

## 11. Fan Card · 팀 기여도

> `contribution`은 인앱 메트릭 (KBO·구단 공식 데이터 아님 — 정책 결정 #1)

| ID | Method · Path | 설명 | Req → Res | 화면 | Spec | Priority | Owner | Status |
|----|---------------|------|-----------|------|------|----------|-------|--------|
| A-FAN-01 | GET `/fancard/me` | 팬카드 정보 | — → `{team, summary, badges, contribution}` | S-FAN-01 | 4.3, 4.3.1 | P0 | | TODO |
| A-FAN-02 | PATCH `/fancard/me/customize` | 배지·테마 적용 | `{badgeIds[], themeId}` → `{ok}` | S-FAN-02 | 4.3 | P1 | | TODO |
| A-FAN-03 | GET `/contribution/me` | 내 팀 기여도 상세 | — → `{score, breakdown, teamRank}` | S-FAN-03 | 4.2, 4.2.1 | P1 | | TODO |
| A-FAN-04 | GET `/contribution/team/:teamId` | 팀 기여도 합산 (라이벌 비교용) | — → `{teamId, totalScore, fanCount}` | S-SERIES-02 | 4.1 | P1 | | TODO |

---

## 12. Notification · 알림

| ID | Method · Path | 설명 | Req → Res | 화면 | Spec | Priority | Owner | Status |
|----|---------------|------|-----------|------|------|----------|-------|--------|
| A-NOTI-01 | GET `/notifications` | 인박스 목록 | `?cursor=&unreadOnly=` → `[{id, type, title, body, readAt, createdAt}]` | S-NOTI-01 | 8 | P1 | | TODO |
| A-NOTI-02 | POST `/notifications/:id/read` | 읽음 처리 | — → `{ok}` | S-NOTI-01 | 8 | P1 | | TODO |
| A-NOTI-03 | GET·PATCH `/notifications/preferences` | 수신 설정 조회·변경 | `{push, email, types{...}}` → `{...}` | S-SETTING-03 | 8.1, 8.1.1 | P1 | | TODO |
| A-NOTI-04 | POST `/notifications/devices` | 푸시 토큰 등록 | `{token, platform}` → `{ok}` | (전역) | 8 | P1 | | TODO |

---

## 13. Off-season · 스토브리그

| ID | Method · Path | 설명 | Req → Res | 화면 | Spec | Priority | Owner | Status |
|----|---------------|------|-----------|------|------|----------|-------|--------|
| A-OFFSEASON-01 | GET `/offseason/contents` | 스토브리그 콘텐츠 허브 | `?type=` → `[{id, type, title, status}]` | S-OFF-02 | 정책 결정 #4 | P2 | | TODO |

---

## 14. Document · Support

| ID | Method · Path | 설명 | Req → Res | 화면 | Spec | Priority | Owner | Status |
|----|---------------|------|-----------|------|------|----------|-------|--------|
| A-DOC-01 | GET `/docs/:slug` | 약관·개인정보·오픈소스 | — → `{title, html}` | S-SETTING-04 | 9.1 | P0 | | TODO |
| A-SUPPORT-01 | GET `/support/faqs` | FAQ 목록 | `?category=` → `[{q, a}]` | S-SETTING-05 | 9.1 | P0 | | TODO |
| A-SUPPORT-02 | POST `/support/inquiries` | 1:1 문의 등록 | `{subject, body, attachments?}` → `{ticketId}` | S-SETTING-05 | 9.1 | P0 | | TODO |

---

## 15. Admin · 콘텐츠 관리

| ID | Method · Path | 설명 | Req → Res | 화면 | Spec | Priority | Owner | Status |
|----|---------------|------|-----------|------|------|----------|-------|--------|
| A-ADMIN-QUEST-01 | GET `/admin/quests` | 퀘스트 목록 | filters → `[...]` | S-ADMIN-02 | 5.1.1 | P0 | | TODO |
| A-ADMIN-QUEST-02 | POST `/admin/quests` | 등록 | `{type, title, condition, reward, period}` → `{id}` | S-ADMIN-02 | 5.1.1 | P0 | | TODO |
| A-ADMIN-QUEST-03 | PATCH `/admin/quests/:id` | 수정 | partial → `{ok}` | S-ADMIN-02 | 5.1.1 | P0 | | TODO |
| A-ADMIN-QUEST-04 | POST `/admin/quests/:id/activate` | 활성·비활성 | `{active}` → `{ok}` | S-ADMIN-02 | 5.1.1 | P0 | | TODO |
| A-ADMIN-QUIZ-01 | GET `/admin/quizzes` | 목록 | — → `[...]` | S-ADMIN-03 | 5.1.2 | P0 | | TODO |
| A-ADMIN-QUIZ-02 | POST `/admin/quizzes` | 등록 (문제·정답·보상) | `{...}` → `{id}` | S-ADMIN-03 | 5.1.2 | P0 | | TODO |
| A-ADMIN-QUIZ-03 | PATCH `/admin/quizzes/:id` | 수정 | partial → `{ok}` | S-ADMIN-03 | 5.1.2 | P0 | | TODO |
| A-ADMIN-QUIZ-04 | POST `/admin/quizzes/:id/activate` | 노출 토글 | `{active}` → `{ok}` | S-ADMIN-03 | 5.1.2 | P0 | | TODO |
| A-ADMIN-PRED-01 | GET `/admin/predictions` | 항목 목록 | — → `[...]` | S-ADMIN-04 | 5.1.3 | P0 | | TODO |
| A-ADMIN-PRED-02 | POST `/admin/predictions` | 항목 등록 (배당·마감 포함) | `{gameId, type, options[], fixedOdds, deadline}` → `{id}` | S-ADMIN-04 | 5.1.3, 10.1.1 | P0 | | TODO |
| A-ADMIN-PRED-03 | PATCH `/admin/predictions/:id` | 수정 | partial → `{ok}` | S-ADMIN-04 | 5.1.3 | P0 | | TODO |
| A-ADMIN-PRED-04 | POST `/admin/predictions/:id/activate` | 노출 토글 | `{active}` → `{ok}` | S-ADMIN-04 | 5.1.3 | P0 | | TODO |
| A-ADMIN-PRED-05 | POST `/admin/predictions/:id/settle` | 결과 확정 → 정산 트리거 | `{winningOptionId}` → `{settledCount, totalPayout}` | S-ADMIN-05 | 10.1.2 | P1 | | TODO |
| A-ADMIN-PRED-06 | POST `/admin/predictions/settle/retry` | 정산 실패 재처리 | `{settlementJobId}` → `{ok}` | S-ADMIN-05 | 10.1.2 | P1 | | TODO |

---

## 16. Admin · 리워드 / 어뷰징 / 포인트 / 알림

| ID | Method · Path | 설명 | Req → Res | 화면 | Spec | Priority | Owner | Status |
|----|---------------|------|-----------|------|------|----------|-------|--------|
| A-ADMIN-REWARD-01 | GET `/admin/rewards` | 상품 목록 | — → `[...]` | S-ADMIN-06 | 5.2.1 | P0 | | TODO |
| A-ADMIN-REWARD-02 | POST `/admin/rewards` | 상품 등록 | `{...}` → `{id}` | S-ADMIN-06 | 5.2.1 | P0 | | TODO |
| A-ADMIN-REWARD-03 | PATCH `/admin/rewards/:id` | 수정 (재고·가격·노출) | partial → `{ok}` | S-ADMIN-06 | 5.2.1 | P0 | | TODO |
| A-ADMIN-REWARD-04 | POST `/admin/rewards/coupons/issue` | 쿠폰 발급·배치 | `{rewardId, count}` → `{batchId}` | S-ADMIN-06 | 5.2.1 | P0 | | TODO |
| A-ADMIN-ABUSE-01 | GET `/admin/abuse/rules` | 탐지 룰 목록 | — → `[...]` | S-ADMIN-07 | 5.3.1 | P1 | | TODO |
| A-ADMIN-ABUSE-02 | POST `/admin/abuse/rules` | 룰 등록 | `{name, signal, threshold}` → `{id}` | S-ADMIN-07 | 5.3.1 | P1 | | TODO |
| A-ADMIN-ABUSE-03 | PATCH `/admin/abuse/rules/:id` | 룰 수정 | partial → `{ok}` | S-ADMIN-07 | 5.3.1 | P1 | | TODO |
| A-ADMIN-ABUSE-04 | GET `/admin/abuse/cases` | 의심 사례 목록 | `?status=` → `[...]` | S-ADMIN-08 | 5.3.2 | P1 | | TODO |
| A-ADMIN-ABUSE-05 | POST `/admin/abuse/cases/:userId/sanction` | 제재 집행 | `{type, reason, duration?}` → `{ok}` | S-ADMIN-08 | 5.3.2 | P1 | | TODO |
| A-ADMIN-POINT-01 | GET `/admin/users/:userId/points` | 사용자 포인트 내역 | — → `{balance, ledger[]}` | S-ADMIN-09 | 11 | P1 | | TODO |
| A-ADMIN-POINT-02 | POST `/admin/users/:userId/points/adjust` | 지급·회수·정정 + 사유 | `{amount, type, reason}` → `{ok, ledgerId}` | S-ADMIN-09 | 11.1, 11.1.1 | P1 | | TODO |
| A-ADMIN-NOTI-01 | POST `/admin/notifications` | 공지·이벤트 발송 | `{target, title, body, channel}` → `{id, sentCount}` | S-ADMIN-10 | 8.2, 8.2.1 | P1 | | TODO |
| A-ADMIN-NOTI-02 | GET `/admin/notifications` | 발송 이력 | — → `[...]` | S-ADMIN-10 | 8.2.1 | P1 | | TODO |
| A-ADMIN-NOTI-03 | GET `/admin/notifications/:id/stats` | 도달·읽음 통계 | — → `{...}` | S-ADMIN-10 | 8.2 | P1 | | TODO |

---

## 17. Admin · 대시보드 · 사용자

| ID | Method · Path | 설명 | Req → Res | 화면 | Spec | Priority | Owner | Status |
|----|---------------|------|-----------|------|------|----------|-------|--------|
| A-ADMIN-DASH-01 | GET `/admin/dashboard` | 운영 KPI 요약 | `?range=` → `{dau, mau, sortieRate, ...}` | S-ADMIN-01 | — | P0 | | TODO |
| A-ADMIN-USER-01 | GET `/admin/users` | 사용자 검색·목록 | `?q=` → `[...]` | S-ADMIN-11 | — | P2 | | TODO |
| A-ADMIN-USER-02 | GET `/admin/users/:userId` | 사용자 상세 | — → `{...}` | S-ADMIN-11 | — | P2 | | TODO |

---

## 데이터 모델 ER (요약)

```
User ── has-one ── Team
User ── has-many ── Sortie / QuestLog / PredictionEntry / QuizAnswer / Checkin / Exchange / Notification
User ── has-many ── PointLedger
Team ── has-many ── Game / Series
Game ── has-many ── PredictionItem / Quest(game-type)
PredictionItem ── has-many ── PredictionEntry
PredictionItem ── has-one ── SettlementResult
RewardItem ── has-many ── Exchange
AbuseRule ── has-many ── AbuseCase ── User
AdminUser ── audit ── PointLedger / AbuseSanction / NotificationDispatch
```

---

## 분담 가이드

### 추천 BE 분담

| 담당 | 도메인 |
|------|--------|
| BE 1 (Identity) | §1 Auth, §2 User·Team, §14 Document·Support |
| BE 2 (Game-day Core) | §3 Home·Series, §4 Sortie, §5 Quest, §6 Prediction, §7 Quiz, §8 Check-in |
| BE 3 (Economy) | §9 Point, §10 Reward, §16 Admin Point |
| BE 4 (Fan·Notification) | §11 Fan Card, §12 Notification, §16 Admin Noti |
| BE 5 (Admin·Off-season) | §13 Off-season, §15 Admin Content, §16 Admin Reward·Abuse, §17 Dashboard |

### MVP 우선순위

- **P0** — §1 Auth · §2 User·Team · §3 Home·Series · §4 Sortie · §5 Quest · §6 Prediction(A-PRED-01~03) · §9 Point · §10 Reward · §11 A-FAN-01 · §14 Document·Support · §15 Admin Content · §16 Admin Reward · §17 A-ADMIN-DASH-01
- **P1** — §6 A-PRED-04 · §7 Quiz · §8 Check-in · §11 A-FAN-02~04 · §12 Notification · §16 Admin Abuse·Point·Noti
- **P2** — §9 A-POINT-03 · §13 Off-season · §17 Admin User

### 계약 우선 작업

API 계약 픽스 → FE는 mock(MSW 등)으로 병렬 진행. BE 구현 전 계약 합의를 위해 OpenAPI/Swagger(`api.yaml`) 분리 작성 권장.

---

## 비고

- **A-PRED-04** — 자유 환금 정책 (정책 결정 #2). 응답 필드·약관 표시 의무 법무 검수.
- **A-CHECKIN-01** — 위치 검증 기준(반경 m), 어뷰징 대응(GPS 스푸핑) 미정.
- **A-OFFSEASON-01** — 콘텐츠 종류 확정 후 세부 엔드포인트 분리.
- **A-POINT-02** — 포인트 원장 멱등성 키·이벤트 중복 처리 정책 확정 필요(3.1.2).
- **Admin Base URL** — 별도 도메인 vs 권한 분기 결정 필요 (잔여 Open Q #3).
