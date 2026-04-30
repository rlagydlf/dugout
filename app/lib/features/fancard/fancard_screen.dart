import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_theme.dart';
import '../../app/theme/tokens.dart';
import '../../app/theme/typography.dart';
import '../../core/providers/app_providers.dart';
import '../../shared/widgets/d_button.dart';
import '../../shared/widgets/d_glass_panel.dart';
import '../../shared/widgets/d_scoreboard.dart';
import '../../shared/widgets/d_team_crest.dart';

// ── mock data ─────────────────────────────────────────────────────────────────

class _Badge {
  final String id;
  final String name;
  final IconData icon;
  final String rarity;
  final Color color;
  const _Badge({
    required this.id,
    required this.name,
    required this.icon,
    required this.rarity,
    required this.color,
  });
}

const _mockBadges = [
  _Badge(id: 'first_sortie', name: '첫 출정', icon: Icons.rocket_launch_rounded, rarity: 'COMMON', color: DTokens.info),
  _Badge(id: 'rookie_predictor', name: '신인 예측가', icon: Icons.psychology_rounded, rarity: 'RARE', color: DTokens.warning),
  _Badge(id: 'night_owl', name: '야행성 팬', icon: Icons.nightlight_rounded, rarity: 'RARE', color: Color(0xFF9B6DFF)),
  _Badge(id: 'streak7', name: '7일 연속', icon: Icons.local_fire_department_rounded, rarity: 'EPIC', color: DTokens.danger),
  _Badge(id: 'first_win', name: '첫 예측 적중', icon: Icons.military_tech_rounded, rarity: 'COMMON', color: DTokens.success),
  _Badge(id: 'stadium_10', name: '직관 10회', icon: Icons.stadium_rounded, rarity: 'EPIC', color: Color(0xFF00C4B4)),
  _Badge(id: 'season_complete', name: '시즌 완주', icon: Icons.emoji_events_rounded, rarity: 'LEGENDARY', color: DTokens.warning),
  _Badge(id: 'top_fan', name: '상위 1%', icon: Icons.workspace_premium_rounded, rarity: 'LEGENDARY', color: Color(0xFFFF6B9D)),
];

class _Activity {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String time;
  const _Activity({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.time,
  });
}

const _mockActivities = [
  _Activity(title: '출정 완료', subtitle: '오늘의 출정 성공 +50P', icon: Icons.rocket_launch_rounded, color: DTokens.info, time: '2시간 전'),
  _Activity(title: '예측 적중', subtitle: 'LG vs KIA 경기 승리팀 적중 +200P', icon: Icons.psychology_rounded, color: DTokens.success, time: '어제'),
  _Activity(title: '퀘스트 완료', subtitle: '응원 댓글 3개 작성 +30P', icon: Icons.assignment_turned_in_rounded, color: DTokens.warning, time: '2일 전'),
  _Activity(title: '출정 완료', subtitle: '오늘의 출정 성공 +50P', icon: Icons.rocket_launch_rounded, color: DTokens.info, time: '3일 전'),
  _Activity(title: '배지 획득', subtitle: '7일 연속 출정 달성', icon: Icons.military_tech_rounded, color: Color(0xFF9B6DFF), time: '1주일 전'),
];

// ── screen ────────────────────────────────────────────────────────────────────

class FancardScreen extends ConsumerWidget {
  const FancardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final team = context.team;

