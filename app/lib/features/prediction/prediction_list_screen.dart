import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_theme.dart';
import '../../app/theme/team_theme.dart';
import '../../app/theme/tokens.dart';
import '../../app/theme/typography.dart';
import '../../core/providers/app_providers.dart';
import '../../shared/widgets/d_effects.dart';
import '../../shared/widgets/d_glass_panel.dart';
import '../../shared/widgets/d_point_badge.dart';

// ── 데이터 모델 ───────────────────────────────────────────────────────────

enum PredCategory { winner, keyPlayer, longHit, rivalry }

class _Prediction {
  final String id;
  final PredCategory category;
  final String title;
  final String homeTeamId;
  final String awayTeamId;
  final double odds;
  final String deadline;
  final int minutesLeft;
  final bool freeEntry;
  final int participants;

  const _Prediction({
    required this.id,
    required this.category,
    required this.title,
    required this.homeTeamId,
    required this.awayTeamId,
    required this.odds,
    required this.deadline,
    required this.minutesLeft,
    required this.freeEntry,
    required this.participants,
  });
}

const _mockPredictions = [
  _Prediction(id: '1', category: PredCategory.winner, title: '오늘의 승리팀 예측', homeTeamId: 'lg', awayTeamId: 'doosan', odds: 2.0, deadline: '18:00 마감', minutesLeft: 47, freeEntry: false, participants: 3842),
  _Prediction(id: '2', category: PredCategory.keyPlayer, title: '오늘 활약할 키플레이어', homeTeamId: 'ssg', awayTeamId: 'kia', odds: 4.5, deadline: '18:30 마감', minutesLeft: 77, freeEntry: true, participants: 1290),
  _Prediction(id: '3', category: PredCategory.longHit, title: '오늘 홈런/장타 선수 예측', homeTeamId: 'hanwha', awayTeamId: 'samsung', odds: 7.0, deadline: '경기 시작까지', minutesLeft: 120, freeEntry: false, participants: 672),
  _Prediction(id: '4', category: PredCategory.rivalry, title: '라이벌전 최다 득점 이닝', homeTeamId: 'lg', awayTeamId: 'doosan', odds: 3.5, deadline: '19:00 마감', minutesLeft: 107, freeEntry: false, participants: 2140),
  _Prediction(id: '5', category: PredCategory.winner, title: '키움 vs NC 승리팀', homeTeamId: 'kiwoom', awayTeamId: 'nc', odds: 2.0, deadline: '17:30 마감', minutesLeft: 17, freeEntry: true, participants: 905),
  _Prediction(id: '6', category: PredCategory.rivalry, title: '잠실 더비 선취점 팀', homeTeamId: 'lg', awayTeamId: 'doosan', odds: 1.8, deadline: '18:00 마감', minutesLeft: 47, freeEntry: false, participants: 4510),
];

final _predFilterProvider = StateProvider<PredCategory?>((ref) => null);

const _catLabels = {
  PredCategory.winner: '승리팀',
  PredCategory.keyPlayer: '키플레이어',
  PredCategory.longHit: '장타',
  PredCategory.rivalry: '라이벌전',
};

const _catIconAssets = {
  PredCategory.winner: 'assets/images/icons/trophy.png',
  PredCategory.keyPlayer: 'assets/images/icons/helmet.png',
  PredCategory.longHit: 'assets/images/icons/bats.png',
  PredCategory.rivalry: 'assets/images/icons/bolt.png',
};

// ── 화면 ──────────────────────────────────────────────────────────────────

class PredictionListScreen extends ConsumerWidget {
  const PredictionListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user   = ref.watch(userProvider);
    final filter = ref.watch(_predFilterProvider);

    final filtered = filter == null
        ? _mockPredictions
        : _mockPredictions.where((p) => p.category == filter).toList();

