import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../app/theme/team_theme.dart';
import '../../app/theme/tokens.dart';
import '../../app/theme/typography.dart';

enum GameStatus { preGame, live, finished }

class MatchupGameInfo {
  final TeamTheme home;
  final TeamTheme away;
  final GameStatus status;
  final String time; // '18:30'
  final String seriesLabel; // '시리즈 1차전'
  final int? homeScore;
  final int? awayScore;
  final int? inning; // 1~9
  final bool? isTopInning;
  final String? homePitcher;
  final String? awayPitcher;
  final String stadium;

  const MatchupGameInfo({
    required this.home,
    required this.away,
    required this.status,
    required this.time,
    required this.seriesLabel,
    required this.stadium,
    this.homeScore,
    this.awayScore,
    this.inning,
    this.isTopInning,
    this.homePitcher,
    this.awayPitcher,
  });

  bool get isLive => status == GameStatus.live;
  bool get isPre => status == GameStatus.preGame;
  bool get isFinished => status == GameStatus.finished;
}

/// 매치업 카드 — 양 팀 로고 좌우 + 가운데 상태 영역.
/// 경기 전: 시간 + 선발투수
/// 라이브: 스코어 + 이닝
/// 종료: 최종 스코어 + FINAL
class DMatchupCard extends StatelessWidget {
  final MatchupGameInfo game;
  final double height;

  const DMatchupCard({
    super.key,
    required this.game,
    this.height = 188,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(DTokens.r24),
        boxShadow: [
          BoxShadow(
            color: game.home.primary.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(-6, 8),
          ),
          BoxShadow(
            color: game.away.primary.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(6, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(DTokens.r24),
        child: Stack(
          children: [
            // 좌/우 분할 그라데이션 배경
            Row(
              children: [
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          game.home.primary,
                          Color.lerp(
                              game.home.primary, game.home.secondary, 0.6)!,
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color.lerp(
                              game.away.primary, game.away.secondary, 0.6)!,
                          game.away.primary,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // 다이아몬드 패턴 오버레이 (subtle)
            Positioned.fill(
              child: CustomPaint(
                painter: _DiamondPatternPainter(),
              ),
            ),
            // top vignette
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.25),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.45),
                    ],
                    stops: const [0.0, 0.4, 1.0],
                  ),
                ),
              ),
            ),
            // 콘텐츠
            Padding(
              padding: const EdgeInsets.all(DTokens.s16),
              child: Column(
                children: [
                  // 상단 라벨
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _StatusPill(game: game),
                      Text(
                        game.seriesLabel,
                        style: DType.label(10, color: Colors.white70),
                      ),
                      _StadiumPill(stadium: game.stadium),
                    ],
                  ),
                  const Spacer(),
                  // 양팀 로고 + 가운데 상태
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(child: _TeamSide(team: game.home, isHome: true)),
                      _CenterStatus(game: game),
                      Expanded(child: _TeamSide(team: game.away, isHome: false)),
                    ],
                  ),
                  const Spacer(),
                  // 하단 부가 정보
                  if (game.isPre) _PitcherRow(game: game),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 좌/우 팀 사이드 ────────────────────────────────────────────────────────────

class _TeamSide extends StatelessWidget {
  final TeamTheme team;
  final bool isHome;
  const _TeamSide({required this.team, required this.isHome});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          team.crestAsset,
          width: 56,
          height: 56,
          fit: BoxFit.contain,
          errorBuilder: (e, s, t) => Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: team.accent.withValues(alpha: 0.15),
            ),
            child: Center(
              child: Text(
                team.teamShortName,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: team.accent,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: DTokens.s8),
        Text(
          team.teamShortName,
          style: DType.impact(20, color: Colors.white, letterSpacing: 1.5),
        ),
        Text(
          isHome ? 'HOME' : 'AWAY',
          style: DType.label(9, color: Colors.white60),
        ),
      ],
    );
  }
}

