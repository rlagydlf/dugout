import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_theme.dart';
import '../../app/theme/tokens.dart';
import '../../app/theme/typography.dart';
import '../../core/providers/app_providers.dart';
import '../../shared/widgets/d_effects.dart';
import '../../shared/widgets/d_point_badge.dart';

// ── 퀘스트 데이터 모델 ──────────────────────────────────────────────────────

enum QuestType { daily, gameDay, rivalry, series, stadium }

class _Quest {
  final String id;
  final QuestType type;
  final String title;
  final String description;
  final int reward;
  final int progress;
  final int total;
  final bool completed;

  const _Quest({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.reward,
    required this.progress,
    required this.total,
    required this.completed,
  });
}

const _mockQuests = [
  _Quest(id: '1', type: QuestType.daily, title: '오늘의 출석 체크', description: '앱을 실행해 오늘 출석을 완료하세요', reward: 10, progress: 1, total: 1, completed: true),
  _Quest(id: '2', type: QuestType.gameDay, title: '경기 시작 30분 전 입장', description: '경기 시작 30분 전에 앱에서 출정을 눌러주세요', reward: 30, progress: 0, total: 1, completed: false),
  _Quest(id: '3', type: QuestType.rivalry, title: '라이벌전 예측 1회 참여', description: '라이벌 팀과의 경기에서 예측을 1회 제출하세요', reward: 50, progress: 0, total: 1, completed: false),
  _Quest(id: '4', type: QuestType.daily, title: '예측 3회 참여', description: '오늘 예측 참여를 3번 완료하세요', reward: 40, progress: 1, total: 3, completed: false),
  _Quest(id: '5', type: QuestType.series, title: '3연전 출정 완료', description: '같은 팀과의 3연전 기간 동안 매일 출정하세요', reward: 150, progress: 1, total: 3, completed: false),
  _Quest(id: '6', type: QuestType.stadium, title: '구장 방문 인증', description: '직관 시 구장에서 GPS 인증을 완료하세요', reward: 200, progress: 0, total: 1, completed: false),
  _Quest(id: '7', type: QuestType.daily, title: '퀴즈 1문제 풀기', description: '야구 퀴즈 1문제를 정답 처리하세요', reward: 20, progress: 0, total: 1, completed: false),
  _Quest(id: '8', type: QuestType.gameDay, title: '경기 결과 예측 적중', description: '오늘 경기 결과를 정확히 예측하세요', reward: 100, progress: 0, total: 1, completed: false),
  _Quest(id: '9', type: QuestType.rivalry, title: '라이벌전 응원 댓글 3개', description: '라이벌전 경기 중 응원 댓글을 3개 남기세요', reward: 60, progress: 1, total: 3, completed: false),
  _Quest(id: '10', type: QuestType.series, title: '시리즈 MVP 예측', description: '3연전 MVP를 미리 예측하고 적중시키세요', reward: 300, progress: 0, total: 1, completed: false),
];

final _filterProvider = StateProvider<QuestType?>((ref) => null);

String _questIconAsset(QuestType type) => switch (type) {
  QuestType.daily    => 'assets/images/icons/baseball.png',
  QuestType.gameDay  => 'assets/images/icons/scoreboard.png',
  QuestType.rivalry  => 'assets/images/icons/bolt.png',
  QuestType.series   => 'assets/images/icons/trophy.png',
  QuestType.stadium  => 'assets/images/icons/stadium.png',
};

const _typeLabels = {
  QuestType.daily:   '일일',
  QuestType.gameDay: '경기일',
  QuestType.rivalry: '라이벌전',
  QuestType.series:  '시리즈',
  QuestType.stadium: '직관',
};

// ── 메인 화면 ─────────────────────────────────────────────────────────────

class QuestListScreen extends ConsumerWidget {
  const QuestListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter         = ref.watch(_filterProvider);
    final user           = ref.watch(userProvider);
    final filtered       = filter == null ? _mockQuests : _mockQuests.where((q) => q.type == filter).toList();
    final completedCount = _mockQuests.where((q) => q.completed).length;
    final totalPoints    = _mockQuests.where((q) => q.completed).fold(0, (s, q) => s + q.reward);

