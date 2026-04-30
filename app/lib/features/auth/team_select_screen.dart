import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/team_theme.dart';
import '../../app/theme/theme_provider.dart';
import '../../app/theme/tokens.dart';
import '../../app/theme/typography.dart';
import '../../core/providers/app_providers.dart';
import '../../shared/widgets/d_button.dart';
import '../../shared/widgets/d_effects.dart';
import '../../shared/widgets/d_team_crest.dart';

// ── mock team stats ───────────────────────────────────────────────────────────

const _kTeamStats = <String, (String, String, String)>{
  'lg':      ('1위', '2회', '오스틴'),
  'doosan':  ('4위', '6회', '양의지'),
  'kiwoom':  ('7위', '1회', '이정후'),
  'ssg':     ('2위', '4회', '최정'),
  'kia':     ('3위', '11회', '나성범'),
  'nc':      ('5위', '2회', '박민우'),
  'kt':      ('6위', '2회', '강백호'),
  'samsung': ('8위', '8회', '구자욱'),
  'lotte':   ('9위', '2회', '안치홍'),
  'hanwha':  ('10위', '1회', '노시환'),
};

// ── screen ────────────────────────────────────────────────────────────────────

class TeamSelectScreen extends ConsumerStatefulWidget {
  const TeamSelectScreen({super.key});

  @override
  ConsumerState<TeamSelectScreen> createState() => _TeamSelectScreenState();
}

