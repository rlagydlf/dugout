import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_theme.dart';
import '../../app/theme/tokens.dart';
import '../../shared/widgets/d_button.dart';

class ErrorScreen extends ConsumerWidget {
  final int? statusCode;
  final String? message;
  const ErrorScreen({super.key, this.statusCode, this.message});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final team = context.team;
    final code = statusCode ?? 500;
    final is4xx = code >= 400 && code < 500;

    final (icon, title, subtitle) = switch (code) {
      404 => (
          Icons.search_off_rounded,
          '페이지를 찾을 수 없어요',
          '요청하신 페이지가 존재하지 않거나 이동되었습니다.',
        ),
      403 => (
          Icons.lock_rounded,
          '접근 권한이 없어요',
          '이 페이지에 접근할 권한이 없습니다.',
        ),
      401 => (
          Icons.no_accounts_rounded,
          '로그인이 필요해요',
          '로그인 후 이용 가능한 기능입니다.',
        ),
      _ => (
          Icons.cloud_off_rounded,
          '서버에 문제가 생겼어요',
          '잠시 후 다시 시도해 주세요. 문제가 지속되면 고객센터로 문의해 주세요.',
        ),
    };

    return Scaffold(
      appBar: AppBar(
        title: Text('오류 $code'),
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => context.pop(),
              )
            : null,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(DTokens.s32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 아이콘 글로우
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          (is4xx ? team.primary : DTokens.danger).withValues(alpha: 0.15),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: (is4xx ? team.primary : DTokens.danger).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: (is4xx ? team.primary : DTokens.danger).withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      icon,
                      size: 44,
                      color: is4xx ? team.primary : DTokens.danger,
                    ),
                  ),
                ],
              )
                  .animate()
                  .scale(begin: const Offset(0.6, 0.6), curve: Curves.elasticOut, duration: 700.ms)
                  .fadeIn(),

              const SizedBox(height: DTokens.s32),

              Text(
                '$code',
                style: TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.w900,
                  color: (is4xx ? team.primary : DTokens.danger).withValues(alpha: 0.2),
                  height: 1.0,
                ),
              ).animate().fadeIn(delay: 100.ms),

              const SizedBox(height: DTokens.s8),

              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.1),

              const SizedBox(height: DTokens.s12),

              Text(
                message ?? subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: DTokens.textSecondaryDark,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: DTokens.s40),

              DButton(
                label: '홈으로 돌아가기',
                icon: Icons.home_rounded,
                fullWidth: false,
                onPressed: () => context.go('/home'),
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),

              if (Navigator.of(context).canPop()) ...[
                const SizedBox(height: DTokens.s12),
                DButton(
                  label: '이전 화면으로',
                  icon: Icons.arrow_back_rounded,
                  variant: DButtonVariant.ghost,
                  fullWidth: false,
                  onPressed: () => context.pop(),
                ).animate().fadeIn(delay: 350.ms),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
