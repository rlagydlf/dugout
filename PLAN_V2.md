# 더그아웃 v2 대규모 업데이트 기획안

> 작성: 2026-04-30 · 예상 작업 시간: **6시간 30분** (8개 phase, 압축 시 5시간)
> 목표: AI 티 제거 + 진짜 디자이너 손길 + KBO 팬덤 정체성 + 앱 스토어 출시 가능 수준

---

## 1. Context

v1(35개 화면, MVP 동작 OK)을 기준으로 사용자 피드백 누적:

> "글씨가 너무 작고 잘 안 보임 / 폰트 깨짐 / 너무 AI 같음 / 단순 그라데이션만 / 천재 디자이너 손길 없음 / 매치업이 진짜 KBO 라이브 같지 않음"

v1은 빠르게 만들어진 prototype에 가깝고, 30화면을 designer 3명이 분담하다 보니 **톤이 분열**되어 있다. v2는 단일 디자인 시스템으로 **전 화면 통일** + ambient 효과 **절제** + KBO 팬덤이 보고 "진짜 야구 앱"이라 느낄 수준.

---

## 2. 현재 진단 (v1 문제점)

| # | 영역 | 문제 |
|---|------|------|
| 1 | **폰트** | Anton/VT323/Black Ops/Major Mono로 한글 호출 → 시스템 fallback 깨짐 |
| 2 | **폰트 가중치** | Noto Sans KR weight 일관성 부족 (w400~w900 무작위) |
| 3 | **AI 효과 남발** | 모든 화면에 다이아몬드 그리드 + CRT 스캔라인 + 회전 야구공 + 펄스 글로우 + 그라데이션 카드 |
| 4 | **그라데이션 반복** | 모든 카드/타일/CTA가 동일한 LinearGradient 패턴 |
| 5 | **레이아웃 평면** | 대비/위계 부족, 비대칭 의도 없음 |
| 6 | **카드 패딩** | 8~14pt 무작위 (16~20pt 표준 부재) |
| 7 | **매치업 카드** | 양 팀 로고만, 라이브 정보(이닝/타석/투구수) 부족 |
| 8 | **출정 모달** | 3-phase 좋지만 ambient 효과 과다 + 햅틱 일관성 부족 |
| 9 | **응원팀 선택** | 10팀 카드만 보여줌, 팀 시즌 통계/순위/슬로건 없음 |
| 10 | **빈 상태** | 데이터 0건일 때 표시 없음 |
| 11 | **로딩** | spinner 한두 곳, skeleton 없음 |
| 12 | **에러** | 500 페이지만 있고 4xx/network/timeout 분기 없음 |
| 13 | **데이터 일관성** | 각 화면 const mock 흩어짐, 사용자 액션 → 다른 화면 반영 안 됨 |
| 14 | **인터랙션** | 페이지 전환 모두 default fade, 햅틱·사운드 없음 |
| 15 | **safe area** | iOS notch / 하단 home indicator 일부 화면 처리 누락 |

---

## 3. 목표 (성공 기준)

| 지표 | v1 | v2 목표 |
|------|-----|---------|
| 폰트 깨짐 | 다수 | **0건** |
| `flutter analyze` | 7 issue | 0 issue |
| ambient 효과 | 화면당 6+종 | 화면당 **0~2종** (의도적) |
| 매치업 카드 정보 | 6요소 | **15요소** (이닝별 LED, 투구수, 타석, 평균자책점, 다음 타자 등) |
| 빈 상태 / 로딩 / 에러 화면 | 1개 | **3종 × 모든 list 화면 = 30+개** |
| 햅틱 트리거 | 2곳 | **15+곳** |
| README · 스크린샷 | 일부 | 완전 정리 |

---

## 4. Phase 별 작업 계획

### Phase 1 — 디자인 토큰 + Pretendard (45분)

**산출물**: 단일 폰트/색상/간격 시스템

- [ ] Pretendard `.otf` 6 weight (Regular/Medium/SemiBold/Bold/ExtraBold/Black) `assets/fonts/`에 직접 다운로드 (OFL 라이선스, GitHub release)
- [ ] `pubspec.yaml` fonts 등록
- [ ] `DType` 헬퍼 갈아엎기:
  - 한글 = **모두 Pretendard** (`.body / .heading / .label / .caption`)
  - 영문 액센트만 Anton (impact display) / Black Ops (badge) — 그 외 영문 폰트 4종(VT323, JetBrains, Major Mono) 제거
- [ ] 색상 팔레트 표준화 — 10팀 컬러 + neutral 8단계 (`bg/surface1/surface2/border/text-{primary/secondary/tertiary/disabled}`)
- [ ] Spacing/Radius/Elevation 표준화 (`s4/s8/s12/s16/s20/s24/s32/s48`, `r8/r12/r16/r24`, `elev1/2/3`)

**검증**: 모든 화면에서 한글 텍스트 Pretendard로 렌더 + `flutter analyze` 0 issue

---

