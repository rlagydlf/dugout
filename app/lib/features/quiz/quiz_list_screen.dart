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

// ── 데이터 모델 ───────────────────────────────────────────────────────────

enum QuizCategory { history, rules, players }
enum QuizDifficulty { easy, medium, hard }

class _Quiz {
  final String id;
  final QuizCategory category;
  final QuizDifficulty difficulty;
  final String title;
  final int reward;
  final int timeLimitSecs;
  final bool solved;

  const _Quiz({
    required this.id, required this.category, required this.difficulty,
    required this.title, required this.reward, required this.timeLimitSecs, required this.solved,
  });
}

const _mockQuizzes = [
  _Quiz(id: 'q1', category: QuizCategory.history, difficulty: QuizDifficulty.easy, title: 'KBO 리그가 처음 출범한 연도는?', reward: 20, timeLimitSecs: 30, solved: false),
  _Quiz(id: 'q2', category: QuizCategory.players, difficulty: QuizDifficulty.medium, title: '통산 최다 홈런 기록을 보유한 KBO 선수는?', reward: 40, timeLimitSecs: 45, solved: false),
  _Quiz(id: 'q3', category: QuizCategory.rules, difficulty: QuizDifficulty.easy, title: '타자가 삼진 아웃되는 경우 몇 스트라이크인가?', reward: 15, timeLimitSecs: 20, solved: true),
  _Quiz(id: 'q4', category: QuizCategory.history, difficulty: QuizDifficulty.hard, title: '잠실구장에서 최초로 노히트노런을 달성한 투수는?', reward: 80, timeLimitSecs: 60, solved: false),
  _Quiz(id: 'q5', category: QuizCategory.rules, difficulty: QuizDifficulty.medium, title: '인필드 플라이 룰이 적용되는 조건은?', reward: 35, timeLimitSecs: 45, solved: false),
];

final _quizFilterProvider = StateProvider<QuizCategory?>((ref) => null);

const _catLabels = {
  QuizCategory.history: '역사',
  QuizCategory.rules:   '규칙',
  QuizCategory.players: '선수',
};

const _catIconAssets = {
  QuizCategory.history: 'assets/images/icons/trophy.png',
  QuizCategory.rules:   'assets/images/icons/plate.png',
  QuizCategory.players: 'assets/images/icons/helmet.png',
};

const _diffColors = {
  QuizDifficulty.easy:   DTokens.success,
  QuizDifficulty.medium: DTokens.warning,
  QuizDifficulty.hard:   DTokens.danger,
};

const _diffLabels = {
  QuizDifficulty.easy:   '쉬움',
  QuizDifficulty.medium: '보통',
  QuizDifficulty.hard:   '어려움',
};

const _diffStars = {
  QuizDifficulty.easy:   1,
  QuizDifficulty.medium: 2,
  QuizDifficulty.hard:   3,
};

// ── 화면 ──────────────────────────────────────────────────────────────────

class QuizListScreen extends ConsumerWidget {
  const QuizListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter     = ref.watch(_quizFilterProvider);
    final user       = ref.watch(userProvider);
    final filtered   = filter == null ? _mockQuizzes : _mockQuizzes.where((q) => q.category == filter).toList();
    final solvedCount = _mockQuizzes.where((q) => q.solved).length;

