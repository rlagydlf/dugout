import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/tokens.dart';
import '../../app/theme/typography.dart';
import '../../core/providers/app_providers.dart';
import '../../shared/widgets/d_button.dart';
import '../../shared/widgets/d_glass_panel.dart';

class WithdrawScreen extends ConsumerStatefulWidget {
  const WithdrawScreen({super.key});
  @override
  ConsumerState<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends ConsumerState<WithdrawScreen> {
  bool _agreed = false;

  Future<void> _onWithdraw() async {
    // Step 1: 확인 다이얼로그
    final step1 = await showDialog<bool>(
      context: context,
      builder: (_) => const _ConfirmDialog1(),
    );
    if (step1 != true || !mounted) return;

    // Step 2: 최종 확인
    final step2 = await showDialog<bool>(
      context: context,
      builder: (_) => const _ConfirmDialog2(),
    );
    if (step2 != true || !mounted) return;

    ref.read(authProvider.notifier).signOut();
    context.go('/auth');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DTokens.bgDark,
      appBar: AppBar(
        backgroundColor: DTokens.bgDark,
        elevation: 0,
        title: Text('회원탈퇴',
            style: DType.heading(17, color: Colors.white)),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(DTokens.s16),
              children: [
                // ── 탈퇴 데이터 처리 안내
                DGlassPanel(
                  padding: const EdgeInsets.all(DTokens.s20),
                  radius: DTokens.r20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: DTokens.danger.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.warning_amber_rounded,
                              color: DTokens.danger,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: DTokens.s12),
                          Text(
                            '탈퇴 전 꼭 확인하세요',
                            style: DType.body(15, FontWeight.w800)
                                .copyWith(color: DTokens.danger),
                          ),
                        ],
                      ),
                      const SizedBox(height: DTokens.s20),
                      ..._dataItems.map(
                        (item) => Padding(
                          padding:
                              const EdgeInsets.only(bottom: DTokens.s14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                margin: const EdgeInsets.only(
                                    top: 7, right: DTokens.s8),
                                decoration: const BoxDecoration(
                                  color: DTokens.danger,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.$1,
                                      style: DType.body(13,
                                              FontWeight.w700)
                                          .copyWith(
                                              color:
                                                  DTokens.textPrimaryDark),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      item.$2,
                                      style: DType.caption(12,
                                              color:
                                                  DTokens.textSecondaryDark)
                                          .copyWith(height: 1.5),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(),

                const SizedBox(height: DTokens.s16),

                // ── 개인정보 처리 안내
                DGlassPanel(
                  padding: const EdgeInsets.all(DTokens.s16),
                  radius: DTokens.r20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.security_rounded,
                              size: 15,
                              color: DTokens.textSecondaryDark),
                          const SizedBox(width: DTokens.s8),
                          Text(
                            '개인정보 처리 안내',
                            style: DType.body(13, FontWeight.w700)
                                .copyWith(
                                    color: DTokens.textSecondaryDark),
                          ),
                        ],
                      ),
                      const SizedBox(height: DTokens.s12),
                      Text(
                        '탈퇴 시 개인정보는 관련 법령(전자상거래법 등)에 따라 일정 기간 '
                        '보관 후 파기됩니다. 법적 의무 보관 대상이 아닌 정보는 즉시 삭제됩니다.',
                        style: DType.caption(12,
                                color: DTokens.textSecondaryDark)
                            .copyWith(height: 1.7),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 100.ms),

                const SizedBox(height: DTokens.s24),

                // ── 동의 체크
                GestureDetector(
                  onTap: () => setState(() => _agreed = !_agreed),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: _agreed
                              ? DTokens.danger
                              : Colors.transparent,
                          borderRadius:
                              BorderRadius.circular(DTokens.r4),
                          border: Border.all(
                            color: _agreed
                                ? DTokens.danger
                                : DTokens.borderDark,
                            width: 1.5,
                          ),
                        ),
                        child: _agreed
                            ? const Icon(Icons.check_rounded,
                                size: 14, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: DTokens.s12),
                      Expanded(
                        child: Text(
                          '위 내용을 모두 확인했으며, 탈퇴에 동의합니다.',
                          style: DType.body(13, FontWeight.w600)
                              .copyWith(color: DTokens.textPrimaryDark),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 160.ms),
              ],
            ),
          ),

          // ── CTA
          Container(
            padding: EdgeInsets.fromLTRB(
              DTokens.s16,
              DTokens.s12,
              DTokens.s16,
              MediaQuery.of(context).padding.bottom + DTokens.s12,
            ),
            decoration: const BoxDecoration(
              color: DTokens.bgDark,
              border: Border(top: BorderSide(color: DTokens.borderDark)),
            ),
            child: DButton(
              label: '회원탈퇴',
              onPressed: _agreed ? _onWithdraw : null,
            ),
          ),
        ],
      ),
    );
  }
}

const _dataItems = [
  ('포인트 소멸', '보유 중인 모든 포인트가 즉시 소멸됩니다.'),
  ('데이터 삭제', '팬카드·배지·기여도·예측 기록이 모두 영구 삭제됩니다.'),
  ('복구 불가', '탈퇴 후 동일 계정으로 복구할 수 없습니다.'),
  ('재가입 제한', '탈퇴 후 7일간 동일 이메일로 재가입이 제한됩니다.'),
];

// ── Step 1 다이얼로그 ─────────────────────────────────────────────────────────

class _ConfirmDialog1 extends StatelessWidget {
  const _ConfirmDialog1();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: DTokens.surfaceDark,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DTokens.r20)),
      title: Row(
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: DTokens.danger, size: 22),
          const SizedBox(width: DTokens.s8),
          Text('정말 탈퇴하시겠습니까?',
              style: DType.body(16, FontWeight.w800)
                  .copyWith(color: Colors.white)),
        ],
      ),
      content: Text(
        '탈퇴 후에는 모든 데이터가 삭제되며 복구할 수 없습니다.',
        style: DType.caption(13, color: DTokens.textSecondaryDark)
            .copyWith(height: 1.5),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('취소',
              style: DType.body(14)
                  .copyWith(color: DTokens.textSecondaryDark)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: DTokens.danger,
            foregroundColor: Colors.white,
          ),
          onPressed: () => Navigator.pop(context, true),
          child: Text('계속 진행',
              style: DType.body(14, FontWeight.w700)
                  .copyWith(color: Colors.white)),
        ),
      ],
    );
  }
}

// ── Step 2 최종 다이얼로그 ────────────────────────────────────────────────────

class _ConfirmDialog2 extends StatelessWidget {
  const _ConfirmDialog2();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: DTokens.surfaceDark,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DTokens.r20)),
      title: Text('최종 확인',
          style: DType.body(16, FontWeight.w800)
              .copyWith(color: Colors.white)),
      content: Text(
        '이 작업은 되돌릴 수 없습니다.\n정말로 탈퇴하시겠습니까?',
        style: DType.caption(13, color: DTokens.textSecondaryDark)
            .copyWith(height: 1.6),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('취소',
              style: DType.body(14)
                  .copyWith(color: DTokens.textSecondaryDark)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: DTokens.danger,
            foregroundColor: Colors.white,
          ),
          onPressed: () => Navigator.pop(context, true),
          child: Text('탈퇴하기',
              style: DType.body(14, FontWeight.w700)
                  .copyWith(color: Colors.white)),
        ),
      ],
    );
  }
}
