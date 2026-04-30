import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_theme.dart';
import '../../app/theme/theme_provider.dart';
import '../../app/theme/tokens.dart';
import '../../app/theme/typography.dart';
import '../../core/providers/app_providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});
  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scanCtrl;

  @override
  void initState() {
    super.initState();
    _scanCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    Future.delayed(const Duration(milliseconds: 2200), () {
      if (!mounted) return;
      // 진짜 처음부터 — 응원팀 미선택 / 미로그인 상태로 /auth 진입
      ref.read(currentTeamProvider.notifier).reset();
      context.go("/auth");
    });
  }

  @override
  void dispose() {
    _scanCtrl.dispose();
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
          // ── 3-stop radial glow (팀 컬러 조명)
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.3),
                radius: 1.2,
                colors: [
                  team.primary.withValues(alpha: 0.28),
                  team.primary.withValues(alpha: 0.06),
                  DTokens.bgDark,
                ],
                stops: const [0.0, 0.45, 1.0],
              ),
            ),
          ),

          // ── 스캔라인 오버레이 (치지직 CRT 느낌)
          AnimatedBuilder(
            animation: _scanCtrl,
            builder: (context, _) {
              return CustomPaint(
                painter: _ScanlinePainter(_scanCtrl.value),
              );
            },
          ),

          // ── 좌상단 + 우하단 다이아몬드 배경 패턴
          Positioned.fill(
            child: CustomPaint(
              painter: _DiamondBgPainter(team.primary.withValues(alpha: 0.04)),
            ),
          ),

          // ── 메인 콘텐츠
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 야구공 아이콘 + 글로우 링
                _GlowCrest(team: team),

                const SizedBox(height: DTokens.s32),

                // DUGOUT — Anton impact
                ShaderMask(
                  shaderCallback: (rect) => LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.white, team.primary],
                    stops: const [0.3, 1.0],
                  ).createShader(rect),
                  child: Text(
                    'DUGOUT',
                    style: DType.impact(56, letterSpacing: 12),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 350.ms, duration: 700.ms)
                    .slideY(begin: 0.15, curve: Curves.easeOutCubic),

                const SizedBox(height: DTokens.s8),

                // 슬로건 — body
                Text(
                  '응원, 그 이상의 행동',
                  style: DType.body(14).copyWith(
                    color: Colors.white.withValues(alpha: 0.55),
                    letterSpacing: 2.5,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 700.ms, duration: 600.ms),

                const SizedBox(height: DTokens.s48),

                // LED 로딩 도트
                _LedDots(color: team.primary)
                    .animate()
                    .fadeIn(delay: 900.ms, duration: 500.ms),
              ],
            ),
          ),

          // ── 하단 버전
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Text(
              'v1.0.0  ·  KBO 2026',
              textAlign: TextAlign.center,
              style: DType.micro(10, color: Colors.white.withValues(alpha: 0.2)),
            ).animate().fadeIn(delay: 1200.ms, duration: 500.ms),
          ),
        ],
      ),
    );
  }
}

// ── Glow crest ────────────────────────────────────────────────────────────────

class _GlowCrest extends StatelessWidget {
  final dynamic team;
  const _GlowCrest({required this.team});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // outer glow ring
        Container(
          width: 156,
          height: 156,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: (team.primary as Color).withValues(alpha: 0.5),
                blurRadius: 64,
                spreadRadius: 8,
              ),
            ],
          ),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .custom(
              duration: 1800.ms,
              builder: (context, value, child) => Opacity(
                opacity: 0.6 + value * 0.4,
                child: child,
              ),
            ),

        // Logo image
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: (team.primary as Color).withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.cover,
              errorBuilder: (e, s, t) => Center(
                child: Image.asset(
                  'assets/images/icons/baseball.png',
                  width: 80,
                  errorBuilder: (e, s, t) => Icon(
                    Icons.sports_baseball_rounded,
                    size: 80,
                    color: team.primary as Color,
                  ),
                ),
              ),
            ),
          ),
        )
            .animate()
            .scale(
              begin: const Offset(0.6, 0.6),
              duration: 800.ms,
              curve: Curves.easeOutBack,
            )
            .fadeIn(duration: 500.ms),
      ],
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
          width: 6,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .fadeIn(
              delay: Duration(milliseconds: 180 * i),
              duration: 500.ms,
            )
            .custom(
              duration: 900.ms,
              builder: (context, value, child) => Opacity(
                opacity: 0.2 + value * 0.8,
                child: child,
              ),
            );
      }),
    );
  }
}

// ── Painters ──────────────────────────────────────────────────────────────────

class _ScanlinePainter extends CustomPainter {
  final double progress;
  _ScanlinePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.018)
      ..strokeWidth = 1;
    for (double y = 0; y < size.height; y += 3) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    // moving highlight
    final highlightY = size.height * progress;
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 60
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawLine(
      Offset(0, highlightY),
      Offset(size.width, highlightY),
      highlightPaint,
    );
  }

  @override
  bool shouldRepaint(_ScanlinePainter old) => old.progress != progress;
}

class _DiamondBgPainter extends CustomPainter {
  final Color color;
  _DiamondBgPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;
    const step = 36.0;
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