// ── 가운데 상태 (경기 전 / 라이브 / 종료) ────────────────────────────────────

class _CenterStatus extends StatelessWidget {
  final MatchupGameInfo game;
  const _CenterStatus({required this.game});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 96,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (game.isPre) ...[
            Text(
              'TODAY',
              style: DType.label(10, color: Colors.white60),
            ),
            const SizedBox(height: 2),
            Text(
              game.time,
              style: DType.scoreboardDigital(36, color: Colors.white),
            ),
            const SizedBox(height: 2),
            Text(
              'VS',
              style: DType.impact(24, color: Colors.white70, letterSpacing: 4),
            ),
          ] else if (game.isLive) ...[
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
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ).animate(
                      onPlay: (c) => c.repeat(reverse: true)).fade(
                      begin: 0.4, end: 1.0, duration: 700.ms),
                  const SizedBox(width: 4),
                  Text(
                    'LIVE',
                    style: DType.badge(10, color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${game.homeScore ?? 0} : ${game.awayScore ?? 0}',
              style: DType.scoreboardDigital(40, color: Colors.white),
            ),
            Text(
              '${game.inning ?? 1}회 ${(game.isTopInning ?? true) ? '초' : '말'}',
              style: DType.label(10, color: Colors.white70),
            ),
          ] else ...[
            Text(
              'FINAL',
              style: DType.badge(10, color: Colors.white60),
            ),
            const SizedBox(height: 2),
            Text(
              '${game.homeScore ?? 0} : ${game.awayScore ?? 0}',
              style: DType.scoreboardDigital(40, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }
}

// ── 상단 status pill ─────────────────────────────────────────────────────────

class _StatusPill extends StatelessWidget {
  final MatchupGameInfo game;
  const _StatusPill({required this.game});
  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (game.status) {
      GameStatus.preGame => ('경기 전', Colors.white24),
      GameStatus.live => ('LIVE', DTokens.danger),
      GameStatus.finished => ('종료', Colors.white24),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: DTokens.s8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(DTokens.rPill),
      ),
      child: Text(
        label,
        style: DType.badge(10, color: Colors.white),
      ),
    );
  }
}

class _StadiumPill extends StatelessWidget {
  final String stadium;
  const _StadiumPill({required this.stadium});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: DTokens.s8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(DTokens.rPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.location_on_rounded, size: 11, color: Colors.white70),
          const SizedBox(width: 3),
          Text(
            stadium,
            style: DType.label(9, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _PitcherRow extends StatelessWidget {
  final MatchupGameInfo game;
  const _PitcherRow({required this.game});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _Pitcher(
            label: '선발',
            name: game.homePitcher ?? '미정',
            align: CrossAxisAlignment.start,
          ),
        ),
        const SizedBox(width: 96),
        Expanded(
          child: _Pitcher(
            label: '선발',
            name: game.awayPitcher ?? '미정',
            align: CrossAxisAlignment.end,
          ),
        ),
      ],
    );
  }
}

class _Pitcher extends StatelessWidget {
  final String label;
  final String name;
  final CrossAxisAlignment align;
  const _Pitcher({required this.label, required this.name, required this.align});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: align,
      children: [
        Text(label, style: DType.label(9, color: Colors.white54)),
        Text(
          name,
          style: DType.body(13, FontWeight.w700).copyWith(color: Colors.white),
        ),
      ],
    );
  }
}

// ── 다이아몬드 패턴 ──────────────────────────────────────────────────────────

class _DiamondPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    const step = 24.0;
    for (double y = -step; y < size.height + step; y += step) {
      for (double x = -step; x < size.width + step; x += step) {
        final path = Path()
          ..moveTo(x + step / 2, y)
          ..lineTo(x + step, y + step / 2)
          ..lineTo(x + step / 2, y + step)
          ..lineTo(x, y + step / 2)
          ..close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
