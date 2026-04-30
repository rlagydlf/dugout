import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_theme.dart';
import '../../app/theme/tokens.dart';
import '../../app/theme/typography.dart';
import '../../core/providers/app_providers.dart';
import '../../shared/widgets/d_effects.dart';
import '../../shared/widgets/d_scoreboard.dart';

// ── phase enum ────────────────────────────────────────────────────────────────

enum _SortiePhase { charging, explode, complete }

// ── screen ────────────────────────────────────────────────────────────────────

class SortieModal extends ConsumerStatefulWidget {
  const SortieModal({super.key});

  @override
  ConsumerState<SortieModal> createState() => _SortieModalState();
}

class _SortieModalState extends ConsumerState<SortieModal>
    with TickerProviderStateMixin {
  _SortiePhase _phase = _SortiePhase.charging;
  bool _pointVisible = false;

  late final AnimationController _pulseCtrl;
  late final AnimationController _rippleCtrl;
  late final AnimationController _ripple2Ctrl;
  late final AnimationController _ripple3Ctrl;
  late final AnimationController _floatCtrl;
  late final AnimationController _scanCtrl;
  // Phase 3: 24개 파티클 (별 + 번개) — explode + complete
  late final AnimationController _particleCtrl;
  late final AnimationController _shimmerCtrl;

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);

    _rippleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _ripple2Ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _ripple3Ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );

    _scanCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();

    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    _runSequence();
  }

  Future<void> _runSequence() async {
    // charging: 3 light haptics
    for (int i = 0; i < 3; i++) {
      await Future.delayed(const Duration(milliseconds: 380));
      if (!mounted) return;
      await HapticFeedback.lightImpact();
    }
    if (!mounted) return;

    // → explode
    setState(() => _phase = _SortiePhase.explode);
    _pulseCtrl.stop();
    // stagger 3 ripple waves
    _rippleCtrl.forward(from: 0);
    await Future.delayed(const Duration(milliseconds: 160));
    if (!mounted) return;
    _ripple2Ctrl.forward(from: 0);
    await Future.delayed(const Duration(milliseconds: 160));
    if (!mounted) return;
    _ripple3Ctrl.forward(from: 0);
    // medium haptic at peak
    await HapticFeedback.mediumImpact();
    // Phase 3: 24-particle explosion
    _particleCtrl.forward(from: 0);
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.heavyImpact();

    await Future.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;

    // → complete
    setState(() {
      _phase = _SortiePhase.complete;
      _pointVisible = true;
    });
    _floatCtrl.repeat(reverse: true);
    _particleCtrl.repeat(); // continue sparkle in complete
    _shimmerCtrl.repeat();
    await HapticFeedback.lightImpact();
  }

  void _close() {
    ref.read(sortiedTodayProvider.notifier).state = true;
    ref.read(userProvider.notifier).addSortie();
    ref.read(userProvider.notifier).addPoint(50);
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _rippleCtrl.dispose();
    _ripple2Ctrl.dispose();
    _ripple3Ctrl.dispose();
    _floatCtrl.dispose();
    _scanCtrl.dispose();
    _particleCtrl.dispose();
    _shimmerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final team = context.team;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: DTokens.bgDark,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── radial glow (phase에 따라 강도 변화)
          _GlowBackground(team: team, phase: _phase),

          // ── 다이아몬드 배경
          Positioned.fill(
            child: CustomPaint(
              painter: DDiamondGridPainter(
                team.primary.withValues(alpha: 0.04),
              ),
            ),
          ),

          // ── CRT 스캔라인
          AnimatedBuilder(
            animation: _scanCtrl,
            builder: (context, _) => CustomPaint(
              painter: _SortieScanPainter(_scanCtrl.value),
            ),
          ),

          // ── 충격파 ripple #1
          if (_phase == _SortiePhase.explode)
            _ShockwaveRipple(
              color: team.primary,
              controller: _rippleCtrl,
              center: Offset(size.width / 2, size.height / 2),
              scale: 1.0,
            ),
          // ── 충격파 ripple #2 — wider, secondary
          if (_phase == _SortiePhase.explode)
            _ShockwaveRipple(
              color: team.secondary,
              controller: _ripple2Ctrl,
              center: Offset(size.width / 2, size.height / 2),
              scale: 1.15,
            ),
          // ── 충격파 ripple #3 — widest, accent tint
          if (_phase == _SortiePhase.explode)
            _ShockwaveRipple(
              color: team.primary.withValues(alpha: 0.55),
              controller: _ripple3Ctrl,
              center: Offset(size.width / 2, size.height / 2),
              scale: 1.3,
            ),

          // ── Phase 3: 24개 파티클 폭발 (별 + 번개, explode & complete)
          if (_phase == _SortiePhase.explode ||
              _phase == _SortiePhase.complete)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _particleCtrl,
                builder: (context, _) => CustomPaint(
                  painter: _SortieParticlePainter(
                    progress: _particleCtrl.value,
                    color: team.primary,
                    accentColor: team.accent,
                    size: size,
                  ),
                ),
              ),
            ),

          // ── 닫기 버튼
          Positioned(
            top: MediaQuery.of(context).padding.top + DTokens.s8,
            right: DTokens.s16,
            child: AnimatedOpacity(
              opacity: _phase == _SortiePhase.complete ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 400),
              child: IconButton(
                icon: const Icon(Icons.close_rounded,
                    color: Colors.white54, size: 26),
                onPressed: _phase == _SortiePhase.complete ? _close : null,
              ),
            ),
          ),

          // ── 중앙 콘텐츠
          Center(
            child: switch (_phase) {
              _SortiePhase.charging => _ChargingContent(
                  team: team,
                  pulseCtrl: _pulseCtrl,
                ),
              _SortiePhase.explode => _ExplodeContent(team: team),
              _SortiePhase.complete => _CompleteContent(
                  team: team,
                  pointVisible: _pointVisible,
                  floatCtrl: _floatCtrl,
                  shimmerCtrl: _shimmerCtrl,
                ),
            },
          ),

          // ── 하단 완료 버튼
          if (_phase == _SortiePhase.complete)
            Positioned(
              left: DTokens.s24,
              right: DTokens.s24,
              bottom:
                  MediaQuery.of(context).padding.bottom + DTokens.s32,
              child: _CompleteBottom(team: team, onClose: _close),
            ),
        ],
      ),
    );
  }
}