    return Scaffold(
      backgroundColor: DTokens.bgDark,
      appBar: AppBar(
        title: Text('야구 퀴즈', style: DType.heading(17)),
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
            child: _QuizBanner(solvedCount: solvedCount, totalCount: _mockQuizzes.length)
                .animate().fadeIn(duration: 350.ms).slideY(begin: -0.08),
          ),
          SliverToBoxAdapter(
            child: _CategoryChips(
              selected: filter,
              onSelect: (c) => ref.read(_quizFilterProvider.notifier).state = c,
            ).animate().fadeIn(duration: 300.ms, delay: 80.ms),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(DTokens.s16, DTokens.s8, DTokens.s16, DTokens.s32),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) {
                  final q = filtered[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: DTokens.s12),
                    child: D3DTiltCard(
                      onTap: q.solved ? null : () => context.push('/quiz/${q.id}'),
                      child: _QuizCard(quiz: q),
                    )
                        .animate(delay: Duration(milliseconds: 60 * i))
                        .fadeIn(duration: 270.ms)
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

// ── 배너 (DDiamondGridPainter + DMultiPulseGlow + DShimmerSweep) ──────────

class _QuizBanner extends StatelessWidget {
  final int solvedCount;
  final int totalCount;
  const _QuizBanner({required this.solvedCount, required this.totalCount});

  @override
  Widget build(BuildContext context) {
    final team = context.team;
    return Padding(
      padding: const EdgeInsets.fromLTRB(DTokens.s16, DTokens.s16, DTokens.s16, DTokens.s8),
      child: DShimmerSweep(
        period: const Duration(milliseconds: 3200),
        highlightOpacity: 0.14,
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(DTokens.r20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [team.primary, Color.lerp(team.primary, team.secondary, 0.55)!],
            ),
            boxShadow: [BoxShadow(color: team.primary.withValues(alpha: 0.45), blurRadius: 32, offset: const Offset(0, 12))],
          ),
          child: Stack(
            children: [
              // 다이아몬드 그리드
              Positioned.fill(
                child: CustomPaint(
                  painter: DDiamondGridPainter(Colors.white.withValues(alpha: 0.07), step: 36),
                ),
              ),
              // 스캔라인
              Positioned.fill(
                child: CustomPaint(painter: DScanlinePainter(opacity: 0.013)),
              ),
              // 야구 아이콘 배경 대형
              Positioned(
                right: -24, bottom: -24,
                child: Image.asset('assets/images/icons/baseball.png', width: 140, height: 140,
                    color: Colors.white.withValues(alpha: 0.10),
                    errorBuilder: (e, s, t) => const SizedBox.shrink()),
              ),
              Padding(
                padding: const EdgeInsets.all(DTokens.s20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        DMultiPulseGlow(
                          color: Colors.white,
                          accentColor: team.accent,
                          size: 10,
                          child: Container(
                            width: 10, height: 10,
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          ),
                        ),
                        const SizedBox(width: DTokens.s8),
                        Text('QUIZ CHALLENGE', style: DType.label(11, color: Colors.white70, letterSpacing: 2.0)),
                      ],
                    ),
                    const SizedBox(height: DTokens.s12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text('$solvedCount', style: DType.scoreboardDigital(52, color: Colors.white)),
                        Text(' / $totalCount', style: DType.scoreboardDigital(28, color: Colors.white60)),
                        const SizedBox(width: DTokens.s8),
                        Text('풀이 완료', style: DType.body(16, FontWeight.w700).copyWith(color: Colors.white70)),
                      ],
                    ),
                    const SizedBox(height: DTokens.s8),
                    Text('정답을 맞히면 포인트가 자동 적립됩니다', style: DType.caption(13, color: Colors.white.withValues(alpha: 0.72))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── 카테고리 필터 ─────────────────────────────────────────────────────────

class _CategoryChips extends StatelessWidget {
  final QuizCategory? selected;
  final ValueChanged<QuizCategory?> onSelect;

  const _CategoryChips({required this.selected, required this.onSelect});

  static const _labels = {
    null: '전체',
    QuizCategory.history: '역사',
    QuizCategory.rules:   '규칙',
    QuizCategory.players: '선수',
  };

  @override
  Widget build(BuildContext context) {
    final team  = context.team;
    final types = [null, ...QuizCategory.values];
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
                        errorBuilder: (e, s, t) => Icon(Icons.quiz_rounded, size: 12,
                            color: isSelected ? Colors.white : DTokens.textTertiaryDark)),
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

// ── 퀴즈 카드 ─────────────────────────────────────────────────────────────

class _QuizCard extends StatelessWidget {
  final _Quiz quiz;
  const _QuizCard({required this.quiz});

  @override
  Widget build(BuildContext context) {
    final team      = context.team;
    final diffColor = _diffColors[quiz.difficulty]!;
    final stars     = _diffStars[quiz.difficulty]!;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: DTokens.surfaceDark,
        borderRadius: BorderRadius.circular(DTokens.r20),
        border: Border.all(
          color: quiz.solved ? DTokens.borderDark : team.primary.withValues(alpha: 0.4),
          width: quiz.solved ? 1.0 : 1.5,
        ),
        boxShadow: quiz.solved
            ? null
            : [BoxShadow(color: team.primary.withValues(alpha: 0.12), blurRadius: 14, offset: const Offset(0, 4))],
      ),
      child: Stack(
        children: [
          // 상단 난이도 컬러 라인
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              height: 3,
              decoration: BoxDecoration(
                color: quiz.solved ? DTokens.borderDark : diffColor,
                boxShadow: quiz.solved ? null : [BoxShadow(color: diffColor.withValues(alpha: 0.7), blurRadius: 6)],
              ),
            ),
          ),
          Opacity(
            opacity: quiz.solved ? 0.5 : 1.0,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(DTokens.s16, DTokens.s16, DTokens.s16, DTokens.s14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // 카테고리 배지
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: DTokens.s8, vertical: DTokens.s4),
                        decoration: BoxDecoration(
                          color: team.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(DTokens.rPill),
                          border: Border.all(color: team.primary.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(_catIconAssets[quiz.category]!, width: 11, height: 11, color: team.primary,
                                errorBuilder: (e, s, t) => Icon(Icons.quiz_rounded, size: 11, color: team.primary)),
                            const SizedBox(width: 3),
                            Text(_catLabels[quiz.category]!, style: DType.label(11, color: team.primary)),
                          ],
                        ),
                      ),
                      const SizedBox(width: DTokens.s8),
                      // 난이도 별
                      Row(
                        children: List.generate(3, (i) => Icon(
                          i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
                          size: 14,
                          color: i < stars ? diffColor : DTokens.borderDark,
                        )),
                      ),
                      const SizedBox(width: DTokens.s4),
                      Text(_diffLabels[quiz.difficulty]!, style: DType.label(11, color: diffColor)),
                      const Spacer(),
                      if (quiz.solved)
                        Row(
                          children: [
                            const Icon(Icons.check_circle_rounded, size: 14, color: DTokens.success),
                            const SizedBox(width: 3),
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
                          child: Text('+${quiz.reward} P', style: DType.mono(11, color: DTokens.warning, weight: FontWeight.w700)),
                        ),
                    ],
                  ),
                  const SizedBox(height: DTokens.s12),
                  Text(
                    quiz.title,
                    style: DType.body(15, FontWeight.w700).copyWith(
                      color: quiz.solved ? DTokens.textTertiaryDark : DTokens.textPrimaryDark,
                      decoration: quiz.solved ? TextDecoration.lineThrough : null,
                      decorationColor: DTokens.textTertiaryDark,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: DTokens.s12),
                  Row(
                    children: [
                      Icon(Icons.timer_outlined, size: 13, color: DTokens.textTertiaryDark),
                      const SizedBox(width: 4),
                      Text('제한 ${quiz.timeLimitSecs}초', style: DType.mono(12, color: DTokens.textTertiaryDark, weight: FontWeight.w400)),
                      const Spacer(),
                      if (!quiz.solved) ...[
                        Text('풀기', style: DType.label(12, color: team.primary)),
                        const SizedBox(width: 3),
                        Icon(Icons.arrow_forward_ios_rounded, size: 11, color: team.primary),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