    return Scaffold(
      backgroundColor: DTokens.bgDark,
      appBar: AppBar(
        title: Text('예측', style: DType.heading(17)),
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
            child: _StatusSummary(
              activeCount: _mockPredictions.length,
              pendingCount: 2,
            ).animate().fadeIn(duration: 350.ms).slideY(begin: -0.08),
          ),
          SliverToBoxAdapter(
            child: _CategoryFilter(
              selected: filter,
              onSelect: (c) => ref.read(_predFilterProvider.notifier).state = c,
            ).animate().fadeIn(duration: 300.ms, delay: 80.ms),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(DTokens.s16, DTokens.s8, DTokens.s16, DTokens.s12),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) {
                  final p = filtered[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: DTokens.s12),
                    child: D3DTiltCard(
                      onTap: () => context.push('/predictions/${p.id}'),
                      child: _PredictionCard(prediction: p),
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
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(DTokens.s16, DTokens.s4, DTokens.s16, DTokens.s32),
              child: _MyHistoryCta()
                  .animate(delay: 400.ms).fadeIn(duration: 300.ms),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 상태 요약 (DShimmerSweep) ─────────────────────────────────────────────

class _StatusSummary extends StatelessWidget {
  final int activeCount;
  final int pendingCount;

  const _StatusSummary({required this.activeCount, required this.pendingCount});

  @override
  Widget build(BuildContext context) {
    final team = context.team;
    return Padding(
      padding: const EdgeInsets.fromLTRB(DTokens.s16, DTokens.s16, DTokens.s16, DTokens.s8),
      child: Row(
        children: [
          Expanded(
            child: _SummaryTile(
              iconAsset: 'assets/images/icons/baseball.png',
              color: team.primary,
              label: '진행 중 예측',
              value: '$activeCount개',
            ),
          ),
          const SizedBox(width: DTokens.s12),
          Expanded(
            child: _SummaryTile(
              iconAsset: 'assets/images/icons/scoreboard.png',
              color: DTokens.warning,
              label: '정산 대기',
              value: '$pendingCount개',
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String iconAsset;
  final Color color;
  final String label;
  final String value;

  const _SummaryTile({
    required this.iconAsset,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return DShimmerSweep(
      period: const Duration(milliseconds: 3500),
      highlightOpacity: 0.10,
      child: DGlassPanel(
        padding: const EdgeInsets.symmetric(horizontal: DTokens.s16, vertical: DTokens.s14),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Center(
                child: Image.asset(iconAsset, width: 18, height: 18, color: color,
                    errorBuilder: (e, s, t) => Icon(Icons.sports_baseball_rounded, size: 18, color: color)),
              ),
            ),
            const SizedBox(width: DTokens.s12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: DType.caption(12, color: DTokens.textSecondaryDark)),
                Text(value, style: DType.scoreboardDigital(22, color: color)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── 카테고리 필터 ─────────────────────────────────────────────────────────

class _CategoryFilter extends StatelessWidget {
  final PredCategory? selected;
  final ValueChanged<PredCategory?> onSelect;

  const _CategoryFilter({required this.selected, required this.onSelect});

  static const _labels = {
    null: '전체',
    PredCategory.winner: '승리팀',
    PredCategory.keyPlayer: '키플레이어',
    PredCategory.longHit: '장타',
    PredCategory.rivalry: '라이벌전',
  };

  @override
  Widget build(BuildContext context) {
    final team  = context.team;
    final types = [null, ...PredCategory.values];

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
                    ? [BoxShadow(color: team.primary.withValues(alpha: 0.5), blurRadius: 10)]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (type != null) ...[
                    Image.asset(_catIconAssets[type]!, width: 12, height: 12,
                        color: isSelected ? Colors.white : DTokens.textTertiaryDark,
                        errorBuilder: (e, s, t) => const SizedBox.shrink()),
                    const SizedBox(width: 4),
                  ],
                  Text(_labels[type]!, style: DType.label(12, color: isSelected ? Colors.white : DTokens.textSecondaryDark)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── 예측 카드 (D3DTiltCard 래퍼 없이 — 상위에서 감쌈) ────────────────────

class _PredictionCard extends StatelessWidget {
  final _Prediction prediction;

  const _PredictionCard({required this.prediction});

  @override
  Widget build(BuildContext context) {
    final team     = context.team;
    final isUrgent = prediction.minutesLeft <= 30;
    final home     = TeamThemes.byId(prediction.homeTeamId);
    final away     = TeamThemes.byId(prediction.awayTeamId);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: DTokens.surfaceDark,
        borderRadius: BorderRadius.circular(DTokens.r20),
        border: Border.all(color: team.primary.withValues(alpha: 0.35)),
        boxShadow: [BoxShadow(color: team.primary.withValues(alpha: 0.10), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          // 팀컬러 이중 스트라이프 헤더
          SizedBox(
            height: 5,
            child: Row(
              children: [
                Expanded(child: Container(color: home.primary)),
                Expanded(child: Container(color: away.primary)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(DTokens.s16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 배지 행
                Row(
                  children: [
                    _CatBadge(cat: prediction.category),
                    const SizedBox(width: DTokens.s8),
                    if (prediction.freeEntry)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: DTokens.s8, vertical: 3),
                        decoration: BoxDecoration(
                          color: DTokens.success.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(DTokens.rPill),
                          border: Border.all(color: DTokens.success.withValues(alpha: 0.3)),
                        ),
                        child: Text('무료', style: DType.label(11, color: DTokens.success)),
                      ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: DTokens.s8, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [team.primary, Color.lerp(team.primary, team.secondary, 0.5)!]),
                        borderRadius: BorderRadius.circular(DTokens.rPill),
                        boxShadow: [BoxShadow(color: team.primary.withValues(alpha: 0.5), blurRadius: 8)],
                      ),
                      child: Text('×${prediction.odds.toStringAsFixed(1)}',
                          style: DType.scoreboardDigital(15, color: Colors.white)),
                    ),
                  ],
                ),
                const SizedBox(height: DTokens.s12),
                Text(prediction.title, style: DType.body(14, FontWeight.w700).copyWith(color: DTokens.textPrimaryDark)),
                const SizedBox(height: DTokens.s12),
                // 팀 매치업 미니
                Row(
                  children: [
                    Expanded(child: _MiniTeamSide(team: home, isHome: true)),
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [home.primary.withValues(alpha: 0.3), away.primary.withValues(alpha: 0.3)],
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(color: DTokens.borderDark),
                      ),
                      child: Center(child: Text('VS', style: DType.impact(10, color: Colors.white70, letterSpacing: 1))),
                    ),
                    Expanded(child: _MiniTeamSide(team: away, isHome: false)),
                  ],
                ),
                const SizedBox(height: DTokens.s12),
                // 푸터
                Row(
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 13,
                      color: isUrgent ? DTokens.danger : DTokens.textTertiaryDark,
                    ),
                    const SizedBox(width: 4),
                    Text(prediction.deadline,
                        style: DType.mono(11, color: isUrgent ? DTokens.danger : DTokens.textTertiaryDark,
                            weight: isUrgent ? FontWeight.w700 : FontWeight.w400)),
                    if (isUrgent) ...[
                      const SizedBox(width: DTokens.s4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: DTokens.danger.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(DTokens.rPill),
                          border: Border.all(color: DTokens.danger.withValues(alpha: 0.35)),
                        ),
                        child: Text('마감 임박', style: DType.label(10, color: DTokens.danger)),
                      ).animate(onPlay: (c) => c.repeat(reverse: true)).fade(begin: 0.6, end: 1.0, duration: 700.ms),
                    ],
                    const Spacer(),
                    Icon(Icons.people_rounded, size: 13, color: DTokens.textTertiaryDark),
                    const SizedBox(width: 3),
                    Text('${_fmtCount(prediction.participants)}명',
                        style: DType.label(11, color: DTokens.textTertiaryDark)),
                    const SizedBox(width: DTokens.s12),
                    Text('참여 →', style: DType.label(12, color: team.primary)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _fmtCount(int v) {
    if (v < 1000) return '$v';
    return '${(v / 1000).toStringAsFixed(1)}k';
  }
}

class _MiniTeamSide extends StatelessWidget {
  final TeamTheme team;
  final bool isHome;
  const _MiniTeamSide({required this.team, required this.isHome});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          team.crestAsset, width: 44, height: 44, fit: BoxFit.contain,
          errorBuilder: (e, s, t) => Container(
            width: 44, height: 44,
            decoration: BoxDecoration(shape: BoxShape.circle,
                gradient: LinearGradient(colors: [team.primary, team.secondary])),
            alignment: Alignment.center,
            child: Text(team.teamShortName.substring(0, 1),
                style: DType.impact(16, color: team.accent)),
          ),
        ),
        const SizedBox(height: 4),
        Text(team.teamShortName, style: DType.impact(14, color: Colors.white, letterSpacing: 1)),
        Text(isHome ? 'HOME' : 'AWAY', style: DType.micro(9, color: Colors.white54)),
      ],
    );
  }
}

class _CatBadge extends StatelessWidget {
  final PredCategory cat;
  const _CatBadge({required this.cat});

  @override
  Widget build(BuildContext context) {
    final team = context.team;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: DTokens.s8, vertical: 3),
      decoration: BoxDecoration(
        color: team.primary.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(DTokens.rPill),
        border: Border.all(color: team.primary.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(_catIconAssets[cat]!, width: 10, height: 10, color: team.primary,
              errorBuilder: (e, s, t) => const SizedBox.shrink()),
          const SizedBox(width: 3),
          Text(_catLabels[cat]!, style: DType.label(11, color: team.primary)),
        ],
      ),
    );
  }
}

// ── 내 예측 내역 CTA ──────────────────────────────────────────────────────

class _MyHistoryCta extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final team = context.team;
    return DGlassPanel(
      onTap: () {},
      padding: const EdgeInsets.all(DTokens.s16),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: team.primary.withValues(alpha: 0.15), shape: BoxShape.circle),
            child: Center(
              child: Image.asset('assets/images/icons/scoreboard.png', width: 22, height: 22, color: team.primary,
                  errorBuilder: (e, s, t) => Icon(Icons.history_rounded, color: team.primary, size: 22)),
            ),
          ),
          const SizedBox(width: DTokens.s16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('내 예측 내역', style: DType.body(15, FontWeight.w700).copyWith(color: DTokens.textPrimaryDark)),
                Text('참여한 예측 결과 및 정산 내역 확인', style: DType.caption(13, color: DTokens.textSecondaryDark)),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded, size: 16, color: DTokens.textTertiaryDark),
        ],
      ),
    );
  }
}
