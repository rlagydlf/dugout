import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_theme.dart';
import '../../app/theme/team_theme.dart';
import '../../app/theme/tokens.dart';
import '../../app/theme/typography.dart';
import '../../core/providers/app_providers.dart';
import '../../shared/widgets/d_matchup_card.dart';
import 'series_content.dart';
import 'series_led.dart';
import 'series_widgets.dart';

// ── mock ──────────────────────────────────────────────────────────────────────

const _kHomeId = 'lg';
const _kAwayId = 'doosan';
const _kIsLive = true;

// ── screen ────────────────────────────────────────────────────────────────────

class SeriesScreen extends ConsumerWidget {
  const SeriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final team = context.team;
    final sortied = ref.watch(sortiedTodayProvider);
    final home = TeamThemes.byId(_kHomeId);
    final away = TeamThemes.byId(_kAwayId);

    return Scaffold(
      backgroundColor: DTokens.bgDark,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── backdrop layer
          _SeriesBackdrop(home: home, away: away),

          // ── content
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _DuelHero(home: home, away: away),
              ),
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, -20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: DTokens.s16),
                    child: DMatchupCard(
                      game: MatchupGameInfo(
                        home: home,
                        away: away,
                        status: _kIsLive
                            ? GameStatus.live
                            : GameStatus.preGame,
                        time: '18:30',
                        seriesLabel: '시리즈 1차전',
                        stadium: home.stadium,
                        homeScore: _kIsLive ? 3 : null,
                        awayScore: _kIsLive ? 2 : null,
                        inning: _kIsLive ? kSeriesCurrentInning : null,
                        isTopInning: false,
                        homePitcher: '임찬규',
                        awayPitcher: '곽빈',
                      ),
                      height: 196,
                    ),
                  ),
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.04),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: DTokens.s16),
                  child: _kIsLive
                      ? SeriesInningLedBoard(home: home, away: away)
                      : SeriesPitcherCards(home: home, away: away),
                ),
              ),
              if (_kIsLive) ...[
                const SliverToBoxAdapter(
                    child: SizedBox(height: DTokens.s16)),
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: DTokens.s16),
                    child: SeriesTimeline(),
                  ),
                ),
              ],
              const SliverToBoxAdapter(
                  child: SizedBox(height: DTokens.s16)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: DTokens.s16),
                  child: SeriesQuestSection(team: team),
                ),
              ),
              const SliverToBoxAdapter(
                  child: SizedBox(height: DTokens.s16)),
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: DTokens.s16),
                  child: SeriesPredictionSection(),
                ),
              ),
              const SliverToBoxAdapter(
                  child: SizedBox(height: DTokens.s16)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: DTokens.s16),
                  child: SeriesFanComparisonSection(
                      home: home, away: away),
                ),
              ),
              const SliverToBoxAdapter(
                  child: SizedBox(height: DTokens.s16)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: DTokens.s16),
                  child: _SortieCta(sortied: sortied, team: team),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height:
                      MediaQuery.of(context).padding.bottom + DTokens.s48,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── series backdrop ───────────────────────────────────────────────────────────

class _SeriesBackdrop extends StatefulWidget {
  final TeamTheme home;
  final TeamTheme away;
  const _SeriesBackdrop({required this.home, required this.away});

  @override
  State<_SeriesBackdrop> createState() => _SeriesBackdropState();
}