// ── glow background ───────────────────────────────────────────────────────────

class _GlowBackground extends StatelessWidget {
  final dynamic team;
  final _SortiePhase phase;
  const _GlowBackground({required this.team, required this.phase});

  @override
  Widget build(BuildContext context) {
    final intensity = switch (phase) {
      _SortiePhase.charging => 0.22,
      _SortiePhase.explode  => 0.85,
      _SortiePhase.complete => 0.45,
    };
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.4,
          colors: [
            (team.primary as Color).withValues(alpha: intensity),
            DTokens.bgDark.withValues(alpha: 0.9),
            DTokens.bgDark,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }
}

// ── shockwave ─────────────────────────────────────────────────────────────────

class _ShockwaveRipple extends StatelessWidget {
  final Color color;
  final AnimationController controller;
  final Offset center;
  final double scale;
  const _ShockwaveRipple({
    required this.color,
    required this.controller,
    required this.center,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) => CustomPaint(
        painter: _RipplePainter(
          progress: controller.value,
          color: color,
          center: center,
          scale: scale,
        ),
      ),
    );
  }
}

class _RipplePainter extends CustomPainter {
  final double progress;
  final Color color;
  final Offset center;
  final double scale;
  _RipplePainter({
    required this.progress,
    required this.color,
    required this.center,
    this.scale = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final maxR =
        math.sqrt(center.dx * center.dx + center.dy * center.dy) * 1.6 * scale;
    for (int i = 0; i < 4; i++) {
      final delay = i * 0.18;
      final t = ((progress - delay) / (1 - delay)).clamp(0.0, 1.0);
      if (t <= 0) continue;
      final radius = maxR * Curves.easeOutCubic.transform(t);
      final opacity = (1 - t) * 0.65;
      final paint = Paint()
        ..color = color.withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5 - t * 2;
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(_RipplePainter old) =>
      old.progress != progress || old.scale != scale;
}

// ── Phase 3: 24개 파티클 painter (별 + 번개) ─────────────────────────────────

class _SortieParticlePainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color accentColor;
  final Size size;

  static const _count = 24;
  static final _rng = math.Random(42);

  _SortieParticlePainter({
    required this.progress,
    required this.color,
    required this.accentColor,
    required this.size,
  });

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final cx = canvasSize.width / 2;
    final cy = canvasSize.height * 0.38;

    for (int i = 0; i < _count; i++) {
      final phaseOffset = i / _count;
      final t = ((progress - phaseOffset + 1.0) % 1.0);
      final fade = math.sin(t * math.pi).clamp(0.0, 1.0);
      if (fade < 0.01) continue;

      final angle =
          (i / _count) * 2 * math.pi + progress * math.pi * 0.4;
      final radius = 80.0 + _rng.nextDouble() * 160.0;
      final x = cx + math.cos(angle) * radius;
      final y = cy + math.sin(angle) * radius * 0.6;
      final pSize = 2.5 + _rng.nextDouble() * 5.5;
      final useAccent = i % 3 == 0;
      final paint = Paint()
        ..color = (useAccent ? accentColor : color)
            .withValues(alpha: fade * 0.8)
        ..style = PaintingStyle.fill;

      // alternate star and lightning
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
      final ix = c.dx + math.cos(innerA) * s * 0.38;
      final iy = c.dy + math.sin(innerA) * s * 0.38;
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
  bool shouldRepaint(_SortieParticlePainter old) =>
      old.progress != progress;
}

// ── charging content ──────────────────────────────────────────────────────────

class _ChargingContent extends StatelessWidget {
  final dynamic team;
  final AnimationController pulseCtrl;
  const _ChargingContent({required this.team, required this.pulseCtrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 마스코트 + 다중 펄스 글로우
        AnimatedBuilder(
          animation: pulseCtrl,
          builder: (context, child) {
            final s = 1.0 + pulseCtrl.value * 0.06;
            final glowOpacity = 0.3 + pulseCtrl.value * 0.4;
            return Transform.scale(
              scale: s,
              child: DMultiPulseGlow(
                color: team.primary as Color,
                accentColor: team.accent as Color,
                size: 220,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (team.primary as Color)
                            .withValues(alpha: glowOpacity),
                        blurRadius: 56,
                        spreadRadius: 16,
                      ),
                    ],
                  ),
                  child: child,
                ),
              ),
            );
          },
          child: Image.asset(
            team.mascotAsset as String,
            width: 200,
            height: 200,
            fit: BoxFit.contain,
            errorBuilder: (e, s, t) => Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: (team.primary as Color).withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.sports_baseball_rounded,
                size: 100,
                color: (team.primary as Color).withValues(alpha: 0.5),
              ),
            ),
          ),
        ),

        const SizedBox(height: DTokens.s32),

        // CHARGING... LED text
        Text(
          'CHARGING...',
          style: DType.scoreboardDigital(28,
              color: (team.primary as Color).withValues(alpha: 0.9)),
        )
            .animate(onPlay: (c) => c.repeat())
            .shimmer(
              duration: 1400.ms,
              color: Colors.white.withValues(alpha: 0.5),
            ),

        const SizedBox(height: DTokens.s20),

        // 충전 바
        _ChargeBar(color: team.primary as Color),

        const SizedBox(height: DTokens.s16),

        Text(
          (team.teamName as String).toUpperCase(),
          style: DType.label(12,
              color: Colors.white.withValues(alpha: 0.6)),
        ),
      ],
    );
  }
}

