import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/tokens.dart';
import '../../app/theme/typography.dart';
import '../../shared/widgets/d_card.dart';

class LegalScreen extends ConsumerWidget {
  const LegalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = [
      _LegalItem(
        icon: Icons.description_rounded,
        title: '서비스 이용약관',
        version: 'v2.1 · 2024.01.01',
        body: _termsBody,
      ),
      _LegalItem(
        icon: Icons.security_rounded,
        title: '개인정보 처리방침',
        version: 'v1.8 · 2024.03.15',
        body: _privacyBody,
      ),
      _LegalItem(
        icon: Icons.code_rounded,
        title: '오픈소스 라이선스',
        version: '현재 버전',
        body: _opensourceBody,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('약관 및 정책')),
      body: ListView.separated(
        padding: EdgeInsets.fromLTRB(
          DTokens.s16, DTokens.s16, DTokens.s16,
          MediaQuery.of(context).padding.bottom + DTokens.s24,
        ),
        itemCount: items.length,
        separatorBuilder: (_, idx) => const SizedBox(height: DTokens.s12),
        itemBuilder: (context, i) =>
            _ExpandableLegalCard(item: items[i])
                .animate()
                .fadeIn(delay: Duration(milliseconds: 80 * i))
                .slideY(begin: 0.04),
      ),
    );
  }
}

class _LegalItem {
  final IconData icon;
  final String title;
  final String version;
  final String body;
  const _LegalItem({required this.icon, required this.title, required this.version, required this.body});
}

class _ExpandableLegalCard extends StatefulWidget {
  final _LegalItem item;
  const _ExpandableLegalCard({required this.item});
  @override
  State<_ExpandableLegalCard> createState() => _ExpandableLegalCardState();
}

class _ExpandableLegalCardState extends State<_ExpandableLegalCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return DCard(
      padding: EdgeInsets.zero,
      onTap: () => setState(() => _expanded = !_expanded),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(DTokens.s16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: DTokens.borderDark,
                    borderRadius: BorderRadius.circular(DTokens.r8),
                  ),
                  child: Icon(widget.item.icon, size: 20, color: DTokens.textSecondaryDark),
                ),
                const SizedBox(width: DTokens.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.item.title,
                          style: DType.body(16, FontWeight.w700).copyWith(color: DTokens.textPrimaryDark)),
                      Text(widget.item.version,
                          style: DType.label(12, color: DTokens.textTertiaryDark)),
                    ],
                  ),
                ),
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(Icons.keyboard_arrow_down_rounded,
                      color: DTokens.textTertiaryDark),
                ),
              ],
            ),
          ),
          if (_expanded) ...[
            const Divider(color: DTokens.borderDark, height: 1),
            Padding(
              padding: const EdgeInsets.all(DTokens.s16),
              child: Text(
                widget.item.body,
                style: DType.body(14).copyWith(
                  color: DTokens.textSecondaryDark,
                  height: 1.8,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

const _termsBody = '''제1조 (목적)
본 약관은 더그아웃(이하 "회사")이 제공하는 야구 팬 참여 플랫폼 서비스의 이용 조건 및 절차에 관한 사항을 규정합니다.

제2조 (정의)
① "서비스"란 회사가 제공하는 더그아웃 앱 내 모든 기능을 의미합니다.
② "포인트"는 서비스 내 활동을 통해 적립되는 가상 재화로 환금성이 없습니다.

제3조 (서비스 이용)
① 회원은 본 약관 및 관련 법령을 준수하여야 합니다.
② 어뷰징, 부정 이용 시 계정이 정지될 수 있습니다.''';

const _privacyBody = '''1. 수집하는 개인정보
이메일 주소, 닉네임, 응원팀 정보, 서비스 이용 기록

2. 수집 목적
서비스 제공, 포인트 관리, 맞춤형 콘텐츠 제공

3. 보유 기간
회원 탈퇴 시까지 보유하며, 관련 법령에 따른 기간 내 보관 후 파기

4. 제3자 제공
원칙적으로 제3자에게 제공하지 않으며, 법령에 의한 경우 예외

5. 문의
privacy@dugout.app''';

const _opensourceBody = '''flutter (BSD-3-Clause)
flutter_riverpod (MIT)
go_router (BSD-3-Clause)
flutter_animate (MIT)
google_fonts (Apache-2.0)
dio (MIT)
freezed (MIT)
shared_preferences (BSD-3-Clause)
cached_network_image (MIT)
flutter_svg (MIT)

전체 라이선스 내용은 앱 내 오픈소스 공지 페이지를 참고하세요.''';
