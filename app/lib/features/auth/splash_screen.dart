import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_theme.dart';
import '../../app/theme/theme_provider.dart';
import '../../app/theme/tokens.dart';
import '../../app/theme/typography.dart';
import '../../shared/widgets/d_effects.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});
  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _scanCtrl;
  late final AnimationController _glowCtrl;

  @override
  void initState() {
    super.initState();
    _scanCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    Future.delayed(const Duration(milliseconds: 2200), () {
      if (!mounted) return;
      ref.read(currentTeamProvider.notifier).reset();
      context.go('/auth');
    });
  }

  @override
  void dispose() {
    _scanCtrl.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final team = context.team;
    return Scaffold(
      backgroundColor: DTokens.bgDark,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── radial glow (팀 컬러, 숨쉬기)
          AnimatedBuilder(
            animation: _glowCtrl,
            builder: (context, _) => DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.25),
                  radius: 1.0 + _glowCtrl.value * 0.15,
                  colors: [
                    team.primary.withValues(alpha: 0.22 + _glowCtrl.value * 0.08),
                    team.primary.withValues(alpha: 0.04),
                    DTokens.bgDark,
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),

          // ── diamond grid
          Positioned.fill(
            child: CustomPaint(
              painter: DDiamondGridPainter(
                team.primary.withValues(alpha: 0.04),
                step: 40,
              ),
            ),
          ),

          // ── scanline (CRT)
          AnimatedBuilder(
            animation: _scanCtrl,
            builder: (context, _) => CustomPaint(
              painter: _SplashScanlinePainter(_scanCtrl.value),
            ),
          ),

          // ── 메인 콘텐츠
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 로고 + multi-pulse glow
                DMultiPulseGlow(
                  color: team.primary,
                  accentColor: team.accent,
                  size: 140,
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: team.primary.withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.cover,
                        errorBuilder: (e, s, t) => Icon(
                          Icons.sports_baseball_rounded,
                          size: 60,
                          color: team.primary,
                        ),
                      ),
                    ),
                  ),
                )
                    .animate()
                    .scale(
                      begin: const Offset(0.5, 0.5),
                      duration: 800.ms,
                      curve: Curves.easeOutBack,
                    )
                    .fadeIn(duration: 600.ms),

                const SizedBox(height: DTokens.s32),

                // DUGOUT — Anton
                ShaderMask(
                  shaderCallback: (rect) => LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.white, team.primary],
                    stops: const [0.4, 1.0],
                  ).createShader(rect),
                  child: Text(
                    'DUGOUT',
                    style: DType.impact(58, letterSpacing: 14),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 300.ms, duration: 700.ms)
                    .slideY(begin: 0.12, curve: Curves.easeOutCubic),

                const SizedBox(height: DTokens.s8),

                // 슬로건 — Pretendard body
                Text(
                  '응원, 그 이상의 행동',
                  style: DType.body(13).copyWith(
                    color: Colors.white.withValues(alpha: 0.5),
                    letterSpacing: 3.0,
                  ),
                ).animate().fadeIn(delay: 650.ms, duration: 600.ms),

                const SizedBox(height: DTokens.s48),

                // LED 도트
                _LedDots(color: team.primary)
                    .animate()
                    .fadeIn(delay: 900.ms, duration: 500.ms),
              ],
            ),
          ),

          // ── 하단 버전
          Positioned(
            bottom: 28,
            left: 0,
            right: 0,
            child: Text(
              'v2.0.0  ·  KBO 2026',
              textAlign: TextAlign.center,
              style: DType.micro(10,
                  color: Colors.white.withValues(alpha: 0.2)),
            ).animate().fadeIn(delay: 1200.ms),
          ),
        ],
      ),
    );
  }
}

// ── LED dots ──────────────────────────────────────────────────────────────────

class _LedDots extends StatelessWidget {
  final Color color;
  const _LedDots({required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        return Container(
          width: 5,
          height: 5,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 4),
            ],
          ),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .custom(
              delay: Duration(milliseconds: 160 * i),
              duration: 700.ms,
              builder: (context, value, child) =>
                  Opacity(opacity: 0.2 + value * 0.8, child: child),
            );
      }),
    );
  }
}

// ── Painters ──────────────────────────────────────────────────────────────────

class _SplashScanlinePainter extends CustomPainter {
  final double progress;
  _SplashScanlinePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white.withValues(alpha: 0.016)
      ..strokeWidth = 1;
    for (double y = 0; y < size.height; y += 3) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
    // moving sweep
    final hy = size.height * progress;
    canvas.drawLine(
      Offset(0, hy),
      Offset(size.width, hy),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.035)
        ..strokeWidth = 40
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
    );
  }

  @override
  bool shouldRepaint(_SplashScanlinePainter old) => old.progress != progress;
}