class _ChargeBar extends StatelessWidget {
  final Color color;
  const _ChargeBar({required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(DTokens.rPill),
        child: Container(
          height: 5,
          color: color.withValues(alpha: 0.15),
          child: Container(color: color)
              .animate(onPlay: (c) => c.repeat())
              .custom(
                duration: 1200.ms,
                builder: (context, value, child) => FractionallySizedBox(
                  widthFactor: value,
                  alignment: Alignment.centerLeft,
                  child: Container(color: color),
                ),
              ),
        ),
      ),
    );
  }
}

// ── explode content ───────────────────────────────────────────────────────────

class _ExplodeContent extends StatelessWidget {
  final dynamic team;
  const _ExplodeContent({required this.team});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 마스코트 scale-up 폭발
        Image.asset(
          team.mascotAsset as String,
          width: 240,
          height: 240,
          fit: BoxFit.contain,
          errorBuilder: (e, s, t) => Icon(
            Icons.sports_baseball_rounded,
            size: 200,
            color: team.primary as Color,
          ),
        )
            .animate()
            .scale(
              begin: const Offset(0.4, 0.4),
              end: const Offset(1.0, 1.0),
              duration: 550.ms,
              curve: Curves.easeOutBack,
            )
            .fadeIn(duration: 280.ms),

        const SizedBox(height: DTokens.s20),

        // 출정! — impact gradient
        DImpactText(text: '출정!', size: 88, gradient: true)
            .animate()
            .scale(
              begin: const Offset(0.2, 0.2),
              duration: 500.ms,
              curve: Curves.elasticOut,
            )
            .fadeIn(duration: 220.ms),
      ],
    );
  }
}

// ── complete content ──────────────────────────────────────────────────────────

class _CompleteContent extends StatelessWidget {
  final dynamic team;
  final bool pointVisible;
  final AnimationController floatCtrl;
  final AnimationController shimmerCtrl;