    return Scaffold(
      backgroundColor: DTokens.bgDark,
      appBar: AppBar(
        title: Text('오늘의 퀘스트', style: DType.heading(17)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: DTokens.borderDark),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: DTokens.s16),
            child: DPointBadge(point: user.point, compact: true),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _ProgressHeader(
              completed: completedCount,
              total: _mockQuests.length,
              earnedPoints: totalPoints,
            ).animate().fadeIn(duration: 350.ms).slideY(begin: -0.08),
          ),
          SliverToBoxAdapter(
            child: _FilterRow(
              selected: filter,
              onSelect: (t) => ref.read(_filterProvider.notifier).state = t,
            ).animate().fadeIn(duration: 300.ms, delay: 80.ms),
          ),
          if (filtered.isEmpty)
            SliverToBoxAdapter(
              child: _EmptyState(filter: filter)
                  .animate(delay: 120.ms).fadeIn(duration: 280.ms).scale(begin: const Offset(0.92, 0.92)),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(DTokens.s16, DTokens.s8, DTokens.s16, DTokens.s32),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) {
                    final q = filtered[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: DTokens.s12),
                      child: D3DTiltCard(
                        onTap: () => context.push('/quests/${q.id}'),
                        child: _QuestCard(quest: q),
                      )
                          .animate(delay: Duration(milliseconds: 60 * i))
                          .fadeIn(duration: 280.ms)
                          .slideX(begin: 0.04),
                    );
                  },
                  childCount: filtered.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── 진행도 헤더 (D3DTiltCard + DShimmerSweep + DMultiPulseGlow) ───────────

class _ProgressHeader extends StatelessWidget {
  final int completed;
  final int total;
  final int earnedPoints;

  const _ProgressHeader({
    required this.completed,
    required this.total,
    required this.earnedPoints,
  });

