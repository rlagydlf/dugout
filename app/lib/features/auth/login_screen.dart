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

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController(text: 'fan@dugout.app');
  final _password = TextEditingController(text: 'demo1234');
  bool _loading = false;
  bool _passwordVisible = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    ref.read(userProvider.notifier).becomeDemo();
    ref.read(authProvider.notifier).signIn();
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final team = context.team;
    return Scaffold(
      backgroundColor: DTokens.bgDark,
      body: Stack(
        children: [
          // ── 우상단 야구 아이콘 배경
          Positioned(
            top: -40,
            right: -60,
            child: Opacity(
              opacity: 0.05,
              child: Image.asset(
                'assets/images/icons/helmet.png',
                width: 260,
                errorBuilder: (e, s, t) => const SizedBox.shrink(),
              ),
            ),
          ),

          // ── 팀 컬러 상단 글로우
          Positioned(
            top: -100,
            left: -50,
            right: -50,
            child: Container(
              height: 300,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topRight,
                  radius: 0.85,
                  colors: [
                    team.primary.withValues(alpha: 0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── 스캔라인
          Positioned.fill(
            child: CustomPaint(painter: _LoginScanlinePainter()),
          ),

          SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: DTokens.s24),
              children: [
                const SizedBox(height: DTokens.s16),

                // ── 뒤로 + 헤더
                _Header(team: team),

                const SizedBox(height: DTokens.s48),

                // ── 스코어보드 스타일 환영 텍스트
                _WelcomeBlock(team: team),

                const SizedBox(height: DTokens.s40),

                // ── 로그인 폼
                _LoginForm(
                  email: _email,
                  password: _password,
                  passwordVisible: _passwordVisible,
                  onTogglePassword: () =>
                      setState(() => _passwordVisible = !_passwordVisible),
                  loading: _loading,
                  onSubmit: _submit,
                  team: team,
                ),

                const SizedBox(height: DTokens.s24),

                // ── 비밀번호 찾기
                Center(
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      '비밀번호를 잊으셨나요?',
                      style: DType.body(15).copyWith(
                        color: team.primary.withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 700.ms),

                const SizedBox(height: DTokens.s16),

                // ── demo notice
                _DemoNotice(team: team),

                const SizedBox(height: DTokens.s48),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final dynamic team;
  const _Header({required this.team});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).maybePop(),
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
        const SizedBox(width: DTokens.s16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('WELCOME BACK',
                style: DType.label(12,
                    color: (team.primary as Color).withValues(alpha: 0.8))),
            Text('로그인', style: DType.heading(22, color: Colors.white)),
          ],
        ),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }
}

// ── Welcome block ─────────────────────────────────────────────────────────────

class _WelcomeBlock extends StatelessWidget {
  final dynamic team;
  const _WelcomeBlock({required this.team});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // VT323 LED 스타일 텍스트
        ShaderMask(
          shaderCallback: (rect) => LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, (team.primary as Color)],
          ).createShader(rect),
          child: Text(
            '돌아오신 걸\n환영합니다',
            style: DType.heading(34, color: Colors.white),
          ),
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

        const SizedBox(height: DTokens.s12),

        // 이미 가입한 팬을 위한 서브카피
        Row(
          children: [
            Image.asset(
              'assets/images/icons/megaphone.png',
              width: 16,
              height: 16,
              errorBuilder: (e, s, t) => Icon(
                Icons.campaign_rounded,
                size: 16,
                color: (team.primary as Color).withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(width: DTokens.s8),
            Text(
              '팬들이 기다리고 있습니다',
              style: DType.body(16).copyWith(
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ],
        ).animate().fadeIn(delay: 400.ms),
      ],
    );
  }
}

// ── Login form ────────────────────────────────────────────────────────────────

class _LoginForm extends StatelessWidget {
  final TextEditingController email;
  final TextEditingController password;
  final bool passwordVisible;
  final VoidCallback onTogglePassword;
  final bool loading;
  final VoidCallback onSubmit;
  final dynamic team;

  const _LoginForm({
    required this.email,
    required this.password,
    required this.passwordVisible,
    required this.onTogglePassword,
    required this.loading,
    required this.onSubmit,
    required this.team,
  });

  @override
  Widget build(BuildContext context) {
    return DGlassPanel(
      teamBorder: true,
      padding: const EdgeInsets.all(DTokens.s20),
      radius: DTokens.r24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 이메일
          Text('EMAIL',
              style: DType.label(12,
                  color: (team.primary as Color).withValues(alpha: 0.8))),
          const SizedBox(height: DTokens.s8),
          _LoginField(
            controller: email,
            keyboardType: TextInputType.emailAddress,
            prefixAsset: 'assets/images/icons/baseball.png',
            prefixFallback: Icons.email_outlined,
          ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.06),

          const SizedBox(height: DTokens.s20),

          // 비밀번호
          Text('PASSWORD',
              style: DType.label(12,
                  color: (team.primary as Color).withValues(alpha: 0.8))),
          const SizedBox(height: DTokens.s8),
          _LoginField(
            controller: password,
            obscureText: !passwordVisible,
            prefixAsset: 'assets/images/icons/mitt.png',
            prefixFallback: Icons.lock_outline,
            suffixIcon: GestureDetector(
              onTap: onTogglePassword,
              child: Icon(
                passwordVisible
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                size: 18,
                color: DTokens.textTertiaryDark,
              ),
            ),
          ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.06),

          const SizedBox(height: DTokens.s24),

          // 로그인 버튼
          DButton(
            label: '로그인',
            loading: loading,
            onPressed: onSubmit,
            icon: Icons.sports_baseball_rounded,
          ).animate().fadeIn(delay: 700.ms),
        ],
      ),
    ).animate().fadeIn(delay: 450.ms).slideY(begin: 0.12);
  }
}

// ── Login field ───────────────────────────────────────────────────────────────

class _LoginField extends StatelessWidget {
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String prefixAsset;
  final IconData prefixFallback;
  final Widget? suffixIcon;

  const _LoginField({
    required this.controller,
    this.keyboardType,
    this.obscureText = false,
    required this.prefixAsset,
    required this.prefixFallback,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final team = context.team;
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: DType.mono(14, color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: const EdgeInsets.all(14),
          child: Image.asset(
            prefixAsset,
            width: 18,
            height: 18,
            errorBuilder: (e, s, t) =>
                Icon(prefixFallback, size: 18, color: team.primary),
          ),
        ),
        suffixIcon: suffixIcon != null
            ? Padding(
                padding: const EdgeInsets.only(right: 12),
                child: suffixIcon,
              )
            : null,
        prefixIconColor: team.primary,
        filled: true,
        fillColor: DTokens.surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DTokens.r12),
          borderSide: const BorderSide(color: DTokens.borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DTokens.r12),
          borderSide: const BorderSide(color: DTokens.borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DTokens.r12),
          borderSide: BorderSide(color: team.primary, width: 1.5),
        ),
      ),
    );
  }
}

// ── Demo notice ───────────────────────────────────────────────────────────────

class _DemoNotice extends StatelessWidget {
  final dynamic team;
  const _DemoNotice({required this.team});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DTokens.s12),
      decoration: BoxDecoration(
        color: (team.primary as Color).withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(DTokens.r12),
        border: Border.all(
          color: (team.primary as Color).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded,
              size: 14,
              color: (team.primary as Color).withValues(alpha: 0.7)),
          const SizedBox(width: DTokens.s8),
          Expanded(
            child: Text(
              '데모 모드: fan@dugout.app / demo1234 로 바로 진입합니다.',
              style: DType.label(12,
                  color: Colors.white.withValues(alpha: 0.7)),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 800.ms);
  }
}

// ── Painter ───────────────────────────────────────────────────────────────────

class _LoginScanlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.012)
      ..strokeWidth = 1;
    for (double y = 0; y < size.height; y += 3) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