class _SeriesBackdropState extends State<_SeriesBackdrop>
    with TickerProviderStateMixin {
  late final AnimationController _rotateCtrl;
  late final AnimationController _glowCtrl;

  @override
  void initState() {
    super.initState();
    _rotateCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 32),
    )..repeat();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotateCtrl.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final home = widget.home;
    final away = widget.away;
    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. 홈팀 mood 이미지 — full bleed backdrop
        Positioned.fill(
          child: Image.asset(
            home.moodAsset,
            fit: BoxFit.cover,
            color: Colors.black.withValues(alpha: 0.72),
            colorBlendMode: BlendMode.darken,
            errorBuilder: (context, error, stackTrace) =>
                const SizedBox.shrink(),
          ),
        ),

        // 2. 다크 vignette
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  DTokens.bgDark.withValues(alpha: 0.55),
                  Colors.transparent,
                  DTokens.bgDark.withValues(alpha: 0.70),
                ],
                stops: const [0.0, 0.40, 1.0],
              ),
            ),
          ),
        ),

        // 3. dual team radial glows (좌 = home, 우 = away)
        AnimatedBuilder(
          animation: _glowCtrl,
          builder: (context, _) {
            final opacityHome = 0.08 + _glowCtrl.value * 0.06;
            final opacityAway = 0.06 + (1 - _glowCtrl.value) * 0.06;
            return Stack(
              fit: StackFit.expand,
              children: [
                Positioned(
                  top: -60,
                  left: -80,
                  child: Container(
                    width: 360,
                    height: 280,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          home.primary.withValues(alpha: opacityHome),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: -60,
                  right: -80,
                  child: Container(
                    width: 360,
                    height: 280,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          away.primary.withValues(alpha: opacityAway),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),

        // 4. ambient 야구공 — 우하단, 천천히 회전
        Positioned(
          bottom: -90,
          right: -80,
          child: AnimatedBuilder(
            animation: _rotateCtrl,
            builder: (context, child) => Transform.rotate(
              angle: _rotateCtrl.value * 2 * math.pi,
              child: child,
            ),
            child: Opacity(
              opacity: 0.05,
              child: Image.asset(
                'assets/images/icons/baseball.png',
                width: 260,
                height: 260,
                errorBuilder: (context, error, stackTrace) => const SizedBox(
                  width: 260,
                  height: 260,
                ),
              ),
            ),
          ),
        ),

        // 5. 다이아몬드 그리드
        Positioned.fill(
          child: CustomPaint(
            painter: _SeriesDiamondPainter(
              home.primary.withValues(alpha: 0.03),
            ),
          ),
        ),
      ],
    );
  }
}

// ── diamond painter ───────────────────────────────────────────────────────────

class _SeriesDiamondPainter extends CustomPainter {
  final Color color;
  const _SeriesDiamondPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.6
      ..style = PaintingStyle.stroke;
    const step = 44.0;
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
  bool shouldRepaint(covariant _SeriesDiamondPainter old) =>
      old.color != color;
}

// ── duel hero ─────────────────────────────────────────────────────────────────

class _DuelHero extends StatelessWidget {
  final TeamTheme home;
  final TeamTheme away;
  const _DuelHero({required this.home, required this.away});

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return SizedBox(
      height: 260 + topPad,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // split gradient background
          Row(
            children: [
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        home.primary,
                        Color.lerp(
                            home.primary, home.secondary, 0.5)!,
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        away.primary,
                        Color.lerp(
                            away.primary, away.secondary, 0.5)!,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          // home pattern overlay
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            right: MediaQuery.of(context).size.width * 0.5,
            child: Opacity(
              opacity: 0.1,
              child: Image.asset(
                home.patternAsset,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox.shrink(),
              ),
            ),
          ),
          // center slash
          Positioned.fill(
            child: CustomPaint(
                painter: const DiagonalSlashPainter()),
          ),
          // bottom vignette
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 100,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    DTokens.bgDark.withValues(alpha: 0.92),
                  ],
                ),
              ),
            ),
          ),
          // home mascot
          Positioned(
            left: -16,
            bottom: 16,
            child: Image.asset(
              home.mascotAsset,
              width: 180,
              height: 200,
              fit: BoxFit.contain,
              alignment: Alignment.bottomCenter,
              errorBuilder: (context, error, stackTrace) => SizedBox(
                width: 180,
                height: 200,
                child: Center(
                  child: Text(
                    home.teamShortName.substring(0, 1),
                    style: DType.impact(96,
                        color: Colors.white.withValues(alpha: 0.15)),
                  ),
                ),
              ),
            ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.08),
          ),
          // away mascot (mirrored)
          Positioned(
            right: -16,
            bottom: 16,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(3.14159),
              child: Image.asset(
                away.mascotAsset,
                width: 180,
                height: 200,
                fit: BoxFit.contain,
                alignment: Alignment.bottomCenter,
                errorBuilder: (context, error, stackTrace) => SizedBox(
                  width: 180,
                  height: 200,
                  child: Center(
                    child: Text(
                      away.teamShortName.substring(0, 1),
                      style: DType.impact(96,
                          color:
                              Colors.white.withValues(alpha: 0.15)),
                    ),
                  ),
                ),
              ),
            ).animate().fadeIn(duration: 500.ms).slideX(begin: 0.08),
          ),
          // center VS pill
          Positioned(
            top: topPad + DTokens.s48,
            left: 0,
            right: 0,
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(DTokens.rPill),
                child: Text('VS',
                    style: DType.impact(22,
                        color: Colors.white54,
                        letterSpacing: 3)),
              ),
            ),
          ),
          // top nav
          Positioned(
            top: topPad + DTokens.s8,
            left: 0,
            right: 0,
            child: Row(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.only(left: DTokens.s16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(home.teamShortName,
                          style: DType.label(12,
                              color: Colors.white
                                  .withValues(alpha: 0.85))),
                      Text('HOME',
                          style: DType.micro(9,
                              color: Colors.white
                                  .withValues(alpha: 0.7))),
                    ],
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 18),
                  onPressed: () => context.pop(),
                  visualDensity: VisualDensity.compact,
                ),
                const Spacer(),
                Padding(
                  padding:
                      const EdgeInsets.only(right: DTokens.s16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(away.teamShortName,
                          style: DType.label(12,
                              color: Colors.white
                                  .withValues(alpha: 0.85))),
                      Text('AWAY',
                          style: DType.micro(9,
                              color: Colors.white
                                  .withValues(alpha: 0.7))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 450.ms);
  }
}

