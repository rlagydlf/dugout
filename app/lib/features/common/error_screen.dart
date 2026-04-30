import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_theme.dart';
import '../../app/theme/tokens.dart';
import '../../app/theme/typography.dart';
import '../../shared/widgets/d_button.dart';
import '../../shared/widgets/d_effects.dart';

class ErrorScreen extends ConsumerWidget {
  final int? statusCode;
  final String? message;
  const ErrorScreen({super.key, this.statusCode, this.message});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final team = context.team;
    final code = statusCode ?? 500;
    final is4xx = code >= 400 && code < 500;
    final glowColor = is4xx ? team.primary : DTokens.danger;

    final (errorLabel, title, subtitle) = _errorMeta(code);

    return Scaffold(
      backgroundColor: DTokens.bgDark,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── 배경 radial glow
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topCenter,
                radius: 1.4,
                colors: [
                  glowColor.withValues(alpha: 0.12),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // ── diamond grid (절제)
          Positioned.fill(
            child: CustomPaint(
              painter: DDiamondGridPainter(
                glowColor.withValues(alpha: 0.03),
                step: 44,
              ),
            ),
          ),

          // ── 야구공 배경 (대형 반투명)
          Positioned(
            top: -40,
            right: -60,
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.04,
                child: Image.asset(
                  'assets/images/icons/baseball.png',
                  width: 280,
                  errorBuilder: (e, s, t) => const SizedBox.shrink(),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(DTokens.s32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ── 야구공 글로우 아이콘
                    _ErrorGlow(
                      code: code,
                      color: glowColor,
                      is4xx: is4xx,
                    )
                        .animate()
                        .scale(
                          begin: const Offset(0.5, 0.5),
                          duration: 700.ms,
                          curve: Curves.easeOutBack,
                        )
                        .fadeIn(),

                    const SizedBox(height: DTokens.s24),

                    // ── 에러 코드 — Anton (영문/숫자)
                    Text(
                      errorLabel,
                      style: DType.impact(72,
                          color: glowColor.withValues(alpha: 0.2),
                          letterSpacing: 4),
                    ).animate().fadeIn(delay: 100.ms),

                    const SizedBox(height: DTokens.s4),

                    // ── 제목 — Pretendard heading
                    Text(
                      title,
                      style: DType.heading(22, color: Colors.white),
                      textAlign: TextAlign.center,
                    )
                        .animate()
                        .fadeIn(delay: 160.ms)
                        .slideY(begin: 0.08),

                    const SizedBox(height: DTokens.s12),

                    Text(
                      message ?? subtitle,
                      style: DType.body(14).copyWith(
                        color: DTokens.textSecondaryDark,
                        height: 1.65,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 220.ms),

                    const SizedBox(height: DTokens.s40),

                    DButton(
                      label: '홈으로 돌아가기',
                      icon: Icons.home_rounded,
                      fullWidth: false,
                      onPressed: () => context.go('/home'),
                    ).animate().fadeIn(delay: 320.ms).slideY(begin: 0.08),

                    if (Navigator.of(context).canPop()) ...[
                      const SizedBox(height: DTokens.s12),
                      DButton(
                        label: '이전 화면으로',
                        icon: Icons.arrow_back_rounded,
                        variant: DButtonVariant.ghost,
                        fullWidth: false,
                        onPressed: () => context.pop(),
                      ).animate().fadeIn(delay: 370.ms),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static (String, String, String) _errorMeta(int code) => switch (code) {
        404 => (
            'ERROR 404',
            '페이지를 찾을 수 없어요',
            '요청하신 페이지가 존재하지 않거나 이동되었습니다.',
          ),
        403 => (
            'ERROR 403',
            '접근 권한이 없어요',
            '이 페이지에 접근할 권한이 없습니다.',
          ),
        401 => (
            'ERROR 401',
            '로그인이 필요해요',
            '로그인 후 이용 가능한 기능입니다.',
          ),
        408 => (
            'TIMEOUT',
            '응답 시간이 초과됐어요',
            '네트워크 상태를 확인하고 다시 시도해 주세요.',
          ),
        _ => (
            'ERROR $code',
            '서버에 문제가 생겼어요',
            '잠시 후 다시 시도해 주세요. 문제가 지속되면 고객센터로 문의해 주세요.',
          ),
      };
}

// ── 야구공 글로우 이펙트 ──────────────────────────────────────────────────────

class _ErrorGlow extends StatefulWidget {
  final int code;
  final Color color;
  final bool is4xx;
  const _ErrorGlow(
      {required this.code, required this.color, required this.is4xx});

  @override
  State<_ErrorGlow> createState() => _ErrorGlowState();
}

class _ErrorGlowState extends State<_ErrorGlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // outer glow ring
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withValues(
                        alpha: 0.15 + _pulse.value * 0.18),
                    blurRadius: 48 + _pulse.value * 24,
                    spreadRadius: _pulse.value * 8,
                  ),
                ],
              ),
            ),
            // inner circle
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: widget.color
                      .withValues(alpha: 0.3 + _pulse.value * 0.2),
                  width: 1.5,
                ),
              ),
              child: widget.is4xx
                  ? Image.asset(
                      'assets/images/icons/baseball.png',
                      fit: BoxFit.contain,
                      errorBuilder: (e, s, t) => Icon(
                        Icons.search_off_rounded,
                        size: 44,
                        color: widget.color,
                      ),
                    )
                  : Icon(
                      Icons.cloud_off_rounded,
                      size: 44,
                      color: widget.color,
                    ),
            ),
          ],
        );
      },
    );
  }
}
