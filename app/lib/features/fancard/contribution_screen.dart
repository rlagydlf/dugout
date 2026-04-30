import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_theme.dart';
import '../../app/theme/tokens.dart';
import '../../app/theme/typography.dart';
import '../../core/providers/app_providers.dart';
import '../../shared/widgets/d_glass_panel.dart';
import '../../shared/widgets/d_scoreboard.dart';
import '../../shared/widgets/d_team_backdrop.dart';

// ── mock breakdown ────────────────────────────────────────────────────────────

class _BreakdownItem {
  final String label;
  final String labelEn;
  final int score;
  final double weight;
  final String assetPath;
  final IconData fallbackIcon;
  final Color accent;
  const _BreakdownItem({
    required this.label,
    required this.labelEn,
    required this.score,
    required this.weight,
    required this.assetPath,
    required this.fallbackIcon,
    required this.accent,
  });
}

const _breakdowns = [
  _BreakdownItem(
    label: '출정',
    labelEn: 'SORTIE',
    score: 1900,
    weight: 0.45,
    assetPath: 'assets/images/icons/bolt.png',
    fallbackIcon: Icons.rocket_launch_rounded,
    accent: DTokens.info,
  ),
  _BreakdownItem(
    label: '퀘스트',
    labelEn: 'QUEST',
    score: 880,
    weight: 0.21,
    assetPath: 'assets/images/icons/bats.png',
    fallbackIcon: Icons.assignment_turned_in_rounded,
    accent: DTokens.warning,
  ),
  _BreakdownItem(
    label: '예측',
    labelEn: 'PREDICTION',
    score: 1100,
    weight: 0.26,
    assetPath: 'assets/images/icons/baseball.png',
    fallbackIcon: Icons.psychology_rounded,
    accent: DTokens.success,
  ),
  _BreakdownItem(
    label: '체크인',
    labelEn: 'CHECK-IN',
    score: 400,
    weight: 0.08,
    assetPath: 'assets/images/icons/stadium.png',
    fallbackIcon: Icons.location_on_rounded,
    accent: Color(0xFF00C4B4),
  ),
];

// ── screen ────────────────────────────────────────────────────────────────────

class ContributionScreen extends ConsumerWidget {
  const ContributionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final team = context.team;
    final user = ref.watch(userProvider);
    final total = user.contribution;

    return Scaffold(
      backgroundColor: DTokens.bgDark,
      appBar: AppBar(
        backgroundColor: DTokens.bgDark,
        elevation: 0,
        title: Row(
          children: [
            Image.asset(
              'assets/images/icons/trophy.png',
              width: 20,
              height: 20,
              errorBuilder: (e, s, t) => Icon(
                Icons.emoji_events_rounded,
                size: 20,
                color: team.primary,
              ),
            ),
            const SizedBox(width: DTokens.s8),
            Text('팀 기여도',
                style: DType.heading(17, color: Colors.white)),
          ],
        ),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // ── 큰 기여도 히어로 (DTeamBackdrop)
          Padding(
            padding: const EdgeInsets.fromLTRB(
                DTokens.s16, DTokens.s8, DTokens.s16, 0),
            child: DTeamBackdrop(
              height: 240,
              showMascot: true,
              showPattern: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MY CONTRIBUTION',
                    style: DType.label(10,
                        color: Colors.white.withValues(alpha: 0.6)),
                  ),
                  const SizedBox(height: DTokens.s8),
                  Text(
                    '나의 기여도',
                    style: DType.heading(20, color: Colors.white),
                  ),
                  const Spacer(),

                  // 큰 숫자 — VT323 scoreboardDigital 64pt
                  _AnimatedDigitalCounter(
                    target: total,
                    color: team.accent,
                  ).animate().fadeIn(duration: 500.ms),

                  const SizedBox(height: DTokens.s12),

                  // 팀 내 순위 배지
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: DTokens.s12, vertical: DTokens.s8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      borderRadius:
                          BorderRadius.circular(DTokens.rPill),
                      border: Border.all(
                        color: team.accent.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/icons/trophy.png',
                          width: 16,
                          height: 16,
                          errorBuilder: (e, s, t) => Icon(
                            Icons.emoji_events_rounded,
                            size: 16,
                            color: team.accent,
                          ),
                        ),
                        const SizedBox(width: DTokens.s8),
                        Text(
                          '팀 내 상위 3.2%  ·  42위',
                          style: DType.badge(12,
                              color: team.accent),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 50.ms),
          ),

          const SizedBox(height: DTokens.s24),

          // ── 4개 DScoreboard 요약 패널
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: DTokens.s16),
            child: DGlassPanel(
              teamBorder: true,
              padding: const EdgeInsets.symmetric(
                  horizontal: DTokens.s12, vertical: DTokens.s16),
              child: Row(
                children: _breakdowns.map((item) {
                  final isLast = item == _breakdowns.last;
                  return Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: DScoreboard(
                            value: '${item.score}',
                            label: item.labelEn,
                            accent: item.accent,
                            valueSize: 20,
                            align: TextAlign.center,
                          ),
                        ),
                        if (!isLast)
                          Container(
                            width: 1,
                            height: 36,
                            color: DTokens.borderDark,
                          ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ).animate().fadeIn(delay: 150.ms),
          ),

          const SizedBox(height: DTokens.s24),

          // ── breakdown 섹션 헤더
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: DTokens.s16),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/icons/scoreboard.png',
                  width: 16,
                  height: 16,
                  errorBuilder: (e, s, t) => Icon(
                    Icons.bar_chart_rounded,
                    size: 16,
                    color: team.primary,
                  ),
                ),
                const SizedBox(width: DTokens.s8),
                Text(
                  '점수 구성',
                  style: DType.heading(16, color: Colors.white),
                ),
              ],
            ),
          ),

          const SizedBox(height: DTokens.s12),

          // ── 각 breakdown 카드
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: DTokens.s16),
            child: Column(
              children: _breakdowns.asMap().entries.map((e) {
                final item = e.value;
                return Padding(
                  padding:
                      const EdgeInsets.only(bottom: DTokens.s12),
                  child: _BreakdownCard(
                    item: item,
                    teamColor: team.primary,
                  ).animate().fadeIn(
                      delay:
                          Duration(milliseconds: 80 * e.key + 200))
                      .slideX(begin: 0.05),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: DTokens.s8),

          // ── 면책 고지 (micro)
          Padding(
            padding: EdgeInsets.fromLTRB(
              DTokens.s16,
              0,
              DTokens.s16,
              MediaQuery.of(context).padding.bottom + DTokens.s24,
            ),
            child: DGlassPanel(
              padding: const EdgeInsets.all(DTokens.s12),
              radius: DTokens.r12,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 14,
                    color: DTokens.textTertiaryDark,
                  ),
                  const SizedBox(width: DTokens.s8),
                  Expanded(
                    child: Text(
                      '팀 기여도는 더그아웃 인앱 활동 기반의 메트릭으로, 구단 공식 지표가 아닙니다. 순위는 매일 자정 갱신됩니다.',
                      style: DType.label(12,
                          color: DTokens.textTertiaryDark),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 500.ms),
          ),
        ],
      ),
    );
  }
}