// ── sortie CTA ────────────────────────────────────────────────────────────────

class _SortieCta extends ConsumerWidget {
  final bool sortied;
  final TeamTheme team;
  const _SortieCta({required this.sortied, required this.team});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: sortied ? null : () => context.push('/sortie'),
      child: AnimatedContainer(
        duration: 350.ms,
        height: 72,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(DTokens.r20),
          gradient: sortied
              ? null
              : LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [team.primary, team.secondary],
                ),
          color: sortied ? DTokens.surfaceDark : null,
          border:
              sortied ? Border.all(color: DTokens.borderDark) : null,
          boxShadow: sortied
              ? null
              : [
                  BoxShadow(
                    color: team.primary.withValues(alpha: 0.45),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        padding: const EdgeInsets.symmetric(
            horizontal: DTokens.s20),
        child: Row(
          children: [
            Image.asset(
              'assets/images/icons/megaphone.png',
              width: 26,
              height: 26,
              color: sortied ? team.primary : Colors.white,
              colorBlendMode: BlendMode.srcIn,
              errorBuilder: (context, error, stackTrace) => Icon(
                sortied
                    ? Icons.check_circle_rounded
                    : Icons.campaign_rounded,
                size: 26,
                color: sortied ? team.primary : Colors.white,
              ),
            ),
            const SizedBox(width: DTokens.s12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sortied ? '오늘 출정 완료!' : '지금 출정',
                    style: DType.heading(18).copyWith(
                        color: sortied
                            ? DTokens.textPrimaryDark
                            : Colors.white,
                        letterSpacing: 1.5),
                  ),
                  Text(
                    sortied ? '내일 다시 만나요!' : 'ENGAGE NOW  ·  +50P',
                    style: DType.label(12,
                        color: sortied
                            ? DTokens.textSecondaryDark
                            : Colors.white.withValues(alpha: 0.75)),
                  ),
                ],
              ),
            ),
            if (!sortied)
              const Icon(Icons.arrow_forward_ios_rounded,
                  color: Colors.white, size: 16),
          ],
        ),
      ),
    ).animate(delay: 300.ms).fadeIn(duration: 380.ms).slideY(begin: 0.05);
  }
}
