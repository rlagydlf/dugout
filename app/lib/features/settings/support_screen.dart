import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_theme.dart';
import '../../app/theme/tokens.dart';
import '../../app/theme/typography.dart';
import '../../shared/widgets/d_button.dart';
import '../../shared/widgets/d_card.dart';

// ── FAQ mock ──────────────────────────────────────────────────────────────────

class _Faq {
  final String q;
  final String a;
  const _Faq(this.q, this.a);
}

const _faqs = [
  _Faq(
    '포인트는 어떻게 적립하나요?',
    '출정 선언(+50P), 일일 퀘스트 완료(+10~80P), 승리팀 예측 적중(+200P), 출석 체크(+10P) 등 다양한 활동으로 포인트를 모을 수 있습니다.',
  ),
  _Faq(
    '응원팀은 언제 변경할 수 있나요?',
    '응원팀 변경은 시즌 중 1회만 가능합니다. 변경 시 팀 기여도는 초기화되지만, 포인트와 배지는 유지됩니다.',
  ),
  _Faq(
    '리워드 교환 후 취소할 수 있나요?',
    '교환 완료된 리워드는 취소·환불이 불가합니다. 쿠폰 유효기간 내에 반드시 사용해 주세요.',
  ),
  _Faq(
    '팀 기여도란 무엇인가요?',
    '팀 기여도는 더그아웃 내 활동(출정, 퀘스트, 예측, 체크인)을 기반으로 산출되는 인앱 메트릭입니다. 구단 공식 지표와는 무관합니다.',
  ),
  _Faq(
    '계정을 삭제하면 어떻게 되나요?',
    '회원 탈퇴 시 포인트·기여도·배지 등 모든 데이터가 영구 삭제됩니다. 삭제된 데이터는 복구할 수 없습니다.',
  ),
];

// ── Screen ────────────────────────────────────────────────────────────────────

class SupportScreen extends ConsumerStatefulWidget {
  const SupportScreen({super.key});
  @override
  ConsumerState<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends ConsumerState<SupportScreen> {
  final _subjectCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_subjectCtrl.text.trim().isEmpty || _bodyCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제목과 내용을 모두 입력해 주세요.')),
      );
      return;
    }
    setState(() => _sending = true);
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;
    setState(() => _sending = false);
    _subjectCtrl.clear();
    _bodyCtrl.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('문의가 접수되었습니다. 24시간 내 답변드립니다.'),
        backgroundColor: context.team.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DTokens.r12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final team = context.team;

    return Scaffold(
      appBar: AppBar(title: const Text('FAQ / 1:1 문의')),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          DTokens.s16, DTokens.s16, DTokens.s16,
          MediaQuery.of(context).padding.bottom + DTokens.s24,
        ),
        children: [
          // FAQ
          Row(
            children: [
              Icon(Icons.quiz_rounded, size: 18, color: team.primary),
              const SizedBox(width: DTokens.s8),
              Text('자주 묻는 질문',
                  style: DType.body(18, FontWeight.w800).copyWith(color: DTokens.textPrimaryDark)),
            ],
          ),
          const SizedBox(height: DTokens.s12),
          ..._faqs.asMap().entries.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: DTokens.s8),
              child: _FaqTile(faq: e.value)
                  .animate()
                  .fadeIn(delay: Duration(milliseconds: 60 * e.key)),
            ),
          ),

          const SizedBox(height: 28),

          // 1:1 문의
          Row(
            children: [
              Icon(Icons.support_agent_rounded, size: 18, color: team.primary),
              const SizedBox(width: DTokens.s8),
              const Text('1:1 문의',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: DTokens.s4),
          const Text('평일 09:00~18:00 답변 · 24시간 내 답변',
              style: TextStyle(fontSize: 12, color: DTokens.textTertiaryDark)),
          const SizedBox(height: DTokens.s16),
          DCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _subjectCtrl,
                  decoration: const InputDecoration(
                    labelText: '제목',
                    hintText: '문의 제목을 입력하세요',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: DTokens.s12),
                TextField(
                  controller: _bodyCtrl,
                  minLines: 4,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    labelText: '내용',
                    hintText: '문의 내용을 자세히 입력해 주세요',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: DTokens.s16),
                DButton(label: '문의 보내기', icon: Icons.send_rounded, loading: _sending, onPressed: _send),
              ],
            ),
          ).animate().fadeIn(delay: 300.ms),
        ],
      ),
    );
  }
}

// ── FAQ 확장형 타일 ───────────────────────────────────────────────────────────

class _FaqTile extends StatefulWidget {
  final _Faq faq;
  const _FaqTile({required this.faq});
  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final team = context.team;
    return DCard(
      padding: EdgeInsets.zero,
      onTap: () => setState(() => _open = !_open),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: DTokens.s16, vertical: DTokens.s12),
            child: Row(
              children: [
                Text('Q', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: team.primary)),
                const SizedBox(width: DTokens.s8),
                Expanded(
                  child: Text(widget.faq.q,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                ),
                AnimatedRotation(
                  turns: _open ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(Icons.keyboard_arrow_down_rounded,
                      size: 20, color: DTokens.textTertiaryDark),
                ),
              ],
            ),
          ),
          if (_open) ...[
            const Divider(color: DTokens.borderDark, height: 1),
            Padding(
              padding: const EdgeInsets.all(DTokens.s16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('A', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: team.primary)),
                  const SizedBox(width: DTokens.s8),
                  Expanded(
                    child: Text(widget.faq.a,
                        style: const TextStyle(
                          fontSize: 13,
                          color: DTokens.textSecondaryDark,
                          height: 1.6,
                        )),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

