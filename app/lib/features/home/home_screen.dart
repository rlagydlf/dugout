import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_theme.dart';
import '../../app/theme/tokens.dart';
import '../../app/theme/typography.dart';
import '../../app/theme/team_theme.dart';
import '../../core/providers/app_providers.dart';
import '../../shared/widgets/d_matchup_card.dart';
import '../../shared/widgets/d_point_badge.dart';
import '../../shared/widgets/d_team_crest.dart';
import '../../shared/widgets/d_effects.dart';
import 'home_rival.dart';
import 'home_widgets.dart';

// ── mock ──────────────────────────────────────────────────────────────────────

const _kHomeScore = 3;
const _kAwayScore = 2;
const _kInning = 5;

// ── screen ────────────────────────────────────────────────────────────────────

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final team = context.team;
    final user = ref.watch(userProvider);
    final sortied = ref.watch(sortiedTodayProvider);

    return Scaffold(
      backgroundColor: DTokens.bgDark,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── backdrop layer (ambient + parallax baseball)
          _StadiumBackdrop(team: team, scrollCtrl: _scrollCtrl),

          // ── content
          CustomScrollView(
            controller: _scrollCtrl,
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _Header(user: user, team: team)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      DTokens.s16, 0, DTokens.s16, 0),
                  child: _HeroMatchup(team: team),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      DTokens.s16, DTokens.s8, DTokens.s16, 0),
                  child: _LiveInsightStripe(team: team),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      DTokens.s16, DTokens.s16, DTokens.s16, 0),
                  child: _SortieCta(sortied: sortied, team: team),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      DTokens.s16, DTokens.s16, DTokens.s16, 0),
                  child: HomeStatLedPanel(team: team),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: DTokens.s16)),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: DTokens.s16),
                sliver: SliverGrid.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.28,
                  children: [
                    D3DTiltCard(
                      onTap: () => context.push('/quests'),
                      child: HomeActionTile(
                        iconAsset: 'assets/images/icons/plate.png',
                        label: '오늘의 퀘스트',
                        sublabel: 'QUESTS',
                        badge: '5',
                        isLive: false,
                        accent: team.primary,
                        onTap: () => context.push('/quests'),
                      ),
                    ).animate(delay: 40.ms).fadeIn(duration: 280.ms).slideY(begin: 0.06, curve: Curves.easeOutBack),
                    D3DTiltCard(
                      onTap: () => context.push('/predictions'),
                      child: HomeActionTile(
                        iconAsset: 'assets/images/icons/bolt.png',
                        label: '예측 참여',
                        sublabel: 'PREDICT',
                        badge: 'LIVE',
                        isLive: true,
                        accent: DTokens.warning,
                        onTap: () => context.push('/predictions'),
                      ),
                    ).animate(delay: 80.ms).fadeIn(duration: 280.ms).slideY(begin: 0.06, curve: Curves.easeOutBack),
                    D3DTiltCard(
                      onTap: () => context.push('/rewards'),
                      child: HomeActionTile(
                        iconAsset: 'assets/images/icons/trophy.png',
                        label: '리워드샵',
                        sublabel: 'REWARDS',
                        badge: 'N',
                        isLive: false,
                        accent: DTokens.success,
                        onTap: () => context.push('/rewards'),
                      ),
                    ).animate(delay: 120.ms).fadeIn(duration: 280.ms).slideY(begin: 0.06, curve: Curves.easeOutBack),
                    D3DTiltCard(
                      onTap: () => context.push('/fancard'),
                      child: HomeActionTile(
                        iconAsset: 'assets/images/icons/helmet.png',
                        label: '내 팬카드',
                        sublabel: 'FAN CARD',
                        badge: null,
                        isLive: false,
                        accent: team.accent,
                        onTap: () => context.push('/fancard'),
                      ),
                    ).animate(delay: 160.ms).fadeIn(duration: 280.ms).slideY(begin: 0.06, curve: Curves.easeOutBack),
                  ],
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      DTokens.s16, DTokens.s20, DTokens.s16, 0),
                  child: HomeRivalPanel(team: team),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, DTokens.s20, 0, 0),
                  child: HomeNewsRibbon(team: team),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: MediaQuery.of(context).padding.bottom + DTokens.s48,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── stadium backdrop ───────────────────────────────────────────────────────────

class _StadiumBackdrop extends StatefulWidget {
  final TeamTheme team;
  final ScrollController scrollCtrl;
  const _StadiumBackdrop({required this.team, required this.scrollCtrl});

  @override
  State<_StadiumBackdrop> createState() => _StadiumBackdropState();
}

