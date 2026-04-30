import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/tokens.dart';
import '../../core/providers/app_providers.dart';
import '../../shared/widgets/d_button.dart';
import '../../shared/widgets/d_card.dart';

class WithdrawScreen extends ConsumerStatefulWidget {
  const WithdrawScreen({super.key});
  @override
  ConsumerState<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends ConsumerState<WithdrawScreen> {
  bool _agreed = false;

  Future<void> _onWithdraw() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const _WithdrawDialog(),
    );
    if (confirmed != true || !mounted) return;
    ref.read(authProvider.notifier).signOut();
    context.go('/auth');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('회원탈퇴')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(DTokens.s16),
              children: [
                // 안내 카드
                DCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: DTokens.danger, size: 20),
                          SizedBox(width: DTokens.s8),
                          Text('탈퇴 전 꼭 확인하세요',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: DTokens.danger,
                              )),
                        ],
                      ),
                      const SizedBox(height: DTokens.s16),
                      ...[
                        ('포인트 소멸', '보유 중인 모든 포인트가 즉시 소멸됩니다.'),
                        ('데이터 삭제', '팬카드·배지·기여도·예측 기록이 모두 영구 삭제됩니다.'),
                        ('복구 불가', '탈퇴 후 동일 계정으로 복구할 수 없습니다.'),
                        ('재가입 제한', '탈퇴 후 7일간 동일 이메일로 재가입이 제한됩니다.'),
                      ].map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: DTokens.s12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  margin: const EdgeInsets.only(top: 6, right: DTokens.s8),
                                  decoration: const BoxDecoration(
                                    color: DTokens.danger,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item.$1,
                                          style: const TextStyle(
                                              fontSize: 13, fontWeight: FontWeight.w700)),
                                      Text(item.$2,
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: DTokens.textSecondaryDark,
                                              height: 1.4)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ).animate().fadeIn(),

                const SizedBox(height: DTokens.s16),

                // 개인정보 처리 안내
                DCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.security_rounded, size: 16, color: DTokens.textSecondaryDark),
                          SizedBox(width: DTokens.s8),
                          Text('개인정보 처리 안내',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                        ],
                      ),
                      const SizedBox(height: DTokens.s12),
                      const Text(
                        '탈퇴 시 개인정보는 관련 법령(전자상거래법 등)에 따라 일정 기간 보관 후 파기됩니다. '
                        '법적 의무 보관 대상이 아닌 정보는 즉시 삭제됩니다.',
                        style: TextStyle(
                          fontSize: 12,
                          color: DTokens.textSecondaryDark,
                          height: 1.7,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 100.ms),

                const SizedBox(height: DTokens.s20),

                // 동의 체크박스
                GestureDetector(
                  onTap: () => setState(() => _agreed = !_agreed),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: 200.ms,
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: _agreed ? DTokens.danger : Colors.transparent,
                          borderRadius: BorderRadius.circular(DTokens.r4),
                          border: Border.all(
                            color: _agreed ? DTokens.danger : DTokens.borderDark,
                            width: 1.5,
                          ),
                        ),
                        child: _agreed
                            ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: DTokens.s12),
                      const Expanded(
                        child: Text(
                          '위 내용을 모두 확인했으며, 탈퇴에 동의합니다.',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 150.ms),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(
              DTokens.s16, DTokens.s12, DTokens.s16,
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

class _WithdrawDialog extends StatelessWidget {
  const _WithdrawDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: DTokens.surfaceDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DTokens.r20)),
      title: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: DTokens.danger, size: 22),
          SizedBox(width: DTokens.s8),
          Text('정말 탈퇴하시겠습니까?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        ],
      ),
      content: const Text(
        '탈퇴 후에는 모든 데이터가 삭제되며 복구할 수 없습니다.',
        style: TextStyle(fontSize: 13, color: DTokens.textSecondaryDark, height: 1.5),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('취소', style: TextStyle(color: DTokens.textSecondaryDark)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: DTokens.danger),
          onPressed: () => Navigator.pop(context, true),
          child: const Text('탈퇴하기', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
