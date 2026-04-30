import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../app/theme/team_theme.dart';
import '../../app/theme/tokens.dart';
import '../../app/theme/typography.dart';
import 'series_widgets.dart' show kSeriesInningScores, kSeriesCurrentInning;

// ── LED inning board ──────────────────────────────────────────────────────────

class SeriesInningLedBoard extends StatelessWidget {
  final TeamTheme home;
  final TeamTheme away;
  const SeriesInningLedBoard(
      {super.key, required this.home, required this.away});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF070A0F),
        borderRadius: BorderRadius.circular(DTokens.r16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: DTokens.s16, vertical: DTokens.s8),
            decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(
                      color: Colors.white.withValues(alpha: 0.06))),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: DTokens.s8, vertical: 2),
                  decoration: BoxDecoration(
                    color: DTokens.danger,
                    borderRadius: BorderRadius.circular(DTokens.rPill),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        margin: const EdgeInsets.only(right: 4),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ).animate(onPlay: (c) => c.repeat(reverse: true))
                          .fade(begin: 0.3, end: 1.0, duration: 550.ms),
                      Text('LIVE',
                          style: DType.badge(9, color: Colors.white)),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Text('이닝별 스코어',
                    style: DType.body(15, FontWeight.w700)
                        .copyWith(color: DTokens.textSecondaryDark)),
                const Spacer(),
                Text('$kSeriesCurrentInning회 말 진행 중',
                    style: DType.scoreboardDigital(14,
                        color: DTokens.warning)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(DTokens.s12),
            child: Column(
              children: [
                _InningRow(
                  leading: '',
                  cells: List.generate(9, (i) => '${i + 1}'),
                  isHeader: true,
                  homeColor: home.primary,
                  awayColor: away.primary,
                ),
                const SizedBox(height: DTokens.s4),
                _InningRow(
                  leading: home.teamShortName,
                  cells: List.generate(9, (i) {
                    final s = kSeriesInningScores[i].$1;
                    return s == -1 ? '' : '$s';
                  }),
                  highlightCurrent: kSeriesCurrentInning - 1,
                  teamColor: home.primary,
                  homeColor: home.primary,
                  awayColor: away.primary,
                ),
                const SizedBox(height: DTokens.s4),
                _InningRow(
                  leading: away.teamShortName,
                  cells: List.generate(9, (i) {
                    final s = kSeriesInningScores[i].$2;
                    return s == -1 ? '' : '$s';
                  }),
                  teamColor: away.primary,
                  homeColor: home.primary,
                  awayColor: away.primary,
                ),
                const SizedBox(height: DTokens.s8),
                Container(
                    height: 1,
                    color: Colors.white.withValues(alpha: 0.06)),
                const SizedBox(height: DTokens.s8),
                Row(
                  children: [
                    const SizedBox(width: 44),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _RheCell(label: 'R', homeVal: '3', awayVal: '2',
                              homeColor: home.primary, awayColor: away.primary),
                          _RheCell(label: 'H', homeVal: '7', awayVal: '5',
                              homeColor: home.primary, awayColor: away.primary),
                          _RheCell(label: 'E', homeVal: '0', awayVal: '1',
                              homeColor: home.primary, awayColor: away.primary),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate(delay: 80.ms).fadeIn(duration: 380.ms);
  }
}

class _InningRow extends StatelessWidget {
  final String leading;
  final List<String> cells;
  final bool isHeader;
  final int? highlightCurrent;
  final Color? teamColor;
  final Color homeColor;
  final Color awayColor;

  const _InningRow({
    required this.leading,
    required this.cells,
    this.isHeader = false,
    this.highlightCurrent,
    this.teamColor,
    required this.homeColor,
    required this.awayColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 44,
          child: isHeader
              ? const SizedBox.shrink()
              : Text(
                  leading,
                  style: DType.label(11,
                      color: teamColor ?? DTokens.textTertiaryDark),
                  overflow: TextOverflow.ellipsis,
                ),
        ),
        Expanded(
          child: Row(
            children: List.generate(cells.length, (i) {
              final isCurrent = highlightCurrent == i;
              final isEmpty = cells[i].isEmpty;
              return Expanded(
                child: Container(
                  height: isHeader ? 20 : 28,
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? (teamColor ?? Colors.white).withValues(alpha: 0.15)
                        : isHeader
                            ? Colors.transparent
                            : Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(3),
                    border: isCurrent
                        ? Border.all(
                            color: (teamColor ?? Colors.white)
                                .withValues(alpha: 0.4))
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    isEmpty ? (isHeader ? cells[i] : '·') : cells[i],
                    style: isHeader
                        ? DType.label(11, color: DTokens.textTertiaryDark)
                        : DType.scoreboardDigital(
                            isEmpty ? 10 : 16,
                            color: isEmpty
                                ? DTokens.textTertiaryDark.withValues(alpha: 0.3)
                                : isCurrent
                                    ? (teamColor ?? Colors.white)
                                    : Colors.white.withValues(alpha: 0.7),
                          ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _RheCell extends StatelessWidget {
  final String label;
  final String homeVal;
  final String awayVal;
  final Color homeColor;
  final Color awayColor;
  const _RheCell({
    required this.label,
    required this.homeVal,
    required this.awayVal,
    required this.homeColor,
    required this.awayColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label,
            style: DType.label(11, color: DTokens.textTertiaryDark)),
        const SizedBox(height: 2),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(homeVal,
                style: DType.scoreboardDigital(16, color: homeColor)),
            Text(' / ',
                style: DType.scoreboardDigital(12,
                    color: DTokens.textTertiaryDark)),
            Text(awayVal,
                style: DType.scoreboardDigital(16, color: awayColor)),
          ],
        ),
      ],
    );
  }
}