class _StadiumBackdropState extends State<_StadiumBackdrop>
    with TickerProviderStateMixin {
  late final AnimationController _rotateCtrl;
  late final AnimationController _glowCtrl;

  @override
  void initState() {
    super.initState();
    _rotateCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 28),
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
    final team = widget.team;
    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. mood image
        Positioned.fill(
          child: Image.asset(
            team.moodAsset,
            fit: BoxFit.cover,
            color: Colors.black.withValues(alpha: 0.72),
            colorBlendMode: BlendMode.darken,
            errorBuilder: (context, error, stackTrace) =>
                const SizedBox.shrink(),
          ),
        ),

        // 2. vignette
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
                stops: const [0.0, 0.45, 1.0],
              ),
            ),
          ),
        ),

        // 3. team radial glow
        AnimatedBuilder(
          animation: _glowCtrl,
          builder: (context, _) {
            final opacity = 0.10 + _glowCtrl.value * 0.07;
            return Positioned(
              top: -80,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 420,
                  height: 320,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        team.primary.withValues(alpha: opacity),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),

        // 4. parallax ambient baseball — 우상단
        Positioned(
          top: -80,
          right: -100,
          child: DParallaxLayer(
            scrollController: widget.scrollCtrl,
            factor: 0.22,
            child: AnimatedBuilder(
              animation: _rotateCtrl,
              builder: (context, child) => Transform.rotate(
                angle: _rotateCtrl.value * 2 * math.pi,
                child: child,
              ),
              child: Opacity(
                opacity: 0.055,
                child: Image.asset(
                  'assets/images/icons/baseball.png',
                  width: 280,
                  height: 280,
                  errorBuilder: (context, error, stackTrace) => const SizedBox(
                    width: 280,
                    height: 280,
                  ),
                ),
              ),
            ),
          ),
        ),

        // 5. diamond grid
        Positioned.fill(
          child: CustomPaint(
            painter: DDiamondGridPainter(
              team.primary.withValues(alpha: 0.04),
            ),
          ),
        ),
      ],
    );
  }
}

// ── header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final dynamic user;
  final TeamTheme team;
  const _Header({required this.user, required this.team});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            DTokens.s20, DTokens.s12, DTokens.s12, DTokens.s8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.nickname as String,
                    style: DType.heading(28, color: DTokens.textPrimaryDark),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: team.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: team.primary.withValues(alpha: 0.6),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        team.teamName,
                        style: DType.label(12, color: team.primary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            DPointBadge(point: user.point as int, compact: true),
            const SizedBox(width: DTokens.s8),
            DTeamCrest(team: team, size: 38),
            Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined, size: 22),
                  color: DTokens.textSecondaryDark,
                  onPressed: () {},
                  visualDensity: VisualDensity.compact,
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: DTokens.danger,
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: DTokens.bgDark, width: 1.5),
                    ),
                  )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .scale(
                        begin: const Offset(0.85, 0.85),
                        end: const Offset(1.15, 1.15),
                        duration: 900.ms,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 350.ms);
  }
}

// ── hero matchup (DMatchupCard v2 with 3D tilt + shimmer) ────────────────────

class _HeroMatchup extends StatelessWidget {
  final TeamTheme team;
  const _HeroMatchup({required this.team});

  @override
  Widget build(BuildContext context) {
    final rival = TeamThemes.byId(kHomeRivalId);
    final game = MatchupGameInfo(
      home: team,
      away: rival,
      status: GameStatus.live,
      time: '18:30',
      seriesLabel: '시리즈 1차전',
      stadium: team.stadium,
      homeScore: _kHomeScore,
      awayScore: _kAwayScore,
      inning: _kInning,
      isTopInning: false,
      homePitcher: '임찬규',
      awayPitcher: '곽빈',
    );

    return D3DTiltCard(
      onTap: () => context.push('/series'),
      child: DShimmerSweep(
        period: const Duration(milliseconds: 3200),
        highlightOpacity: 0.16,
        child: DMatchupCard(game: game, height: 196),
      ),
    ).animate().fadeIn(duration: 480.ms).slideY(
          begin: 0.05,
          curve: Curves.easeOutBack,
        );
  }
}

// ── live insight stripe (다중 펄스 글로우) ────────────────────────────────────