### Phase 2 — 컴포넌트 라이브러리 표준화 (45분)

**산출물**: 단일 컴포넌트 카탈로그

- [ ] **DButton** — primary/secondary/ghost/danger 4 variant + size sm/md/lg + loading/icon
- [ ] **DCard** — surface 1종 + 옵션(border/elevation), 글래스 효과 제거 (BackdropFilter 사용 금지)
- [ ] **DChip** — filter/badge/status 통합
- [ ] **DInput** — text/password/search/number, focus 상태 명확
- [ ] **DAppBar** — back/title/actions 표준
- [ ] **DSection** — 섹션 헤더(title + caption + action)
- [ ] **DEmptyState** — 빈 리스트용 (icon + title + body + cta)
- [ ] **DLoadingSkeleton** — list/card/grid 3종
- [ ] **DErrorBlock** — inline 에러 표시
- [ ] **DStatBlock** — 큰 숫자 + 라벨 (모노)
- [ ] **DMatchupCard v2** — 진짜 KBO 라이브 (이닝별 R/H/E LED 보드 + 선발 투수 + 다음 타자 + 평균자책점)

**검증**: 컴포넌트 카탈로그 한 화면(/dev/components)에서 렌더 확인

---

### Phase 3 — AI 효과 정리 + 레이아웃 재정립 (60분)

**산출물**: 절제된 시각, 의도적 위계

- [ ] **회전 야구공 ambient 제거** (4 화면에서 적용된 것 모두 빼기)
- [ ] **다이아몬드 그리드 패턴 제거** (배경엔 단색 또는 mood image 1장만)
- [ ] **CRT 스캔라인 제거** (auth/splash 등)
- [ ] **펄스 글로우 절제** — 라이브 배지 1곳만 유지, 나머지 제거
- [ ] **그라데이션 카드 → 솔리드** — 카드는 surface 솔리드 + 1px border
- [ ] **레이아웃 비대칭 강화** — 헤더 좌heavy/우compact, 카드 grid → 1+2 mix 등
- [ ] **카드 padding 16/20 표준화**
- [ ] **하단 nav 시각 정제** — floating bar 글로우 절제, 단순 다크 surface

**검증**: 시뮬레이터에서 각 화면 ambient 효과 0~2종 확인

---

### Phase 4 — 핵심 화면 재디자인 (90분)

**산출물**: 진짜 디자이너 톤의 hero 화면들

- [ ] **Splash (15분)** — 단순 로고 + 슬로건 + 브랜드 컬러. 글로우 ring/스캔라인 제거.
- [ ] **응원팀 선택 (20분)** — 10팀 카드(로고 + 마스코트) + 팀 시즌 통계 미리보기 (선두 차이/우승 횟수/주력 타자) + 슬로건 인용
- [ ] **Home (25분)** —
  - 헤더: 닉네임 + 응원팀 + 포인트
  - **DMatchupCard v2** (이닝별 LED + 라이브)
  - 출정 CTA (글로우 절제)
  - 4탭 액션 grid (실제 PNG 아이콘)
  - 라이벌 비교 (전적 표 + 마스코트)
  - 오늘의 시리즈 알림 + 이번주 미션
- [ ] **Series 상세 (15분)** — DMatchupCard v2 hero + 선발 투수 카드 2장 + 이닝별 LED + 라이브 이벤트 타임라인 + 시리즈 퀘스트
- [ ] **Sortie modal (10분)** — 3-phase 단순화: charging → explode → complete. 스파클/추가 ripple 제거. 햅틱 3단계.
- [ ] **Fancard (5분)** — 시즌권 카드 디테일 정리 (가입일/카드번호/순위 강조)

---

### Phase 5 — 게임플레이 화면 정리 (60분)

**산출물**: 일관된 게임플레이 톤

- [ ] **Quest list/detail (15분)** — 유형 칩 / 진행도 / 보상 / 완료 흐름
- [ ] **Prediction list/detail (20분)** — DMatchupCard v2 미니 사이즈 / 옵션 라디오 / 베팅 슬라이더 / 예상 보상 / 정산 안내
- [ ] **Quiz list/detail (10분)** — 카테고리 / 난이도 별 / 4지선다 / 결과 phase
- [ ] **Reward list/detail (10분)** — 카테고리 탭 / FEATURED 캐러셀 / 한정 배지 / 교환 다이얼로그 / 쿠폰 발급
- [ ] **Point ledger (5분)** — 잔액 카드 / 그래프 / 필터 / 내역

---

### Phase 6 — 인증 / 설정 / 공통 (45분)

**산출물**: 정돈된 부수 화면

- [ ] **Auth welcome (5분)** — 단순 hero + 슬로건 + 2 CTA
- [ ] **Signup (10분)** — 이메일/비번/약관 stepper
- [ ] **Login (5분)** — 이메일/비번/잊음
- [ ] **Settings 6화면 (15분)** — 응원팀 변경 / 알림 / 약관 / FAQ / 회원탈퇴 / 로그아웃
- [ ] **Common (10분)** — Error 4xx/5xx/network 분기 / Banned / EmptyState 표준 적용