// ── animated digital counter ──────────────────────────────────────────────────

class _AnimatedDigitalCounter extends StatefulWidget {
  final int target;
  final Color color;
  const _AnimatedDigitalCounter({
    required this.target,
    required this.color,
  });

  @override
  State<_AnimatedDigitalCounter> createState() =>
      _AnimatedDigitalCounterState();
}

class _AnimatedDigitalCounterState extends State<_AnimatedDigitalCounter>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        final val = (_anim.value * widget.target).round();
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // VT323 — 64pt scoreboardDigital
            Text(
              val.toString(),
              style: DType.scoreboardDigital(64,
                  color: widget.color),
            ),
            const SizedBox(width: DTokens.s8),
            Padding(
              padding: const EdgeInsets.only(bottom: DTokens.s8),
              child: Text(
                'pts',
                style: DType.label(16,
                    color: widget.color.withValues(alpha: 0.6)),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ── breakdown card ────────────────────────────────────────────────────────────

class _BreakdownCard extends StatelessWidget {
  final _BreakdownItem item;
  final Color teamColor;
  const _BreakdownCard({
    required this.item,
    required this.teamColor,
  });

  @override
  Widget build(BuildContext context) {
    return DGlassPanel(
      padding: const EdgeInsets.all(DTokens.s16),
      radius: DTokens.r16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // 아이콘 컨테이너
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: item.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Image.asset(
                    item.assetPath,
                    errorBuilder: (e, s, t) => Icon(
                      item.fallbackIcon,
                      size: 18,
                      color: item.accent,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: DTokens.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 한글 label
                    Text(
                      item.label,
                      style: DType.heading(15, color: Colors.white),
                    ),
                    // 영문 CAPS + 가중치
                    Text(
                      '${item.labelEn}  ·  가중치 ${(item.weight * 100).toInt()}%',
                      style: DType.label(11,
                          color: DTokens.textTertiaryDark),
                    ),
                  ],
                ),
              ),
              // 점수 — scoreboardDigital
              Text(
                '+${item.score}',
                style: DType.scoreboardDigital(28,
                    color: item.accent),
              ),
            ],
          ),

          const SizedBox(height: DTokens.s12),

          // 진행률 바
          Stack(
            children: [
              // 배경
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: DTokens.borderDark,
                  borderRadius: BorderRadius.circular(DTokens.rPill),
                ),
              ),
              // 채움
              FractionallySizedBox(
                widthFactor: item.weight,
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: item.accent,
                    borderRadius:
                        BorderRadius.circular(DTokens.rPill),
                    boxShadow: [
                      BoxShadow(
                        color: item.accent.withValues(alpha: 0.5),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              )
                  .animate()
                  .custom(
                    duration: 1000.ms,
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) =>
                        FractionallySizedBox(
                      widthFactor: item.weight * value,
                      child: child,
                    ),
                  ),
            ],
          ),

          const SizedBox(height: 6),

          // 바 하단 레이블
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '기여 비중',
                style: DType.label(11,
                    color: DTokens.textTertiaryDark),
              ),
              Text(
                '${(item.weight * 100).toInt()}%',
                style: DType.mono(10, color: item.accent),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