  @override
  Widget build(BuildContext context) {
    final team     = context.team;
    final progress = total == 0 ? 0.0 : completed / total;

    return Padding(
      padding: const EdgeInsets.fromLTRB(DTokens.s16, DTokens.s16, DTokens.s16, DTokens.s8),
      child: D3DTiltCard(
        child: DShimmerSweep(
          period: const Duration(milliseconds: 2800),
          highlightOpacity: 0.14,
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(DTokens.r20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  team.primary.withValues(alpha: 0.22),
                  team.secondary.withValues(alpha: 0.14),
                ],
              ),
              border: Border.all(color: team.primary.withValues(alpha: 0.4)),
              boxShadow: [
                BoxShadow(color: team.primary.withValues(alpha: 0.25), blurRadius: 28, offset: const Offset(0, 10)),
              ],
            ),
            child: Stack(
              children: [
                // 스캔라인 오버레이
                Positioned.fill(
                  child: CustomPaint(painter: DScanlinePainter(opacity: 0.012)),
                ),
                // 다이아몬드 그리드
                Positioned.fill(
                  child: CustomPaint(
                    painter: DDiamondGridPainter(team.primary.withValues(alpha: 0.07), step: 32),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(DTokens.s20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // 펄스 글로우 점
                          DMultiPulseGlow(
                            color: team.primary,
                            accentColor: team.accent,
                            size: 12,
                            child: Container(
                              width: 12, height: 12,
                              decoration: BoxDecoration(
                                color: team.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          const SizedBox(width: DTokens.s8),
                          Text('TODAY MISSION', style: DType.label(11, color: team.primary, letterSpacing: 2.0)),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: DTokens.s8, vertical: DTokens.s4),
                            decoration: BoxDecoration(
                              color: DTokens.warning.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(DTokens.rPill),
                              border: Border.all(color: DTokens.warning.withValues(alpha: 0.4)),
                            ),
                            child: Text('+$earnedPoints P 획득', style: DType.mono(12, color: DTokens.warning)),
                          ),
                        ],
                      ),
                      const SizedBox(height: DTokens.s16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '$completed',
                            style: DType.scoreboardDigital(52, color: Colors.white),
                          ),
                          Text(
                            ' / $total',
                            style: DType.scoreboardDigital(28, color: Colors.white54),
                          ),
                          const SizedBox(width: DTokens.s8),
                          Text('완료', style: DType.heading(16, color: Colors.white70)),
                        ],
                      ),
                      const SizedBox(height: DTokens.s12),
                      // 진행 바
                      Stack(
                        children: [
                          Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: DTokens.borderDark,
                              borderRadius: BorderRadius.circular(DTokens.rPill),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: progress,
                            child: Container(
                              height: 8,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [team.primary, team.accent.withValues(alpha: 0.8)]),
                                borderRadius: BorderRadius.circular(DTokens.rPill),
                                boxShadow: [BoxShadow(color: team.primary.withValues(alpha: 0.7), blurRadius: 8)],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: DTokens.s8),
                      Text(
                        '${total - completed}개 남음 · 완료 시 팀 기여도 상승',
                        style: DType.caption(12, color: DTokens.textTertiaryDark),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── 필터 행 ───────────────────────────────────────────────────────────────

class _FilterRow extends StatelessWidget {
  final QuestType? selected;
  final ValueChanged<QuestType?> onSelect;

  const _FilterRow({required this.selected, required this.onSelect});

  static const _labels = {
    null: '전체',
    QuestType.daily: '일일',
    QuestType.gameDay: '경기일',
    QuestType.rivalry: '라이벌전',
    QuestType.series: '시리즈',
    QuestType.stadium: '직관',
  };

  @override
  Widget build(BuildContext context) {
    final team  = context.team;
    final types = [null, ...QuestType.values];

    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: DTokens.s16),
        itemCount: types.length,
        separatorBuilder: (e, s) => const SizedBox(width: DTokens.s8),
        itemBuilder: (ctx, i) {
          final type       = types[i];
          final isSelected = selected == type;
          return GestureDetector(
            onTap: () => onSelect(type),
            child: AnimatedContainer(
              duration: 200.ms,
              padding: const EdgeInsets.symmetric(horizontal: DTokens.s16, vertical: DTokens.s8),
              decoration: BoxDecoration(
                color: isSelected ? team.primary : DTokens.surfaceDark2,
                borderRadius: BorderRadius.circular(DTokens.rPill),
                border: Border.all(
                  color: isSelected ? team.primary : DTokens.borderDark,
                  width: isSelected ? 1.5 : 1.0,
                ),
                boxShadow: isSelected
                    ? [BoxShadow(color: team.primary.withValues(alpha: 0.5), blurRadius: 10, spreadRadius: 1)]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (type != null) ...[
                    Image.asset(
                      _questIconAsset(type),
                      width: 12, height: 12,
                      color: isSelected ? Colors.white : DTokens.textTertiaryDark,
                      errorBuilder: (e, s, t) => const SizedBox.shrink(),
                    ),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    _labels[type]!,
                    style: DType.label(12, color: isSelected ? Colors.white : DTokens.textSecondaryDark),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── 빈 상태 ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final QuestType? filter;
  const _EmptyState({required this.filter});

  @override
  Widget build(BuildContext context) {
    final team = context.team;
    return Padding(
      padding: const EdgeInsets.fromLTRB(DTokens.s32, DTokens.s48, DTokens.s32, DTokens.s32),
      child: Column(
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: team.primary.withValues(alpha: 0.10),
              shape: BoxShape.circle,
              border: Border.all(color: team.primary.withValues(alpha: 0.25)),
            ),
            child: Center(
              child: Image.asset(
                filter != null ? _questIconAsset(filter!) : 'assets/images/icons/baseball.png',
                width: 36, height: 36,
                color: team.primary.withValues(alpha: 0.6),
                errorBuilder: (e, s, t) => Icon(Icons.inbox_rounded, size: 36, color: team.primary.withValues(alpha: 0.6)),
              ),
            ),
          ),
          const SizedBox(height: DTokens.s16),
          Text('해당 유형의 퀘스트가 없습니다', style: DType.heading(16, color: DTokens.textSecondaryDark)),
          const SizedBox(height: DTokens.s8),
          Text('다른 필터를 선택해보세요', style: DType.caption(14, color: DTokens.textTertiaryDark)),
        ],
      ),
    );
  }
}

// ── 퀘스트 카드 (3D Tilt 래퍼 없이 — 상위에서 D3DTiltCard로 감쌈) ────────

class _QuestCard extends StatelessWidget {
  final _Quest quest;

  const _QuestCard({required this.quest});

  @override
  Widget build(BuildContext context) {
    final team     = context.team;
    final isDone   = quest.completed;
    final progress = quest.total == 0 ? 0.0 : quest.progress / quest.total;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(DTokens.r20),
        color: DTokens.surfaceDark,
        border: Border.all(
          color: isDone
              ? DTokens.borderDark
              : team.primary.withValues(alpha: 0.4),
          width: isDone ? 1.0 : 1.5,
        ),
        boxShadow: isDone
            ? null
            : [BoxShadow(color: team.primary.withValues(alpha: 0.15), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Stack(
        children: [
          // 좌측 팀컬러 스트라이프
          if (!isDone)
            Positioned(
              left: 0, top: 0, bottom: 0,
              child: Container(
                width: 3,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [team.primary, team.accent.withValues(alpha: 0.6)],
                  ),
                  boxShadow: [BoxShadow(color: team.primary.withValues(alpha: 0.8), blurRadius: 6)],
                ),
              ),
            ),
          Opacity(
            opacity: isDone ? 0.55 : 1.0,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(DTokens.s16, DTokens.s14, DTokens.s16, DTokens.s14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // 유형 배지
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: DTokens.s8, vertical: DTokens.s4),
                        decoration: BoxDecoration(
                          color: isDone ? DTokens.borderDark : team.primary.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(DTokens.rPill),
                          border: Border.all(
                            color: isDone ? Colors.transparent : team.primary.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              _questIconAsset(quest.type),
                              width: 11, height: 11,
                              color: isDone ? DTokens.textTertiaryDark : team.primary,
                              errorBuilder: (e, s, t) => Icon(Icons.sports_baseball_rounded, size: 11,
                                  color: isDone ? DTokens.textTertiaryDark : team.primary),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              _typeLabels[quest.type]!,
                              style: DType.label(11, color: isDone ? DTokens.textTertiaryDark : team.primary),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      if (isDone)
                        Row(
                          children: [
                            const Icon(Icons.check_circle_rounded, size: 15, color: DTokens.success),
                            const SizedBox(width: 4),
                            Text('완료', style: DType.label(11, color: DTokens.success)),
                          ],
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: DTokens.s8, vertical: DTokens.s4),
                          decoration: BoxDecoration(
                            color: DTokens.warning.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(DTokens.rPill),
                            border: Border.all(color: DTokens.warning.withValues(alpha: 0.3)),
                          ),
                          child: Text('+${quest.reward} P', style: DType.mono(12, color: DTokens.warning, weight: FontWeight.w700)),
                        ),
                    ],
                  ),
                  const SizedBox(height: DTokens.s8),
                  Text(
                    quest.title,
                    style: DType.body(15, FontWeight.w700).copyWith(
                      color: isDone ? DTokens.textTertiaryDark : DTokens.textPrimaryDark,
                      decoration: isDone ? TextDecoration.lineThrough : null,
                      decorationColor: DTokens.textTertiaryDark,
                    ),
                  ),
                  const SizedBox(height: DTokens.s4),
                  Text(quest.description, style: DType.caption(13, color: DTokens.textTertiaryDark)),
                  if (!isDone && quest.total > 1) ...[
                    const SizedBox(height: DTokens.s12),
                    Row(
                      children: [
                        Expanded(
                          child: Stack(
                            children: [
                              Container(height: 6, decoration: BoxDecoration(color: DTokens.borderDark, borderRadius: BorderRadius.circular(DTokens.rPill))),
                              FractionallySizedBox(
                                widthFactor: progress,
                                child: Container(
                                  height: 6,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(colors: [team.primary, team.accent.withValues(alpha: 0.8)]),
                                    borderRadius: BorderRadius.circular(DTokens.rPill),
                                    boxShadow: [BoxShadow(color: team.primary.withValues(alpha: 0.6), blurRadius: 6)],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: DTokens.s8),
                        Text(
                          '${quest.progress}/${quest.total}',
                          style: DType.scoreboardDigital(14, color: team.primary),
                        ),
                      ],
                    ),
                  ],
                  if (!isDone && quest.total == 1) ...[
                    const SizedBox(height: DTokens.s8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('수행하기', style: DType.label(12, color: team.primary)),
                        const SizedBox(width: DTokens.s4),
                        Icon(Icons.arrow_forward_ios_rounded, size: 11, color: team.primary),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