    return Scaffold(
      backgroundColor: DTokens.bgDark,
      appBar: AppBar(
        backgroundColor: DTokens.bgDark,
        elevation: 0,
        title: Text('내 팬카드', style: DType.heading(17, color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded, size: 22),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── backdrop layer
          _FancardBackdrop(team: team),

          // ── content
          ListView(
            padding: EdgeInsets.zero,
            physics: const BouncingScrollPhysics(),
            children: [
              // ── 팬카드 히어로
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    DTokens.s16, DTokens.s4, DTokens.s16, 0),
                child: _FancardHero(user: user)
                    .animate()
                    .fadeIn(duration: 500.ms)
                    .slideY(begin: -0.06, curve: Curves.easeOut),
              ),

              const SizedBox(height: DTokens.s20),

              // ── 시즌 통계 (DScoreboard 4종)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: DTokens.s16),
                child: _SeasonStats(user: user)
                    .animate()
                    .fadeIn(delay: 120.ms, duration: 400.ms),
              ),

              const SizedBox(height: 28),

              // ── 배지 컬렉션
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: DTokens.s16),
                child: _SectionLabel(
                  title: '획득 배지',
                  count: _mockBadges.length,
                  icon: 'assets/images/icons/trophy.png',
                ),
              ),
              const SizedBox(height: DTokens.s12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: DTokens.s16),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.82,
                  ),
                  itemCount: _mockBadges.length,
                  itemBuilder: (context, i) => _BadgeCell(badge: _mockBadges[i])
                      .animate()
                      .fadeIn(delay: Duration(milliseconds: 150 + 45 * i))
                      .scale(
                        begin: const Offset(0.75, 0.75),
                        curve: Curves.elasticOut,
                        duration: 600.ms,
                      ),
                ),
              ),

              const SizedBox(height: 28),

              // ── 최근 활동
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: DTokens.s16),
                child: _SectionLabel(
                  title: '최근 활동',
                  count: 0,
                  icon: 'assets/images/icons/bats.png',
                ),
              ),
              const SizedBox(height: DTokens.s12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: DTokens.s16),
                child: Column(
                  children: [
                    ..._mockActivities.asMap().entries.map(
                      (e) => _TimelineTile(
                        activity: e.value,
                        isLast: e.key == _mockActivities.length - 1,
                      )
                          .animate()
                          .fadeIn(delay: Duration(milliseconds: 200 + 70 * e.key))
                          .slideX(begin: -0.04),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: DTokens.s24),

              // ── 프로필 꾸미기 CTA
              Padding(
                padding: EdgeInsets.fromLTRB(
                  DTokens.s16,
                  0,
                  DTokens.s16,
                  MediaQuery.of(context).padding.bottom + DTokens.s24,
                ),
                child: DButton(
                  label: '프로필 꾸미기',
                  icon: Icons.tune_rounded,
                  onPressed: () => context.push('/fancard/customize'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── fancard backdrop ──────────────────────────────────────────────────────────

class _FancardBackdrop extends StatefulWidget {
  final dynamic team;
  const _FancardBackdrop({required this.team});

  @override
  State<_FancardBackdrop> createState() => _FancardBackdropState();
}

class _FancardBackdropState extends State<_FancardBackdrop>
    with TickerProviderStateMixin {
  late final AnimationController _rotateCtrl;
  late final AnimationController _glowCtrl;

  @override
  void initState() {
    super.initState();
    _rotateCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 36),
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
    final primary = widget.team.primary as Color;
    final moodAsset = widget.team.moodAsset as String;
    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. mood image backdrop
        Positioned.fill(
          child: Image.asset(
            moodAsset,
            fit: BoxFit.cover,
            color: Colors.black.withValues(alpha: 0.72),
            colorBlendMode: BlendMode.darken,
            errorBuilder: (context, error, stackTrace) =>
                const SizedBox.shrink(),
          ),
        ),

        // 2. vignette gradient
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
                stops: const [0.0, 0.38, 1.0],
              ),
            ),
          ),
        ),

        // 3. 팀 컬러 radial glow — top center
        AnimatedBuilder(
          animation: _glowCtrl,
          builder: (context, _) {
            final opacity = 0.09 + _glowCtrl.value * 0.06;
            return Positioned(
              top: -60,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 380,
                  height: 300,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        primary.withValues(alpha: opacity),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),

        // 4. ambient baseball — 좌하단, 천천히 회전
        Positioned(
          bottom: -100,
          left: -90,
          child: AnimatedBuilder(
            animation: _rotateCtrl,
            builder: (context, child) => Transform.rotate(
              angle: -_rotateCtrl.value * 2 * math.pi,
              child: child,
            ),
            child: Opacity(
              opacity: 0.045,
              child: Image.asset(
                'assets/images/icons/baseball.png',
                width: 240,
                height: 240,
                errorBuilder: (context, error, stackTrace) => const SizedBox(
                  width: 240,
                  height: 240,
                ),
              ),
            ),
          ),
        ),

        // 5. 다이아몬드 그리드
        Positioned.fill(
          child: CustomPaint(
            painter: _FancardDiamondPainter(
              primary.withValues(alpha: 0.032),
            ),
          ),
        ),
      ],
    );
  }
}

