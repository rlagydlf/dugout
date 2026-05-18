import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_theme.dart';
import '../../app/theme/tokens.dart';
import '../../app/theme/typography.dart';
import '../../core/providers/app_providers.dart';
import '../../shared/widgets/d_button.dart';
import '../../shared/widgets/d_effects.dart';
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

  // 3-step stepper
  int _step = 0; // 0=이메일, 1=비밀번호, 2=약관
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
    if (!_agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('필수 약관에 동의해 주세요.',
              style: DType.body(14).copyWith(color: Colors.white)),
          backgroundColor: DTokens.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DTokens.r12)),
        ),
      );
      return;
    }
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    ref.read(userProvider.notifier).becomeDemo();
    ref.read(authProvider.notifier).signIn();
    context.go('/auth/team');
  }

  void _nextStep() {
    if (_step == 0) {
      if (_email.text.isEmpty || !_email.text.contains('@')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('올바른 이메일을 입력해 주세요.',
                style: DType.body(14).copyWith(color: Colors.white)),
            backgroundColor: DTokens.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    } else if (_step == 1) {
      if (_password.text.length < 8) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('비밀번호는 8자 이상이어야 합니다.',
                style: DType.body(14).copyWith(color: Colors.white)),
            backgroundColor: DTokens.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    }
    if (_step < 2) setState(() => _step++);
  }

  @override
  Widget build(BuildContext context) {
    final team = context.team;

    return Scaffold(
      backgroundColor: DTokens.bgDark,
      body: Stack(
        children: [
          // ── 팀 컬러 상단 글로우
          Positioned(
            top: -80,
            left: -80,
            right: -80,
            child: Container(
              height: 300,
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

          // ── diamond grid
          Positioned.fill(
            child: CustomPaint(
              painter: DDiamondGridPainter(
                team.primary.withValues(alpha: 0.03),
                step: 44,
              ),
            ),
          ),

          // ── scanline
          Positioned.fill(
            child: CustomPaint(painter: DScanlinePainter()),
          ),

          SafeArea(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // ── 헤더
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                        DTokens.s24, DTokens.s16, DTokens.s24, 0),
                    child: _Header(team: team),
                  ),

                  const SizedBox(height: DTokens.s24),

                  // ── 스텝 인디케이터
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: DTokens.s24),
                    child: _StepIndicator(
                        currentStep: _step, team: team),
                  ),

                  const SizedBox(height: DTokens.s32),

                  // ── 스텝 콘텐츠
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, anim) => SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.08, 0),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                            parent: anim, curve: Curves.easeOutCubic)),
                        child: FadeTransition(opacity: anim, child: child),
                      ),
                      child: _buildStepContent(team),
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
                    child: _step < 2
                        ? DButton(
                            label: '다음',
                            icon: Icons.arrow_forward_rounded,
                            onPressed: _nextStep,
                          )
                        : DButton(
                            label: '가입하고 응원팀 선택하기',
                            icon: Icons.sports_baseball_rounded,
                            loading: _loading,
                            onPressed: _submit,
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent(dynamic team) {
    switch (_step) {
      case 0:
        return _EmailStep(
            key: const ValueKey('email'), email: _email, team: team);
      case 1:
        return _PasswordStep(
          key: const ValueKey('password'),
          password: _password,
          passwordVisible: _passwordVisible,
          onToggle: () =>
              setState(() => _passwordVisible = !_passwordVisible),
          team: team,
        );
      default:
        return _AgreementStep(
          key: const ValueKey('agree'),
          agreeTerms: _agreeTerms,
          agreeMarketing: _agreeMarketing,
          onTermsChanged: (v) => setState(() => _agreeTerms = v),
          onMarketingChanged: (v) => setState(() => _agreeMarketing = v),
          team: team,
        );
    }
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
            Text(
              'JOIN DUGOUT',
              style: DType.label(11,
                  color: (team.primary as Color).withValues(alpha: 0.8),
                  letterSpacing: 2.5),
            ),
            Text('회원가입', style: DType.heading(22, color: Colors.white)),
          ],
        ),
      ],
    ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.06);
  }
}