  const _CompleteContent({
    required this.team,
    required this.pointVisible,
    required this.floatCtrl,
    required this.shimmerCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 마스코트 플로팅
        AnimatedBuilder(
          animation: floatCtrl,
          builder: (context, child) => Transform.translate(
            offset: Offset(0, -6 + floatCtrl.value * 12),
            child: child,
          ),
          child: Image.asset(
            team.mascotAsset as String,
            width: 160,
            height: 160,
            fit: BoxFit.contain,
            errorBuilder: (e, s, t) => Icon(
              Icons.sports_baseball_rounded,
              size: 120,
              color: team.primary as Color,
            ),
          )
              .animate()
              .scale(
                begin: const Offset(2.2, 2.2),
                end: const Offset(1.0, 1.0),
                duration: 750.ms,
                curve: Curves.easeOutCubic,
              )
              .fadeIn(duration: 350.ms),
        ),

        const SizedBox(height: DTokens.s20),

        // 거대 "출정" — impact gradient
        DImpactText(text: '출정', size: 96, gradient: true)
            .animate()
            .fadeIn(delay: 200.ms, duration: 500.ms)
            .slideY(
              begin: -0.15,
              curve: Curves.easeOutCubic,
            ),

        const SizedBox(height: DTokens.s8),

        Text(
          (team.teamName as String).toUpperCase(),
          style: DType.label(12, color: team.primary as Color),
        ).animate().fadeIn(delay: 350.ms),

        const SizedBox(height: DTokens.s24),

        // Phase 3: +50P 큰 텍스트 (heading 64) + shimmer
        if (pointVisible) _PointBadge(team: team),

        const SizedBox(height: DTokens.s24),

        // tagline 인용
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: DTokens.s40),
          child: Column(
            children: [
              Text(
                '오늘의 한 마디',
                style: DType.label(11,
                    color: Colors.white.withValues(alpha: 0.6)),
              ),
              const SizedBox(height: DTokens.s8),
              Text(
                '"${team.tagline}"',
                textAlign: TextAlign.center,
                style: DType.body(16).copyWith(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontStyle: FontStyle.italic,
                  height: 1.6,
                ),
              ).animate(delay: 500.ms).fadeIn(duration: 600.ms),
            ],
          ),
        ),
      ],
    );
  }
}

// ── point badge — Phase 3: heading(64) + shimmer ──────────────────────────────

class _PointBadge extends StatelessWidget {
  final dynamic team;
  const _PointBadge({required this.team});

  @override
  Widget build(BuildContext context) {
    return DShimmerSweep(
      period: const Duration(milliseconds: 2000),
      highlightOpacity: 0.28,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: DTokens.s24, vertical: DTokens.s12),
        decoration: BoxDecoration(
          color: (team.primary as Color).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(DTokens.rPill),
          border: Border.all(
            color: (team.primary as Color).withValues(alpha: 0.55),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: (team.primary as Color).withValues(alpha: 0.45),
              blurRadius: 28,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/icons/trophy.png',
              width: 22,
              height: 22,
              errorBuilder: (e, s, t) => Icon(
                Icons.emoji_events_rounded,
                size: 22,
                color: team.primary as Color,
              ),
            ),
            const SizedBox(width: DTokens.s12),
            // Phase 3: heading(64) 큰 텍스트
            Text(
              '+50',
              style: DType.heading(64, color: Colors.white),
            ),
            const SizedBox(width: DTokens.s4),
            Text(
              'P 적립',
              style: DType.label(16, color: Colors.white),
            ),
          ],
        ),
      ),
    )
        .animate()
        .slideY(begin: 0.5, duration: 600.ms, curve: Curves.easeOutCubic)
        .fadeIn(duration: 400.ms);
  }
}

// ── complete bottom ───────────────────────────────────────────────────────────

class _CompleteBottom extends StatelessWidget {
  final dynamic team;
  final VoidCallback onClose;
  const _CompleteBottom({required this.team, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onClose,
        style: ElevatedButton.styleFrom(
          backgroundColor: team.primary as Color,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 58),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DTokens.r20),
          ),
          shadowColor: (team.primary as Color).withValues(alpha: 0.65),
          elevation: 14,
        ),
        child: Text(
          '완료',
          style: DType.heading(20, color: Colors.white),
        ),
      )
          .animate()
          .fadeIn(delay: 750.ms, duration: 400.ms)
          .slideY(begin: 0.25, curve: Curves.easeOutCubic),
    );
  }
}

// ── scanline painter ──────────────────────────────────────────────────────────

class _SortieScanPainter extends CustomPainter {
  final double progress;
  _SortieScanPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.016)
      ..strokeWidth = 1;
    for (double y = 0; y < size.height; y += 3) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    final hp = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..strokeWidth = 80
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24);
    canvas.drawLine(
      Offset(0, size.height * progress),
      Offset(size.width, size.height * progress),
      hp,
    );
  }

  @override
  bool shouldRepaint(_SortieScanPainter old) => old.progress != progress;
}
