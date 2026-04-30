import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_theme.dart';
import '../../app/theme/tokens.dart';
import '../../app/theme/typography.dart';
import '../../shared/widgets/d_button.dart';
import '../../shared/widgets/d_glass_panel.dart';

class AuthScreen extends ConsumerWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final team = context.team;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: DTokens.bgDark,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── 야구장 배경 mood 이미지
          Positioned.fill(
            child: Image.asset(
              team.moodAsset,
              fit: BoxFit.cover,
              errorBuilder: (e, s, t) => DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.topCenter,
                    radius: 1.5,
                    colors: [
                      team.primary.withValues(alpha: 0.35),
                      DTokens.bgDark,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── 다크 오버레이 (가독성)
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.55),
                    DTokens.bgDark.withValues(alpha: 0.88),
                    DTokens.bgDark,
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),
          ),

          // ── 스캔라인 텍스처
          Positioned.fill(
            child: CustomPaint(painter: _StaticScanlinePainter()),
          ),

          // ── 야구 아이콘 배경 (right side)
          Positioned(
            right: -size.width * 0.15,
            top: size.height * 0.08,
            child: Opacity(
              opacity: 0.06,
              child: Image.asset(
                'assets/images/icons/baseball.png',
                width: size.width * 0.85,
                errorBuilder: (e, s, t) => const SizedBox.shrink(),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: DTokens.s24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── 상단 더그아웃 로고 영역
                  const SizedBox(height: DTokens.s40),
                  _LogoBlock(team: team),

                  const Spacer(flex: 2),

                  // ── 히어로 텍스트
                  _HeroText(team: team),

                  const Spacer(flex: 3),

                  // ── 버튼 영역 (glass panel 안에)
                  _ActionPanel(team: team),

                  const SizedBox(height: DTokens.s24),

                  // ── 약관 고지
                  Text(
                    '계속 진행 시 더그아웃 약관 및 개인정보 처리방침에 동의합니다.',
                    textAlign: TextAlign.center,
                    style: DType.label(11,
                        color: Colors.white.withValues(alpha: 0.6)),
                  ).animate().fadeIn(delay: 900.ms),

                  const SizedBox(height: DTokens.s32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Logo block ────────────────────────────────────────────────────────────────

class _LogoBlock extends StatelessWidget {
  final dynamic team;
  const _LogoBlock({required this.team});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: (team.primary as Color).withValues(alpha: 0.6),
              width: 1.5,
            ),
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.cover,
              errorBuilder: (e, s, t) => Icon(
                Icons.sports_baseball_rounded,
                size: 20,
                color: team.primary as Color,
              ),
            ),
          ),
        ),
        const SizedBox(width: DTokens.s12),
        Text(
          'DUGOUT',
          style: DType.impact(22,
              color: Colors.white, letterSpacing: 5),
        ),
      ],
    ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.08);
  }
}

// ── Hero text ─────────────────────────────────────────────────────────────────

class _HeroText extends StatelessWidget {
  final dynamic team;
  const _HeroText({required this.team});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'WELCOME',
          style: DType.label(11,
              color: (team.primary as Color).withValues(alpha: 0.8)),
        )
            .animate()
            .fadeIn(delay: 200.ms, duration: 500.ms),

        const SizedBox(height: DTokens.s8),

        // 한글 대형 헤딩
        Text(
          '더그아웃에\n오신 걸\n환영합니다',
          style: DType.heading(38, color: Colors.white),
        )
            .animate()
            .fadeIn(delay: 350.ms, duration: 600.ms)
            .slideY(begin: 0.12, curve: Curves.easeOutCubic),

        const SizedBox(height: DTokens.s16),

        // 서브 copy
        Row(
          children: [
            Container(
              width: 3,
              height: 16,
              decoration: BoxDecoration(
                color: (team.primary as Color),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: DTokens.s8),
            Text(
              '응원과 참여, 그리고 보상까지',
              style: DType.body(16).copyWith(
                color: Colors.white.withValues(alpha: 0.75),
              ),
            ),
          ],
        ).animate().fadeIn(delay: 550.ms, duration: 500.ms),
      ],
    );
  }
}

// ── Action panel ──────────────────────────────────────────────────────────────

class _ActionPanel extends StatelessWidget {
  final dynamic team;
  const _ActionPanel({required this.team});

  @override
  Widget build(BuildContext context) {
    return DGlassPanel(
      teamBorder: true,
      blur: 24,
      opacity: 0.45,
      radius: DTokens.r24,
      padding: const EdgeInsets.all(DTokens.s20),
      child: Column(
        children: [
          // START label
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 24,
                height: 1,
                color: Colors.white.withValues(alpha: 0.2),
              ),
              const SizedBox(width: DTokens.s8),
              Text(
                'GET STARTED',
                style: DType.label(12,
                    color: Colors.white.withValues(alpha: 0.7)),
              ),
              const SizedBox(width: DTokens.s8),
              Container(
                width: 24,
                height: 1,
                color: Colors.white.withValues(alpha: 0.2),
              ),
            ],
          ),
          const SizedBox(height: DTokens.s16),

          DButton(
            label: '시작하기 (회원가입)',
            icon: Icons.arrow_forward_rounded,
            onPressed: () => context.push('/auth/signup'),
          ),

          const SizedBox(height: DTokens.s12),

          DButton(
            label: '이미 계정이 있어요',
            variant: DButtonVariant.outline,
            onPressed: () => context.push('/auth/login'),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 650.ms, duration: 500.ms)
        .slideY(begin: 0.15, curve: Curves.easeOutCubic);
  }
}

// ── Painters ──────────────────────────────────────────────────────────────────

class _StaticScanlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.015)
      ..strokeWidth = 1;
    for (double y = 0; y < size.height; y += 3) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
