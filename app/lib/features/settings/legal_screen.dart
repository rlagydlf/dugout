import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_theme.dart';
import '../../app/theme/tokens.dart';
import '../../app/theme/typography.dart';
import '../../shared/widgets/d_glass_panel.dart';

class LegalScreen extends ConsumerWidget {
  const LegalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final team = context.team;
    final items = [
      _LegalItem(
        icon: Icons.description_rounded,
        color: team.primary,
        title: '서비스 이용약관',
        version: 'v2.1 · 2024.01.01',
        body: _termsBody,
      ),
      _LegalItem(
        icon: Icons.security_rounded,
        color: DTokens.info,
        title: '개인정보 처리방침',
        version: 'v1.8 · 2024.03.15',
        body: _privacyBody,
      ),
      _LegalItem(
        icon: Icons.code_rounded,
        color: DTokens.success,
        title: '오픈소스 라이선스',
        version: '현재 버전',
        body: _opensourceBody,
      ),
    ];

    return Scaffold(
      backgroundColor: DTokens.bgDark,
      appBar: AppBar(
        backgroundColor: DTokens.bgDark,
        elevation: 0,
        title: Text('약관 및 정책',
            style: DType.heading(17, color: Colors.white)),
      ),
      body: ListView.separated(
        padding: EdgeInsets.fromLTRB(
          DTokens.s16,
          DTokens.s12,
          DTokens.s16,
          MediaQuery.of(context).padding.bottom + DTokens.s32,
        ),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: DTokens.s12),
        itemBuilder: (context, i) => _ExpandableLegalCard(item: items[i])
            .animate()
            .fadeIn(delay: Duration(milliseconds: 80 * i))
            .slideY(begin: 0.04),
      ),
    );
  }
}

// ── data model ────────────────────────────────────────────────────────────────

class _LegalItem {
  final IconData icon;
  final Color color;
  final String title;
  final String version;
  final String body;
  const _LegalItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.version,
    required this.body,
  });
}

// ── expandable card ───────────────────────────────────────────────────────────

class _ExpandableLegalCard extends StatefulWidget {
  final _LegalItem item;
  const _ExpandableLegalCard({required this.item});
  @override
  State<_ExpandableLegalCard> createState() => _ExpandableLegalCardState();
}

class _ExpandableLegalCardState extends State<_ExpandableLegalCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late final AnimationController _ctrl;
  late final Animation<double> _rotateAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 250));
    _rotateAnim = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    _expanded ? _ctrl.forward() : _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return DGlassPanel(
      padding: EdgeInsets.zero,
      radius: DTokens.r20,
      onTap: _toggle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(DTokens.s16),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: widget.item.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(DTokens.r8),
                  ),
                  child: Icon(widget.item.icon,
                      size: 20, color: widget.item.color),
                ),
                const SizedBox(width: DTokens.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.item.title,
                        style: DType.body(15, FontWeight.w700)
                            .copyWith(color: DTokens.textPrimaryDark),
                      ),
                      Text(
                        widget.item.version,
                        style: DType.caption(12,
                            color: DTokens.textTertiaryDark),
                      ),
                    ],
                  ),
                ),
                RotationTransition(
                  turns: _rotateAnim,
                  child: const Icon(Icons.keyboard_arrow_down_rounded,
                      color: DTokens.textTertiaryDark),
                ),
              ],
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 280),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: [
                const Divider(color: DTokens.borderDark, height: 1),
                Padding(
                  padding: const EdgeInsets.all(DTokens.s16),
                  child: Text(
                    widget.item.body,
                    style: DType.body(13).copyWith(
                      color: DTokens.textSecondaryDark,
                      height: 1.85,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── 약관 콘텐츠 ───────────────────────────────────────────────────────────────

const _termsBody = '''제1조 (목적)
본 약관은 더그아웃이 제공하는 야구 팬 참여 플랫폼 서비스의 이용 조건 및 절차에 관한 사항을 규정합니다.

제2조 (정의)
① "서비스"란 더그아웃 앱 내 모든 기능을 의미합니다.
② "포인트"는 서비스 내 활동으로 적립되는 가상 재화로 환금성이 없습니다.

제3조 (서비스 이용)
① 회원은 본 약관 및 관련 법령을 준수하여야 합니다.
② 어뷰징, 부정 이용 시 계정이 정지될 수 있습니다.''';

const _privacyBody = '''1. 수집하는 개인정보
이메일 주소, 닉네임, 응원팀 정보, 서비스 이용 기록

2. 수집 목적
서비스 제공, 포인트 관리, 맞춤형 콘텐츠 제공

3. 보유 기간
회원 탈퇴 시까지 보유하며, 관련 법령에 따라 보관 후 파기

4. 제3자 제공
원칙적으로 제3자에게 제공하지 않으며, 법령에 의한 경우 예외

5. 문의: privacy@dugout.app''';

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
