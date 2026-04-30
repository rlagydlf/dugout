import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/tokens.dart';
import '../../shared/widgets/d_button.dart';
import '../../shared/widgets/d_card.dart';

class BannedScreen extends ConsumerWidget {
  final String? reason;
  final String? bannedUntil;
  const BannedScreen({super.key, this.reason, this.bannedUntil});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayReason = reason ?? '서비스 이용약관 위반 (어뷰징 감지)';
    final displayUntil = bannedUntil ?? '2025-05-14';

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(DTokens.s20),
          child: Column(
            children: [
              const SizedBox(height: DTokens.s40),

              // 아이콘
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          DTokens.danger.withValues(alpha: 0.12),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: DTokens.danger.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: DTokens.danger.withValues(alpha: 0.35), width: 1.5),
                    ),
                    child: const Icon(
                      Icons.gavel_rounded,
                      size: 48,
                      color: DTokens.danger,
                    ),
                  ),
                ],
              )
                  .animate()
                  .scale(begin: const Offset(0.5, 0.5), curve: Curves.elasticOut, duration: 800.ms)
                  .fadeIn(),

              const SizedBox(height: DTokens.s24),

              const Text(
                '이용이 제한된 계정입니다',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

              const SizedBox(height: DTokens.s8),

              const Text(
                '아래 사유로 서비스 이용이 일시 제한되었습니다.',
                style: TextStyle(
                  fontSize: 14,
                  color: DTokens.textSecondaryDark,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 250.ms),

              const SizedBox(height: DTokens.s32),

              // 제재 상세 카드
              DCard(
                child: Column(
                  children: [
                    _InfoRow(
                      icon: Icons.report_rounded,
                      label: '제재 사유',
                      value: displayReason,
                      valueColor: DTokens.danger,
                    ),
                    const Divider(color: DTokens.borderDark, height: DTokens.s24),
                    _InfoRow(
                      icon: Icons.event_busy_rounded,
                      label: '제재 기간',
                      value: '$displayUntil 까지',
                      valueColor: DTokens.warning,
                    ),
                    const Divider(color: DTokens.borderDark, height: DTokens.s24),
                    _InfoRow(
                      icon: Icons.info_rounded,
                      label: '처리 상태',
                      value: '검토 중',
                      valueColor: DTokens.textSecondaryDark,
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.06),

              const SizedBox(height: DTokens.s16),

              // 안내
              Container(
                padding: const EdgeInsets.all(DTokens.s16),
                decoration: BoxDecoration(
                  color: DTokens.surfaceDark2,
                  borderRadius: BorderRadius.circular(DTokens.r12),
                  border: Border.all(color: DTokens.borderDark),
                ),
                child: const Text(
                  '제재 조치에 이의가 있으시면 아래 이의신청 버튼을 눌러 문의해 주세요. '
                  '접수 후 영업일 기준 3일 이내 검토 결과를 알려드립니다.',
                  style: TextStyle(
                    fontSize: 12,
                    color: DTokens.textSecondaryDark,
                    height: 1.7,
                  ),
                  textAlign: TextAlign.center,
                ),
              ).animate().fadeIn(delay: 350.ms),

              const Spacer(),

              // 버튼
              DButton(
                label: '이의신청 하기',
                icon: Icons.send_rounded,
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    builder: (_) => _AppealDialog(),
                  );
                },
              ).animate().fadeIn(delay: 400.ms),

              const SizedBox(height: DTokens.s12),

              DButton(
                label: '로그아웃',
                variant: DButtonVariant.outline,
                icon: Icons.logout_rounded,
                onPressed: () => context.go('/auth'),
              ).animate().fadeIn(delay: 450.ms),

              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  const _InfoRow({required this.icon, required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: valueColor ?? DTokens.textSecondaryDark),
        const SizedBox(width: DTokens.s12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(fontSize: 11, color: DTokens.textTertiaryDark)),
              const SizedBox(height: 2),
              Text(value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: valueColor ?? DTokens.textPrimaryDark,
                  )),
            ],
          ),
        ),
      ],
    );
  }
}

class _AppealDialog extends StatelessWidget {
  final _ctrl = TextEditingController();

  _AppealDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: DTokens.surfaceDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DTokens.r20)),
      title: const Text('이의신청', style: TextStyle(fontWeight: FontWeight.w800)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('제재 사유에 대한 의견을 작성해 주세요.',
              style: TextStyle(fontSize: 13, color: DTokens.textSecondaryDark)),
          const SizedBox(height: DTokens.s12),
          TextField(
            controller: _ctrl,
            minLines: 3,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: '이의신청 내용을 입력하세요',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소', style: TextStyle(color: DTokens.textSecondaryDark)),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('이의신청이 접수되었습니다.')),
            );
          },
          child: const Text('제출'),
        ),
      ],
    );
  }
}