// ── Step indicator ────────────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  final dynamic team;
  const _StepIndicator({required this.currentStep, required this.team});

  static const _labels = ['이메일', '비밀번호', '약관 동의'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(3, (i) {
        final isActive = i == currentStep;
        final isDone = i < currentStep;
        final color = team.primary as Color;

        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: 2,
                            color: isDone || isActive
                                ? color
                                : DTokens.borderDark,
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDone
                                ? color
                                : isActive
                                    ? color.withValues(alpha: 0.15)
                                    : DTokens.surfaceDark2,
                            border: Border.all(
                              color: isDone || isActive
                                  ? color
                                  : DTokens.borderDark,
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: isDone
                                ? const Icon(Icons.check_rounded,
                                    size: 14, color: Colors.white)
                                : Text(
                                    '${i + 1}',
                                    style: DType.label(12,
                                        color: isActive
                                            ? color
                                            : DTokens.textTertiaryDark),
                                  ),
                          ),
                        ),
                        Expanded(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: 2,
                            color:
                                isDone ? color : DTokens.borderDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: DTokens.s4),
                    Text(
                      _labels[i],
                      style: DType.caption(11,
                          color: isActive
                              ? color
                              : DTokens.textTertiaryDark),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

// ── Step 0: Email ─────────────────────────────────────────────────────────────

class _EmailStep extends StatelessWidget {
  final TextEditingController email;
  final dynamic team;
  const _EmailStep(
      {super.key, required this.email, required this.team});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DTokens.s24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '이메일로\n시작하세요',
            style: DType.heading(28, color: Colors.white),
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.08),
          const SizedBox(height: DTokens.s8),
          Text(
            '더그아웃 계정에 사용할 이메일을 입력하세요.',
            style: DType.body(14)
                .copyWith(color: Colors.white.withValues(alpha: 0.6)),
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: DTokens.s32),
          Text(
            'EMAIL ADDRESS',
            style: DType.label(11,
                color: (team.primary as Color).withValues(alpha: 0.85),
                letterSpacing: 2),
          ),
          const SizedBox(height: DTokens.s8),
          _SignupField(
            controller: email,
            keyboardType: TextInputType.emailAddress,
            hintText: 'fan@dugout.app',
            prefixIcon: Icons.email_outlined,
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.06),
        ],
      ),
    );
  }
}

// ── Step 1: Password ──────────────────────────────────────────────────────────

class _PasswordStep extends StatelessWidget {
  final TextEditingController password;
  final bool passwordVisible;
  final VoidCallback onToggle;
  final dynamic team;
  const _PasswordStep({
    super.key,
    required this.password,
    required this.passwordVisible,
    required this.onToggle,
    required this.team,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DTokens.s24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '안전한 비밀번호를\n설정하세요',
            style: DType.heading(28, color: Colors.white),
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.08),
          const SizedBox(height: DTokens.s8),
          Text(
            '영문, 숫자 포함 8자 이상을 권장합니다.',
            style: DType.body(14)
                .copyWith(color: Colors.white.withValues(alpha: 0.6)),
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: DTokens.s32),
          Text(
            'PASSWORD',
            style: DType.label(11,
                color: (team.primary as Color).withValues(alpha: 0.85),
                letterSpacing: 2),
          ),
          const SizedBox(height: DTokens.s8),
          _SignupField(
            controller: password,
            obscureText: !passwordVisible,
            hintText: '8자 이상 입력',
            prefixIcon: Icons.lock_outline,
            suffixIcon: GestureDetector(
              onTap: onToggle,
              child: Icon(
                passwordVisible
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                size: 18,
                color: DTokens.textTertiaryDark,
              ),
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.06),
        ],
      ),
    );
  }
}

// ── Step 2: Agreement ─────────────────────────────────────────────────────────

class _AgreementStep extends StatelessWidget {
  final bool agreeTerms;
  final bool agreeMarketing;
  final ValueChanged<bool> onTermsChanged;
  final ValueChanged<bool> onMarketingChanged;
  final dynamic team;
  const _AgreementStep({
    super.key,
    required this.agreeTerms,
    required this.agreeMarketing,
    required this.onTermsChanged,
    required this.onMarketingChanged,
    required this.team,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DTokens.s24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '약관에\n동의해 주세요',
            style: DType.heading(28, color: Colors.white),
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.08),
          const SizedBox(height: DTokens.s8),
          Text(
            '마지막 단계입니다. 아래 약관을 확인해 주세요.',
            style: DType.body(14)
                .copyWith(color: Colors.white.withValues(alpha: 0.6)),
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: DTokens.s28),
          DGlassPanel(
            padding: const EdgeInsets.all(DTokens.s16),
            radius: DTokens.r20,
            child: Column(
              children: [
                _AgreeRow(
                  label: '(필수) 만 14세 이상, 이용약관 및 개인정보 처리방침 동의',
                  value: agreeTerms,
                  color: team.primary as Color,
                  onChanged: onTermsChanged,
                ),
                const SizedBox(height: DTokens.s4),
                Divider(color: DTokens.borderDark.withValues(alpha: 0.5)),
                const SizedBox(height: DTokens.s4),
                _AgreeRow(
                  label: '(선택) 마케팅 및 이벤트 알림 수신 동의',
                  value: agreeMarketing,
                  color: DTokens.textSecondaryDark,
                  onChanged: onMarketingChanged,
                ),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms),
        ],
      ),
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _SignupField extends StatelessWidget {
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String hintText;
  final IconData prefixIcon;
  final Widget? suffixIcon;

  const _SignupField({
    required this.controller,
    this.keyboardType,
    this.obscureText = false,
    required this.hintText,
    required this.prefixIcon,
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
        hintText: hintText,
        hintStyle: DType.mono(14,
            color: Colors.white.withValues(alpha: 0.25),
            weight: FontWeight.w400),
        prefixIcon: Icon(prefixIcon, size: 18, color: team.primary),
        suffixIcon: suffixIcon != null
            ? Padding(
                padding: const EdgeInsets.only(right: 12),
                child: suffixIcon,
              )
            : null,
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
                color: value ? color.withValues(alpha: 0.18) : Colors.transparent,
                border: Border.all(
                  color: value ? color : DTokens.textTertiaryDark,
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
                style: DType.body(14).copyWith(
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
