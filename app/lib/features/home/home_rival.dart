import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../app/theme/team_theme.dart';
import '../../app/theme/tokens.dart';
import '../../app/theme/typography.dart';
import 'home_widgets.dart' show kHomeRivalId, kHomeRivalFraction, kHomeNewsItems;

// ── rival panel ───────────────────────────────────────────────────────────────

class HomeRivalPanel extends StatelessWidget {
  final TeamTheme team;
  const HomeRivalPanel({super.key, required this.team});

  @override
  Widget build(BuildContext context) {
    final rival = TeamThemes.byId(kHomeRivalId);
    final ourFraction = 1.0 - kHomeRivalFraction;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(DTokens.r24),
        border: Border.all(color: DTokens.borderDark),
        color: DTokens.surfaceDark,
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(DTokens.r24)),
            child: SizedBox(
              height: 80,
              child: Stack(
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: Container(
                              color: team.primary.withValues(alpha: 0.18))),
                      Expanded(
                          child: Container(
                              color: rival.primary.withValues(alpha: 0.18))),
                    ],
                  ),
                  Center(
                    child: Container(width: 1, color: DTokens.borderDark),
                  ),
                  Positioned(
                    left: 8,
                    bottom: -8,
                    child: Image.asset(
                      team.mascotAsset,
                      width: 72,
                      height: 72,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => SizedBox(
                        width: 72,
                        height: 72,
                        child: Center(
                          child: Text(
                            team.teamShortName.substring(0, 1),
                            style: DType.impact(32, color: team.primary),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 8,
                    bottom: -8,
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.rotationY(3.14159),
                      child: Image.asset(
                        rival.mascotAsset,
                        width: 72,
                        height: 72,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => SizedBox(
                          width: 72,
                          height: 72,
                          child: Center(
                            child: Text(
                              rival.teamShortName.substring(0, 1),
                              style: DType.impact(32, color: rival.primary),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: DTokens.s8, vertical: 3),
                      decoration: BoxDecoration(
                        color: DTokens.bgDark,
                        borderRadius: BorderRadius.circular(DTokens.rPill),
                        border: Border.all(color: DTokens.borderDark),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.only(right: 5),
                            decoration: const BoxDecoration(
                              color: DTokens.success,
                              shape: BoxShape.circle,
                            ),
                          ).animate(onPlay: (c) => c.repeat(reverse: true))
                              .fade(begin: 0.3, end: 1.0, duration: 800.ms),
                          Text('오늘의 라이벌',
                              style: DType.badge(9,
                                  color: DTokens.textSecondaryDark)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
                DTokens.s16, DTokens.s16, DTokens.s16, 0),
            child: Row(
              children: [
                Text(
                  '${(ourFraction * 100).toInt()}%',
                  style: DType.scoreboardDigital(30, color: team.primary),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(DTokens.rPill),
                      child: SizedBox(
                        height: 10,
                        child: Row(
                          children: [
                            Expanded(
                              flex: (ourFraction * 100).round(),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      team.primary,
                                      team.primary.withValues(alpha: 0.65),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: (kHomeRivalFraction * 100).round(),
                              child: Container(
                                color: rival.primary.withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Text(
                  '${(kHomeRivalFraction * 100).toInt()}%',
                  style: DType.scoreboardDigital(30, color: rival.primary),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
                DTokens.s16, DTokens.s4, DTokens.s16, DTokens.s12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(team.teamShortName,
                    style: DType.label(10, color: team.primary)),
                Text('팬 기여도 대결',
                    style: DType.micro(9, color: DTokens.textTertiaryDark)),
                Text(rival.teamShortName,
                    style: DType.label(10, color: rival.primary)),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(DTokens.s16, 0, DTokens.s16, 14),
            padding: const EdgeInsets.symmetric(
                horizontal: DTokens.s12, vertical: DTokens.s8),
            decoration: BoxDecoration(
              color: DTokens.bgDark,
              borderRadius: BorderRadius.circular(DTokens.r8),
            ),
            child: Text(
              '출정·퀘스트·예측 합산  ·  자정 기준 정산',
              style: DType.micro(9, color: DTokens.textTertiaryDark),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    ).animate(delay: 200.ms).fadeIn(duration: 400.ms).slideY(begin: 0.05);
  }
}

// ── news ribbon ───────────────────────────────────────────────────────────────

class HomeNewsRibbon extends StatelessWidget {
  final TeamTheme team;
  const HomeNewsRibbon({super.key, required this.team});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(DTokens.s16, 0, DTokens.s16, 10),
          child: Row(
            children: [
              Text('TODAY', style: DType.badge(11, color: team.primary)),
              const SizedBox(width: DTokens.s8),
              Expanded(
                  child: Container(height: 1, color: DTokens.borderDark)),
            ],
          ),
        ),
        SizedBox(
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: DTokens.s16),
            itemCount: kHomeNewsItems.length,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              final item = kHomeNewsItems[i];
              return _NewsCard(
                iconAsset: 'assets/images/icons/${item.$1}',
                title: item.$2,
                subtitle: item.$3,
                accent: team.primary,
              ).animate(delay: Duration(milliseconds: 240 + 60 * i))
                  .fadeIn(duration: 320.ms)
                  .slideX(begin: 0.04);
            },
          ),
        ),
      ],
    );
  }
}

class _NewsCard extends StatelessWidget {
  final String iconAsset;
  final String title;
  final String subtitle;
  final Color accent;
  const _NewsCard({
    required this.iconAsset,
    required this.title,
    required this.subtitle,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: DTokens.surfaceDark,
        borderRadius: BorderRadius.circular(DTokens.r16),
        border: Border.all(color: DTokens.borderDark),
      ),
      padding: const EdgeInsets.all(DTokens.s12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(DTokens.r8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(9),
              child: Image.asset(
                iconAsset,
                fit: BoxFit.contain,
                color: accent,
                colorBlendMode: BlendMode.srcIn,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.sports, size: 18, color: accent),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: DType.body(12, FontWeight.w800)
                      .copyWith(color: DTokens.textPrimaryDark),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: DType.body(11, FontWeight.w400)
                      .copyWith(color: DTokens.textSecondaryDark),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