class _TeamSelectScreenState extends ConsumerState<TeamSelectScreen>
    with TickerProviderStateMixin {
  String? _previewTeamId;
  late final AnimationController _glowCtrl;
  late final AnimationController _particleCtrl;
  bool _confirmed = false;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    _particleCtrl.dispose();
    super.dispose();
  }

  TeamTheme get _selectedTheme =>
      _previewTeamId != null
          ? TeamThemes.byId(_previewTeamId)
          : TeamTheme.defaultTheme;

  Future<void> _onConfirm() async {
    if (_previewTeamId == null) return;
    setState(() => _confirmed = true);
    _particleCtrl.forward(from: 0);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    final router = GoRouter.of(context);
    await ref.read(currentTeamProvider.notifier).select(_previewTeamId!);
    ref.read(userProvider.notifier).selectTeam(_previewTeamId!);
    if (!mounted) return;
    router.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final teams = TeamThemes.all;
    final selected = _selectedTheme;

    return Scaffold(
      backgroundColor: DTokens.bgDark,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── 팀 컬러 radial glow
          AnimatedContainer(
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topCenter,
                radius: 1.2,
                colors: [
                  selected.primary.withValues(alpha: 0.30),
                  selected.primary.withValues(alpha: 0.06),
                  DTokens.bgDark,
                ],
                stops: const [0.0, 0.4, 1.0],
              ),
            ),
          ),

          // ── 마스코트 배경 fade in
          if (_previewTeamId != null)
            Positioned(
              right: -60,
              top: MediaQuery.of(context).padding.top + 40,
              child: Opacity(
                opacity: 0.12,
                child: Image.asset(
                  selected.mascotAsset,
                  width: 280,
                  fit: BoxFit.contain,
                  errorBuilder: (e, s, t) => const SizedBox.shrink(),
                ),
              ),
            ).animate().fadeIn(duration: 400.ms).slideX(
                  begin: 0.08,
                  curve: Curves.easeOutBack,
                ),

          // ── diamond grid
          Positioned.fill(
            child: CustomPaint(
              painter: DDiamondGridPainter(
                selected.primary.withValues(alpha: 0.025),
              ),
            ),
          ),

          // ── scanline
          Positioned.fill(
            child: CustomPaint(
              painter: DScanlinePainter(opacity: 0.013),
            ),
          ),

          // ── particle effect (선택 완료 시)
          if (_confirmed)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _particleCtrl,
                builder: (context, _) => CustomPaint(
                  painter: _ConfirmParticlePainter(
                    progress: _particleCtrl.value,
                    color: selected.primary,
                    accentColor: selected.accent,
                  ),
                ),
              ),
            ),

          // ── main content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TeamSelectHeader(onBack: () => context.pop()),
                const SizedBox(height: DTokens.s16),

                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: DTokens.s24),
                  child: _PreviewTitle(
                    selected: selected,
                    hasSelection: _previewTeamId != null,
                    glowCtrl: _glowCtrl,
                  ),
                ),

                const SizedBox(height: DTokens.s20),

                // ── 10팀 그리드
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: DTokens.s16,
                      vertical: DTokens.s4,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: DTokens.s12,
                      crossAxisSpacing: DTokens.s12,
                      childAspectRatio: 1.1,
                    ),
                    itemCount: teams.length,
                    itemBuilder: (context, i) {
                      final t = teams[i];
                      final isSelected = _previewTeamId == t.teamId;
                      return _TeamCard(
                        team: t,
                        selected: isSelected,
                        stats: _kTeamStats[t.teamId],
                        onTap: () =>
                            setState(() => _previewTeamId = t.teamId),
                      )
                          .animate()
                          .fadeIn(
                            delay: Duration(milliseconds: 50 * i),
                            duration: 350.ms,
                          )
                          .slideY(
                            begin: 0.08,
                            delay: Duration(milliseconds: 50 * i),
                            duration: 400.ms,
                            curve: Curves.easeOutCubic,
                          );
                    },
                  ),
                ),

                // ── 하단 CTA
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    DTokens.s24,
                    DTokens.s12,
                    DTokens.s24,
                    MediaQuery.of(context).padding.bottom + DTokens.s16,
                  ),
                  child: _previewTeamId == null
                      ? DButton(
                          label: '팀을 선택해 주세요',
                          onPressed: null,
                        )
                      : D3DTiltCard(
                          onTap: _onConfirm,
                          child: DShimmerSweep(
                            period: const Duration(milliseconds: 2800),
                            highlightOpacity: 0.22,
                            child: DButton(
                              label: '${selected.teamShortName} 선택 완료',
                              icon: Icons.check_rounded,
                              onPressed: _onConfirm,
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── header ────────────────────────────────────────────────────────────────────

class _TeamSelectHeader extends StatelessWidget {
  final VoidCallback onBack;
  const _TeamSelectHeader({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          DTokens.s16, DTokens.s12, DTokens.s16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: DTokens.surfaceDark,
                borderRadius: BorderRadius.circular(DTokens.r12),
                border: Border.all(color: DTokens.borderDark),
              ),
              child: const Icon(Icons.arrow_back_rounded,
                  size: 20, color: Colors.white),
            ),
          ),
          const SizedBox(width: DTokens.s12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('CHOOSE YOUR TEAM',
                  style: DType.label(12,
                      color: Colors.white.withValues(alpha: 0.7))),
              Text('응원팀 선택',
                  style: DType.heading(20, color: Colors.white)),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}

// ── preview title ─────────────────────────────────────────────────────────────

class _PreviewTitle extends StatelessWidget {
  final TeamTheme selected;
  final bool hasSelection;
  final AnimationController glowCtrl;

  const _PreviewTitle({
    required this.selected,
    required this.hasSelection,
    required this.glowCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      transitionBuilder: (child, anim) =>
          FadeTransition(opacity: anim, child: child),
      child: hasSelection
          ? _SelectedPreview(
              key: ValueKey(selected.teamId),
              team: selected,
              glowCtrl: glowCtrl,
            )
          : const _NoSelectionHint(key: ValueKey('hint')),
    );
  }
}

class _NoSelectionHint extends StatelessWidget {
  const _NoSelectionHint({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '나의 팀을\n선택하세요',
          style: DType.heading(30, color: Colors.white),
        ),
        const SizedBox(height: DTokens.s8),
        Text(
          '선택한 팀의 컬러로 앱 전체가 바뀝니다',
          style: DType.body(16)
              .copyWith(color: Colors.white.withValues(alpha: 0.7)),
        ),
      ],
    );
  }
}

class _SelectedPreview extends StatelessWidget {
  final TeamTheme team;
  final AnimationController glowCtrl;
  const _SelectedPreview({
    super.key,
    required this.team,
    required this.glowCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 팀 로고 with 다중 펄스 글로우
        DMultiPulseGlow(
          color: team.primary,
          accentColor: team.accent,
          size: 80,
          child: ClipOval(
            child: Image.asset(
              team.crestAsset,
              width: 72,
              height: 72,
              fit: BoxFit.contain,
              errorBuilder: (e, s, t) =>
                  DTeamCrest(team: team, size: 72, glow: true),
            ),
          ),
        ),
        const SizedBox(width: DTokens.s16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                team.teamShortName.toUpperCase(),
                style: DType.label(14, color: team.primary),
              ),
              Text(
                team.teamName,
                style: DType.heading(22, color: Colors.white),
              ),
              const SizedBox(height: DTokens.s4),
              Text(
                '"${team.tagline}"',
                style: DType.body(14).copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── team card (3D tilt + mascot + logo + stats) ───────────────────────────────

class _TeamCard extends StatelessWidget {
  final TeamTheme team;
  final bool selected;
  final (String, String, String)? stats;
  final VoidCallback onTap;

  const _TeamCard({
    required this.team,
    required this.selected,
    required this.stats,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return D3DTiltCard(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(DTokens.r20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.lerp(team.primary, Colors.black, selected ? 0.25 : 0.45)!,
              Color.lerp(
                  team.secondary, Colors.black, selected ? 0.1 : 0.35)!,
            ],
          ),
          border: Border.all(
            color: selected
                ? team.primary
                : Colors.white.withValues(alpha: 0.07),
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: team.primary.withValues(alpha: 0.5),
                    blurRadius: 24,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: team.primary.withValues(alpha: 0.25),
                    blurRadius: 48,
                    spreadRadius: 4,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Stack(
          children: [
            // 마스코트 배경 (우하단 cropped)
            Positioned(
              right: -20,
              bottom: -20,
              child: Opacity(
                opacity: selected ? 0.35 : 0.18,
                child: Image.asset(
                  team.mascotAsset,
                  width: 100,
                  fit: BoxFit.contain,
                  errorBuilder: (e, s, t) => const SizedBox.shrink(),
                ),
              ),
            ),

            // 패턴 텍스처
            Positioned.fill(
              child: Opacity(
                opacity: 0.08,
                child: Image.asset(
                  team.patternAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (e, s, t) => const SizedBox.shrink(),
                ),
              ),
            ),

            // 선택 체크마크
            if (selected)
              Positioned(
                top: DTokens.s8,
                right: DTokens.s8,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: team.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_rounded,
                      size: 13, color: Colors.white),
                ).animate().scale(
                      begin: const Offset(0, 0),
                      duration: 300.ms,
                      curve: Curves.easeOutBack,
                    ),
              ),

            // 콘텐츠
            Padding(
              padding: const EdgeInsets.all(DTokens.s14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 실제 KBO 로고
                  Image.asset(
                    team.crestAsset,
                    width: 48,
                    height: 48,
                    fit: BoxFit.contain,
                    errorBuilder: (e, s, t) =>
                        DTeamCrest(team: team, size: 48),
                  ),
                  const Spacer(),
                  // 영문 ALL CAPS
                  Text(
                    team.teamShortName.toUpperCase(),
                    style: DType.label(11,
                        color: selected
                            ? team.primary
                            : Colors.white.withValues(alpha: 0.9)),
                  ),
                  const SizedBox(height: 2),
                  // 한글 팀명
                  Text(
                    team.teamName,
                    style: DType.body(13, FontWeight.w700).copyWith(
                      color: team.accent.withValues(alpha: 0.9),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // mock 시즌 통계 (순위 / 우승 횟수)
                  if (stats != null) ...[
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        _StatChip(label: stats!.$1, color: team.primary),
                        const SizedBox(width: 4),
                        _StatChip(
                            label: '우승 ${stats!.$2}',
                            color: DTokens.warning),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final Color color;
  const _StatChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: DType.micro(9, color: color.withValues(alpha: 0.9)),
      ),
    );
  }
}

// ── confirm particle painter ──────────────────────────────────────────────────

class _ConfirmParticlePainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color accentColor;

  static const _count = 24;
  static final _rng = math.Random(99);

  _ConfirmParticlePainter({
    required this.progress,
    required this.color,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.75;

    for (int i = 0; i < _count; i++) {
      final phaseOffset = i / _count;
      final t = ((progress - phaseOffset + 1.0) % 1.0);
      final scaleT = Curves.easeOutCubic.transform(t.clamp(0.0, 1.0));
      final fade = (1.0 - t).clamp(0.0, 1.0);
      if (fade < 0.02) continue;

      final angle = (i / _count) * 2 * math.pi;
      final spread = 50.0 + _rng.nextDouble() * 120.0;
      final x = cx + math.cos(angle) * spread * scaleT;
      final y = cy + math.sin(angle) * spread * scaleT * 0.65;
      final pSize = 3.0 + _rng.nextDouble() * 6.0;

      final useAccent = i % 3 == 0;
      final paint = Paint()
        ..color = (useAccent ? accentColor : color)
            .withValues(alpha: fade * 0.85)
        ..style = PaintingStyle.fill;

      if (i % 2 == 0) {
        _drawStar(canvas, Offset(x, y), pSize, paint);
      } else {
        _drawLightning(canvas, Offset(x, y), pSize, paint);
      }
    }
  }

  void _drawStar(Canvas canvas, Offset c, double s, Paint p) {
    final path = Path();
    for (int j = 0; j < 4; j++) {
      final outerA = j * math.pi / 2 - math.pi / 4;
      final innerA = outerA + math.pi / 4;
      final ox = c.dx + math.cos(outerA) * s;
      final oy = c.dy + math.sin(outerA) * s;
      final ix = c.dx + math.cos(innerA) * s * 0.36;
      final iy = c.dy + math.sin(innerA) * s * 0.36;
      if (j == 0) {
        path.moveTo(ox, oy);
      } else {
        path.lineTo(ox, oy);
      }
      path.lineTo(ix, iy);
    }
    path.close();
    canvas.drawPath(path, p);
  }

  void _drawLightning(Canvas canvas, Offset c, double s, Paint p) {
    final path = Path()
      ..moveTo(c.dx + s * 0.2, c.dy - s)
      ..lineTo(c.dx - s * 0.1, c.dy - s * 0.05)
      ..lineTo(c.dx + s * 0.3, c.dy - s * 0.05)
      ..lineTo(c.dx - s * 0.2, c.dy + s)
      ..lineTo(c.dx + s * 0.1, c.dy + s * 0.05)
      ..lineTo(c.dx - s * 0.3, c.dy + s * 0.05)
      ..close();
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(_ConfirmParticlePainter old) =>
      old.progress != progress;
}