class _LiveInsightStripe extends StatelessWidget {
  final TeamTheme team;
  const _LiveInsightStripe({required this.team});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: DTokens.surfaceDark2,
        borderRadius: BorderRadius.circular(DTokens.r8),
        border: Border.all(color: DTokens.danger.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          const SizedBox(width: DTokens.s12),
          // 다중 펄스 LIVE dot
          DMultiPulseGlow(
            color: DTokens.danger,
            accentColor: Colors.orange,
            size: 14,
            child: Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                color: DTokens.danger,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: DTokens.s8),
          Text(
            '현재 5회 말',
            style: DType.scoreboardDigital(17, color: DTokens.danger),
          ),
          Container(
            width: 1,
            height: 16,
            margin: const EdgeInsets.symmetric(horizontal: DTokens.s8),
            color: DTokens.borderDark,
          ),
          Text(
            'LG 공격 중',
            style: DType.body(14, FontWeight.w700)
                .copyWith(color: team.primary),
          ),
          Container(
            width: 1,
            height: 16,
            margin: const EdgeInsets.symmetric(horizontal: DTokens.s8),
            color: DTokens.borderDark,
          ),
          Expanded(
            child: Text(
              '다음 타자: 오스틴 (OPS .950)',
              style: DType.mono(13,
                  color: DTokens.textSecondaryDark,
                  weight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: DTokens.s12),
        ],
      ),
    ).animate(delay: 120.ms).fadeIn(duration: 300.ms).slideX(begin: -0.03);
  }
}

// ── sortie CTA (3D tilt + shimmer + glow pulse) ───────────────────────────────

class _SortieCta extends ConsumerStatefulWidget {
  final bool sortied;
  final TeamTheme team;
  const _SortieCta({required this.sortied, required this.team});

  @override
  ConsumerState<_SortieCta> createState() => _SortieCtaState();
}

class _SortieCtaState extends ConsumerState<_SortieCta>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glowCtrl;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    if (!widget.sortied) _glowCtrl.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(_SortieCta oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.sortied && _glowCtrl.isAnimating) {
      _glowCtrl.stop();
    } else if (!widget.sortied && !_glowCtrl.isAnimating) {
      _glowCtrl.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sortied = widget.sortied;
    final team = widget.team;

    final inner = AnimatedBuilder(
      animation: _glowCtrl,
      builder: (context, _) {
        final glow = sortied ? 0.0 : 0.4 + _glowCtrl.value * 0.3;
        return AnimatedContainer(
          duration: 350.ms,
          height: 74,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(DTokens.r20),
            border: Border.all(
              color: sortied
                  ? team.primary.withValues(alpha: 0.25)
                  : team.primary.withValues(alpha: 0.7),
              width: sortied ? 1 : 1.5,
            ),
            color: sortied ? DTokens.surfaceDark2 : null,
            boxShadow: sortied
                ? null
                : [
                    BoxShadow(
                      color: team.primary.withValues(alpha: glow),
                      blurRadius: 28,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: team.primary.withValues(alpha: glow * 0.5),
                      blurRadius: 48,
                      spreadRadius: 4,
                      offset: const Offset(0, 12),
                    ),
                  ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(DTokens.r20),
            child: Stack(
              children: [
                if (!sortied)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            team.primary.withValues(alpha: 0.82),
                            team.secondary.withValues(alpha: 0.6),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (!sortied)
                  Positioned.fill(
                    child: CustomPaint(painter: DScanlinePainter(opacity: 0.025)),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: DTokens.s20),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/images/icons/megaphone.png',
                        width: 28,
                        height: 28,
                        color: sortied ? team.primary : Colors.white,
                        colorBlendMode: BlendMode.srcIn,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          sortied
                              ? Icons.check_circle_rounded
                              : Icons.campaign_rounded,
                          size: 28,
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
                              style: DType.heading(22,
                                  color: sortied
                                      ? DTokens.textPrimaryDark
                                      : Colors.white),
                            ),
                            Text(
                              sortied
                                  ? '내일 다시 만나요!'
                                  : 'ENGAGE NOW  ·  +50P  ·  기여도 +30',
                              style: DType.label(12,
                                  color: sortied
                                      ? DTokens.textSecondaryDark
                                      : Colors.white
                                          .withValues(alpha: 0.88)),
                            ),
                          ],
                        ),
                      ),
                      if (!sortied) ...[
                        const Icon(Icons.chevron_right_rounded,
                            color: Colors.white54, size: 18),
                        const Icon(Icons.chevron_right_rounded,
                            color: Colors.white, size: 18),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    return D3DTiltCard(
      onTap: sortied ? null : () => context.push('/sortie'),
      child: sortied
          ? inner
          : DShimmerSweep(
              period: const Duration(milliseconds: 3200),
              highlightOpacity: 0.2,
              child: inner,
            ),
    ).animate(delay: 90.ms).fadeIn(duration: 380.ms).slideY(
          begin: 0.05,
          curve: Curves.easeOutBack,
        );
  }
}