---

### Phase 7 — 인터랙션 + 모션 + 빈 상태 (45분)

**산출물**: 진짜 앱 같은 인터랙션

- [ ] **페이지 전환** — 슬라이드 / 페이드 / 모달 prevent rebuild
- [ ] **햅틱 트리거 15곳** — 출정 3단계 / 예측 제출 / 리워드 교환 / 퀴즈 정답 / 응원팀 변경 / 카드 탭 / 회원탈퇴 confirm 등
- [ ] **로딩 스켈레톤** — list 화면 모두 (퀘스트/예측/리워드/포인트/알림)
- [ ] **빈 상태** — DEmptyState 적용 (필터 결과 0건 / 알림 없음 / 적립 내역 없음)
- [ ] **새로고침** — pull-to-refresh (RefreshIndicator)
- [ ] **키보드 적응** — Signup/Login에서 키보드 올라올 때 스크롤
- [ ] **iOS safe area** — notch / home indicator 모든 화면 처리

---

### Phase 8 — QA + 빌드 + 문서 (30분)

**산출물**: 출시 가능 빌드 + 정리된 repo

- [ ] `flutter analyze` 0 issue
- [ ] iOS simulator + Android emulator 빌드 검증
- [ ] 작은 기기 (iPhone SE) / 큰 기기 (iPad) 화면 깨짐 검수
- [ ] **Release 빌드** 시뮬레이터 시연 (debug overflow 노란줄/Impeller 도배 모두 제거)
- [ ] 모든 화면 새 스크린샷 30+장 (`screenshots/v2/`)
- [ ] **README.md** 완전 갈아엎기 — 빠른 시작 / 아키텍처 / 디자인 시스템 / 시연 GIF
- [ ] `PLAN_V2.md` → `CHANGELOG_V2.md`로 전환 (실제 한 작업 기록)
- [ ] GitHub commit + push (의미 단위 분할 5~7 commit)

---

## 5. 기술 결정

| 항목 | 결정 | 이유 |
|------|------|------|
| 한글 폰트 | **Pretendard** (직접 fonts asset) | google_fonts에 없음, 한국 표준, 깨짐 없음 |
| 영문 액센트 | Anton + Black Ops 한정 | 다른 4종(VT323/JetBrains/Major Mono) 제거 |
| BackdropFilter | **사용 금지** | Impeller validation 도배 |
| 라우터 | StatefulShellRoute (현재) | 5탭 + 출정 FAB 유지 |
| 상태관리 | Riverpod (현재) | 그대로 |
| Mock 데이터 | `assets/data/mock/*.json` + Riverpod provider 표준화 | 현재 const 흩어짐 |
| 이미지 | Wikipedia KBO 로고 + Codex 마스코트 (transparent 적용 완료) | 그대로 |

---

## 6. 작업 분담 전략

| 영역 | 담당 |
|------|------|
| Phase 1 (토큰) | 본인 직접 — 표준 정의 |
| Phase 2 (컴포넌트) | 본인 직접 — 일관성 핵심 |
| Phase 3 (AI 정리) | 본인 + designer 1명 (대규모 sed + 직접 검수) |
| Phase 4 (핵심 화면) | designer 2명 병렬 (홈+시리즈 / 응원팀+팬카드+Sortie) |
| Phase 5 (게임플레이) | designer 1명 |
| Phase 6 (인증/설정/공통) | designer 1명 |
| Phase 7 (인터랙션) | 본인 직접 |
| Phase 8 (QA/빌드/문서) | 본인 직접 |

---

## 7. 리스크 / 대응

| 리스크 | 대응 |
|--------|------|
| Pretendard 다운로드 실패 | 백업으로 Noto Sans KR 유지 (이미 사용 중) |
| BackdropFilter 다시 쓰는 designer | prompt에 강하게 금지 명시 + 검수 |
| 5+시간 작업 토큰 비용 | Phase 단위 commit으로 끊기 가능 |
| 시간 초과 | Phase 1~5 우선, 6~8은 이후 세션 |
| KBO 로고 저작권 | 시안용 명시 (출시 시 라이선스 또는 자체 디자인) |

---

## 8. 산출물 체크리스트

- [ ] 35+개 화면 모두 v2 디자인 적용
- [ ] 폰트 깨짐 0건
- [ ] `flutter analyze` 0 issue
- [ ] iOS/Android release 빌드 OK
- [ ] 새 스크린샷 30+장
- [ ] README v2
- [ ] CHANGELOG_V2.md
- [ ] GitHub 푸시 완료

---

## 9. 진행 시작 신호

이 기획안 OK 사인이 떨어지면 **Phase 1부터 순차 진행**.
중간 점검 알림: Phase 2/4/6/8 끝날 때마다 진행 보고.
사용자가 중간에 다른 우선순위 지정 시 그쪽으로 pivot.
