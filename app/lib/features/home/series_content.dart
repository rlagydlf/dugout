import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/team_theme.dart';
import '../../app/theme/tokens.dart';
import '../../app/theme/typography.dart';
import '../../shared/widgets/d_glass_panel.dart';
import '../../shared/widgets/d_point_badge.dart';
import 'series_widgets.dart'
    show
        kSeriesQuests,
        kSeriesPredictions,
        kSeriesFanRows,
        SeriesSectionLabel;

// ── quest section ─────────────────────────────────────────────────────────────

class SeriesQuestSection extends StatelessWidget {
  final TeamTheme team;
  const SeriesQuestSection({super.key, required this.team});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SeriesSectionLabel(text: '연결 퀘스트', accent: team.primary),
            const Spacer(),
            GestureDetector(
              onTap: () => context.push('/quests'),
              child: Text('전체보기',
                  style: DType.label(12, color: team.primary)),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ...List.generate(kSeriesQuests.length, (i) {
          final q = kSeriesQuests[i];
          return Padding(
            padding: EdgeInsets.only(
                bottom: i < kSeriesQuests.length - 1 ? DTokens.s8 : 0),
            child: DGlassPanel(
              radius: DTokens.r16,
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: DTokens.s8, vertical: 3),
                    decoration: BoxDecoration(
                      color: team.primary.withValues(alpha: 0.15),
                      borderRadius:
                          BorderRadius.circular(DTokens.rPill),
                    ),
                    child: Text(q.$1,
                        style: DType.label(11, color: team.primary)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(q.$2,
                        style: DType.body(15, FontWeight.w600)
                            .copyWith(
                                color: DTokens.textPrimaryDark)),
                  ),
                  DPointBadge(point: q.$3, compact: true),
                ],
              ),
            ).animate(delay: Duration(milliseconds: 100 + 50 * i))
                .fadeIn(duration: 300.ms),
          );
        }),
      ],
    );
  }
}

// ── prediction section ────────────────────────────────────────────────────────

class SeriesPredictionSection extends StatelessWidget {
  const SeriesPredictionSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const SeriesSectionLabel(
                text: '연결 예측', accent: DTokens.warning),
            const Spacer(),
            GestureDetector(
              onTap: () => context.push('/predictions'),
              child: Text('전체보기',
                  style: DType.label(12, color: DTokens.warning)),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ...List.generate(kSeriesPredictions.length, (i) {
          final p = kSeriesPredictions[i];
          return Padding(
            padding: EdgeInsets.only(
                bottom: i < kSeriesPredictions.length - 1
                    ? DTokens.s8
                    : 0),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: DTokens.surfaceDark,
                borderRadius: BorderRadius.circular(DTokens.r16),
                border: Border.all(color: DTokens.borderDark),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(p.$1,
                        style: DType.label(11,
                            color: DTokens.textTertiaryDark)),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(p.$2,
                        style: DType.body(15, FontWeight.w800)
                            .copyWith(
                                color: DTokens.textPrimaryDark)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: DTokens.s4),
                    decoration: BoxDecoration(
                      color: DTokens.warning.withValues(alpha: 0.12),
                      borderRadius:
                          BorderRadius.circular(DTokens.rPill),
                      border: Border.all(
                          color:
                              DTokens.warning.withValues(alpha: 0.3)),
                    ),
                    child: Text('× ${p.$3}',
                        style:
                            DType.mono(12, color: DTokens.warning)),
                  ),
                ],
              ),
            ).animate(delay: Duration(milliseconds: 120 + 50 * i))
                .fadeIn(duration: 300.ms),
          );
        }),
      ],
    );
  }
}

// ── fan comparison ────────────────────────────────────────────────────────────

class SeriesFanComparisonSection extends StatelessWidget {
  final TeamTheme home;
  final TeamTheme away;
  const SeriesFanComparisonSection(
      {super.key, required this.home, required this.away});

  @override
  Widget build(BuildContext context) {
    return DGlassPanel(
      teamBorder: false,
      radius: DTokens.r20,
      padding: const EdgeInsets.all(DTokens.s16),
      child: Column(
        children: [
          Row(
            children: [
              const SeriesSectionLabel(
                  text: '라이벌 팬 비교', accent: DTokens.warning),
              const Spacer(),
              Container(
                width: 7,
                height: 7,
                margin: const EdgeInsets.only(right: 5),
                decoration: const BoxDecoration(
                    color: DTokens.success, shape: BoxShape.circle),
              ).animate(onPlay: (c) => c.repeat(reverse: true))
                  .fade(begin: 0.3, end: 1.0, duration: 700.ms),
              Text('실시간',
                  style: DType.label(12, color: DTokens.success)),
            ],
          ),
          const SizedBox(height: DTokens.s12),
          ...List.generate(kSeriesFanRows.length, (i) {
            final row = kSeriesFanRows[i];
            return Padding(
              padding: EdgeInsets.only(
                  bottom: i < kSeriesFanRows.length - 1
                      ? DTokens.s12
                      : 0),
              child: _DualBar(
                label: row.$1,
                homeVal: row.$2,
                awayVal: row.$3,
                homeFraction: row.$4,
                homeColor: home.primary,
                awayColor: away.primary,
              ),
            );
          }),
        ],
      ),
    ).animate(delay: 150.ms).fadeIn(duration: 380.ms);
  }
}

class _DualBar extends StatelessWidget {
  final String label;
  final String homeVal;
  final String awayVal;
  final double homeFraction;
  final Color homeColor;
  final Color awayColor;
  const _DualBar({
    required this.label,
    required this.homeVal,
    required this.awayVal,
    required this.homeFraction,
    required this.homeColor,
    required this.awayColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
            style: DType.label(11, color: DTokens.textTertiaryDark)),
        const SizedBox(height: DTokens.s4),
        Row(
          children: [
            Text(homeVal, style: DType.mono(13, color: homeColor)),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(DTokens.rPill),
                  child: SizedBox(
                    height: 8,
                    child: Row(
                      children: [
                        Expanded(
                          flex: (homeFraction * 100).round(),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [
                                homeColor,
                                homeColor.withValues(alpha: 0.7),
                              ]),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: ((1 - homeFraction) * 100).round(),
                          child: Container(
                              color: awayColor.withValues(alpha: 0.4)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Text(awayVal, style: DType.mono(13, color: awayColor)),
          ],
        ),
      ],
    );
  }
}