// ── diamond painter ───────────────────────────────────────────────────────────

class _FancardDiamondPainter extends CustomPainter {
  final Color color;
  const _FancardDiamondPainter(this.color);

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
  bool shouldRepaint(covariant _FancardDiamondPainter old) =>
      old.color != color;
}

// ── fancard hero ──────────────────────────────────────────────────────────────

class _FancardHero extends StatefulWidget {
  final dynamic user;
  const _FancardHero({required this.user});

  @override
  State<_FancardHero> createState() => _FancardHeroState();
}

class _FancardHeroState extends State<_FancardHero>
    with SingleTickerProviderStateMixin {
  late final AnimationController _sweepCtrl;

  @override
  void initState() {
    super.initState();
    _sweepCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat();
  }

  @override
  void dispose() {
    _sweepCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final team = context.team;
    final cardWidth = MediaQuery.of(context).size.width - DTokens.s16 * 2;
    final cardHeight = cardWidth / 1.6;

    return Container(
      width: cardWidth,
      height: cardHeight,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(DTokens.r24),
        boxShadow: [
          BoxShadow(
            color: team.primary.withValues(alpha: 0.5),
            blurRadius: 40,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: team.secondary.withValues(alpha: 0.25),
            blurRadius: 64,
            offset: const Offset(0, 24),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // base 3-stop gradient
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  team.primary,
                  Color.lerp(team.primary, team.secondary, 0.45)!,
                  team.secondary,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // 패턴 텍스처
          Positioned.fill(
            child: Opacity(
              opacity: 0.12,
              child: Image.asset(
                team.patternAsset,
                fit: BoxFit.cover,
                errorBuilder: (e, s, t) => const SizedBox.shrink(),
              ),
            ),
          ),

          // 스캔라인 질감
          Positioned.fill(
            child: CustomPaint(painter: _ScanlinePainter()),
          ),

          // 마스코트 우하단 large cropped
          Positioned(
            right: -cardHeight * 0.2,
            bottom: -cardHeight * 0.1,
            child: Image.asset(
              team.mascotAsset,
              width: cardHeight * 1.3,
              height: cardHeight * 1.3,
              fit: BoxFit.contain,
              alignment: Alignment.bottomCenter,
              errorBuilder: (e, s, t) => Icon(
                Icons.sports_baseball_rounded,
                size: cardHeight * 0.9,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),

          // 마스코트 가독성 마스크
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.black.withValues(alpha: 0.35),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.6],
                ),
              ),
            ),
          ),

          // 하단 vignette
          Positioned(
            left: 0, right: 0, bottom: 0,
            height: cardHeight * 0.4,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.5),
                  ],
                ),
              ),
            ),
          ),

          // 라이팅 sweep — gradient 좌→우 천천히 이동
          AnimatedBuilder(
            animation: _sweepCtrl,
            builder: (context, _) {
              final pos = _sweepCtrl.value;
              return Positioned.fill(
                child: FractionalTranslation(
                  translation: Offset(pos * 2.4 - 0.7, 0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.transparent,
                          Colors.white.withValues(alpha: 0.14),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // 콘텐츠
          Padding(
            padding: const EdgeInsets.all(DTokens.s20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 상단: 실제 KBO 로고 + 팀명 + 카드 정보
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 실제 KBO 로고 (투명 배경 PNG)
                    Image.asset(
                      team.crestAsset,
                      width: 44,
                      height: 44,
                      fit: BoxFit.contain,
                      errorBuilder: (e, s, t) =>
                          DTeamCrest(team: team, size: 44),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'DUGOUT FAN CARD',
                          style: DType.label(10,
                              color: team.accent.withValues(alpha: 0.6)),
                        ),
                        Text(
                          team.teamName,
                          style: DType.label(12,
                              color: team.accent.withValues(alpha: 0.85)),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: DTokens.s8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(DTokens.rPill),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Text(
                            'SEASON 2026',
                            style: DType.badge(8, color: team.accent),
                          ),
                        ),
                        const SizedBox(height: DTokens.s4),
                        // 카드번호 mono
                        Text(
                          '#0042',
                          style: DType.mono(10,
                              color: team.accent.withValues(alpha: 0.5)),
                        ),
                      ],
                    ),
                  ],
                ),

                const Spacer(),

                // 하단: 닉네임 + tagline
                Text(
                  widget.user.nickname as String,
                  style: DType.heading(28, color: team.accent),
                ),
                const SizedBox(height: DTokens.s4),

                // 가입 시즌 — mono
                Text(
                  '가입 시즌 2024  ·  NO. ${(widget.user.id as String).substring(0, 8).toUpperCase()}',
                  style: DType.mono(9,
                      color: team.accent.withValues(alpha: 0.5),
                      weight: FontWeight.w500),
                ),

                const SizedBox(height: DTokens.s8),

                // tagline 인용 bar
                Row(
                  children: [
                    Container(
                      width: 3,
                      height: 30,
                      decoration: BoxDecoration(
                        color: team.accent.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: DTokens.s8),
                    Expanded(
                      child: Text(
                        '"${team.tagline}"',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: DType.body(14).copyWith(
                          fontStyle: FontStyle.italic,
                          color: team.accent.withValues(alpha: 0.7),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── scanline painter ──────────────────────────────────────────────────────────

class _ScanlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.022)
      ..strokeWidth = 1;
    for (double y = 0; y < size.height; y += 3) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── season stats ──────────────────────────────────────────────────────────────

class _SeasonStats extends StatelessWidget {
  final dynamic user;
  const _SeasonStats({required this.user});

  @override
  Widget build(BuildContext context) {
    final team = context.team;
    return DGlassPanel(
      teamBorder: true,
      padding: const EdgeInsets.symmetric(
          horizontal: DTokens.s16, vertical: DTokens.s16),
      child: Row(
        children: [
          Expanded(
            child: DScoreboard(
              value: '${user.sortieCount}',
              label: '출정',
              accent: team.primary,
              valueSize: 26,
              align: TextAlign.center,
            ),
          ),
          Container(width: 1, height: 44, color: DTokens.borderDark),
          Expanded(
            child: DScoreboard(
              value: '${user.stadiumVisits}',
              label: '직관',
              accent: DTokens.info,
              valueSize: 26,
              align: TextAlign.center,
            ),
          ),
          Container(width: 1, height: 44, color: DTokens.borderDark),
          Expanded(
            child: DScoreboard(
              value: '68%',
              label: '예측 적중',
              accent: DTokens.success,
              valueSize: 26,
              align: TextAlign.center,
            ),
          ),
          Container(width: 1, height: 44, color: DTokens.borderDark),
          Expanded(
            child: DScoreboard(
              value: '${user.contribution}',
              label: '기여도',
              accent: DTokens.warning,
              valueSize: 26,
              align: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

// ── section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String title;
  final int count;
  final String icon;
  const _SectionLabel({
    required this.title,
    required this.count,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final team = context.team;
    return Row(
      children: [
        Image.asset(
          icon,
          width: 16,
          height: 16,
          errorBuilder: (e, s, t) => Icon(
            Icons.sports_baseball_rounded,
            size: 16,
            color: team.primary,
          ),
        ),
        const SizedBox(width: DTokens.s8),
        Text(
          title,
          style: DType.heading(16, color: Colors.white),
        ),
        if (count > 0) ...[
          const SizedBox(width: DTokens.s8),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: DTokens.s8, vertical: 2),
            decoration: BoxDecoration(
              color: team.primary.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(DTokens.rPill),
            ),
            child: Text(
              '$count개',
              style: DType.badge(10, color: team.primary),
            ),
          ),
        ],
      ],
    );
  }
}

// ── badge cell ────────────────────────────────────────────────────────────────

class _BadgeCell extends StatelessWidget {
  final _Badge badge;
  const _BadgeCell({required this.badge});

  static const _rarityBg = {
    'LEGENDARY': Color(0xFF2A1F00),
    'EPIC': Color(0xFF1A0F2E),
    'RARE': Color(0xFF0A1A2A),
  };

  @override
  Widget build(BuildContext context) {
    final bg = _rarityBg[badge.rarity] ?? DTokens.surfaceDark2;
    final isLegendary = badge.rarity == 'LEGENDARY';

    return Column(
      children: [
        _BadgeIcon(badge: badge, bg: bg, isLegendary: isLegendary),
        const SizedBox(height: DTokens.s4),
        Text(
          badge.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: DType.body(13, FontWeight.w600)
              .copyWith(color: Colors.white.withValues(alpha: 0.85)),
        ),
        Text(
          badge.rarity,
          style: DType.label(11,
              color: badge.color.withValues(alpha: 0.8)),
        ),
      ],
    );
  }
}

class _BadgeIcon extends StatefulWidget {
  final _Badge badge;
  final Color bg;
  final bool isLegendary;
  const _BadgeIcon({
    required this.badge,
    required this.bg,
    required this.isLegendary,
  });

  @override
  State<_BadgeIcon> createState() => _BadgeIconState();
}

class _BadgeIconState extends State<_BadgeIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    if (widget.isLegendary) _ctrl.repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLegendary) return _buildContainer(0.0);
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) => _buildContainer(_ctrl.value),
    );
  }

  Widget _buildContainer(double glowValue) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: widget.bg,
        borderRadius: BorderRadius.circular(DTokens.r16),
        border: Border.all(
          color: widget.badge.color.withValues(alpha: 0.55),
          width: widget.isLegendary ? 1.5 : 1,
        ),
        boxShadow: widget.isLegendary
            ? [
                BoxShadow(
                  color: widget.badge.color
                      .withValues(alpha: 0.2 + glowValue * 0.45),
                  blurRadius: 8 + glowValue * 18,
                  spreadRadius: glowValue * 2.5,
                ),
              ]
            : null,
      ),
      child: Icon(widget.badge.icon,
          color: widget.badge.color, size: 26),
    );
  }
}

// ── timeline tile ─────────────────────────────────────────────────────────────

class _TimelineTile extends StatelessWidget {
  final _Activity activity;
  final bool isLast;
  const _TimelineTile({required this.activity, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: activity.color.withValues(alpha: 0.14),
                shape: BoxShape.circle,
                border: Border.all(
                  color: activity.color.withValues(alpha: 0.35),
                ),
              ),
              child: Icon(activity.icon, size: 18, color: activity.color),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 38,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      activity.color.withValues(alpha: 0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: DTokens.s12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(
                top: DTokens.s8, bottom: DTokens.s16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.title,
                        style: DType.body(14, FontWeight.w700)
                            .copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        activity.subtitle,
                        style: DType.body(14).copyWith(
                          color: DTokens.textSecondaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: DTokens.s8),
                Text(
                  activity.time,
                  style: DType.mono(10,
                      color: DTokens.textTertiaryDark,
                      weight: FontWeight.w400),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
