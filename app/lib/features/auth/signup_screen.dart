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

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});
  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _agreeTerms = false;
  bool _agreeMarketing = false;
  bool _loading = false;
  bool _passwordVisible = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '필수 약관에 동의해 주세요.',
            style: DType.body(16).copyWith(color: Colors.white),
          ),
          backgroundColor: DTokens.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DTokens.r12),
          ),
        ),
      );
      return;
    }
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    ref.read(userProvider.notifier).becomeDemo();
    ref.read(authProvider.notifier).signIn();
    context.go('/auth/team');
  }

  @override
  Widget build(BuildContext context) {
    final team = context.team;
    return Scaffold(
      backgroundColor: DTokens.bgDark,
      body: Stack(
        children: [
          // ── 팀 컬러 글로우 상단
          Positioned(
            top: -80,
            left: -80,
            right: -80,
            child: Container(
              height: 280,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 0.9,
                  colors: [
                    team.primary.withValues(alpha: 0.22),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── 스캔라인
          Positioned.fill(
            child: CustomPaint(painter: _SignupScanlinePainter()),
          ),

          SafeArea(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: DTokens.s24),
                children: [
                  const SizedBox(height: DTokens.s16),

                  // ── Back + 헤더
                  _Header(team: team),

                  const SizedBox(height: DTokens.s32),

                  // ── 빠른 시작 배지
                  _SpeedBadge(team: team),

                  const SizedBox(height: DTokens.s24),

                  // ── 이메일 필드
                  _FieldLabel(label: 'EMAIL ADDRESS', team: team),
                  const SizedBox(height: DTokens.s8),
                  _StyledField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    hintText: 'fan@dugout.app',
                    prefixIcon: Image.asset(
                      'assets/images/icons/baseball.png',
                      width: 18,
                      height: 18,
                      errorBuilder: (e, s, t) =>
                          const Icon(Icons.email_outlined, size: 18),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return '이메일을 입력하세요.';
                      if (!v.contains('@')) return '올바른 이메일 형식이 아닙니다.';
                      return null;
                    },
                  ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.06),

                  const SizedBox(height: DTokens.s16),

                  // ── 비밀번호 필드
                  _FieldLabel(label: 'PASSWORD', team: team),
                  const SizedBox(height: DTokens.s8),
                  _StyledField(
                    controller: _password,
                    obscureText: !_passwordVisible,
                    hintText: '8자 이상 입력',
                    prefixIcon: Image.asset(
                      'assets/images/icons/mitt.png',
                      width: 18,
                      height: 18,
                      errorBuilder: (e, s, t) =>
                          const Icon(Icons.lock_outline, size: 18),
                    ),
                    suffixIcon: GestureDetector(
                      onTap: () =>
                          setState(() => _passwordVisible = !_passwordVisible),
                      child: Icon(
                        _passwordVisible
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        size: 18,
                        color: DTokens.textTertiaryDark,
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.length < 8) return '8자 이상 입력하세요.';
                      return null;
                    },
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.06),

                  const SizedBox(height: DTokens.s28),

                  // ── 약관 동의
                  DGlassPanel(
                    teamBorder: false,
                    padding: const EdgeInsets.all(DTokens.s16),
                    radius: DTokens.r16,
                    child: Column(
                      children: [
                        _AgreeRow(
                          label: '(필수) 만 14세 이상, 약관 및 개인정보 처리방침 동의',
                          value: _agreeTerms,
                          color: team.primary,
                          onChanged: (v) => setState(() => _agreeTerms = v),
                        ),
                        const SizedBox(height: DTokens.s4),
                        Divider(
                          color: DTokens.borderDark,
                          height: 1,
                        ),
                        const SizedBox(height: DTokens.s4),
                        _AgreeRow(
                          label: '(선택) 마케팅 및 이벤트 알림 수신 동의',
                          value: _agreeMarketing,
                          color: DTokens.textSecondaryDark,
                          onChanged: (v) =>
                              setState(() => _agreeMarketing = v),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 500.ms),

                  const SizedBox(height: DTokens.s32),

                  // ── CTA 버튼
                  DButton(
                    label: '가입하고 응원팀 선택하기',
                    loading: _loading,
                    onPressed: _submit,
                    icon: Icons.arrow_forward_rounded,
                  ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.08),

                  const SizedBox(height: DTokens.s48),
                ],
              ),
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
            Text('JOIN DUGOUT',
                style: DType.label(12,
                    color: (team.primary as Color).withValues(alpha: 0.8))),
            Text('회원가입', style: DType.heading(22, color: Colors.white)),
          ],
        ),
      ],
    ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.06);
  }
}

// ── Speed badge ───────────────────────────────────────────────────────────────

class _SpeedBadge extends StatelessWidget {
  final dynamic team;
  const _SpeedBadge({required this.team});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: DTokens.s16, vertical: DTokens.s12),
      decoration: BoxDecoration(
        color: (team.primary as Color).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DTokens.r16),
        border: Border.all(
          color: (team.primary as Color).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/images/icons/bolt.png',
            width: 20,
            height: 20,
            errorBuilder: (e, s, t) =>
                Icon(Icons.bolt_rounded, size: 20, color: team.primary as Color),
          ),
          const SizedBox(width: DTokens.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('최소 정보로 빠르게 시작',
                    style: DType.label(12, color: team.primary as Color)),
                const SizedBox(height: 2),
                Text('이메일과 비밀번호만 있으면 OK',
                    style: DType.body(14).copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                    )),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }
}

// ── Field label ───────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String label;
  final dynamic team;
  const _FieldLabel({required this.label, required this.team});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: DType.label(12,
          color: (team.primary as Color).withValues(alpha: 0.8)),
    );
  }
}

// ── Styled field ──────────────────────────────────────────────────────────────

class _StyledField extends StatelessWidget {
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  const _StyledField({
    required this.controller,
    this.keyboardType,
    this.obscureText = false,
    required this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final team = context.team;
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: DType.mono(14, color: Colors.white),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: DType.mono(14,
            color: Colors.white.withValues(alpha: 0.25),
            weight: FontWeight.w400),
        prefixIcon: prefixIcon != null
            ? Padding(
                padding: const EdgeInsets.all(14),
                child: prefixIcon,
              )
            : null,
        suffixIcon: suffixIcon != null
            ? Padding(
                padding: const EdgeInsets.only(right: 12),
                child: suffixIcon,
              )
            : null,
        prefixIconColor: team.primary,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DTokens.r12),
          borderSide: BorderSide(color: team.primary, width: 1.5),
        ),
      ),
      validator: validator,
    );
  }
}

// ── Agree row ─────────────────────────────────────────────────────────────────

class _AgreeRow extends StatelessWidget {
  final String label;
  final bool value;
  final Color color;
  final ValueChanged<bool> onChanged;
  const _AgreeRow({
    required this.label,
    required this.value,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(DTokens.r8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: DTokens.s8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    value ? color.withValues(alpha: 0.2) : Colors.transparent,
                border: Border.all(
                  color: value
                      ? color
                      : DTokens.textTertiaryDark,
                  width: 1.5,
                ),
              ),
              child: value
                  ? Icon(Icons.check_rounded, size: 13, color: color)
                  : null,
            ),
            const SizedBox(width: DTokens.s12),
            Expanded(
              child: Text(
                label,
                style: DType.body(15).copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Painter ───────────────────────────────────────────────────────────────────

class _SignupScanlinePainter extends CustomPainter {
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
