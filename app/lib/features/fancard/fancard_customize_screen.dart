import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_theme.dart';
import '../../app/theme/tokens.dart';
import '../../app/theme/typography.dart';
import '../../core/providers/app_providers.dart';
import '../../shared/widgets/d_button.dart';
import '../../shared/widgets/d_glass_panel.dart';
import '../../shared/widgets/d_team_crest.dart';

// ── mock data ─────────────────────────────────────────────────────────────────

class _CardTheme {
  final String id;
  final String name;
  final List<Color> colors;
  final bool shimmer;
  const _CardTheme({
    required this.id,
    required this.name,
    required this.colors,
    this.shimmer = false,
  });
}

const _cardThemes = [
  _CardTheme(id: 'classic', name: '클래식', colors: [Color(0xFF1A1F2C), Color(0xFF2A3040)]),
  _CardTheme(id: 'neon', name: '네온', colors: [Color(0xFF0D1B2A), Color(0xFF1A0A2E)], shimmer: true),
  _CardTheme(id: 'vintage', name: '빈티지', colors: [Color(0xFF2C1810), Color(0xFF4A2E1A)]),
  _CardTheme(id: 'hologram', name: '홀로그램', colors: [Color(0xFF001A3A), Color(0xFF1A003A)], shimmer: true),
  _CardTheme(id: 'field', name: '필드', colors: [Color(0xFF0A2A0A), Color(0xFF1A3A1A)]),
];

class _BadgeOption {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  const _BadgeOption({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });
}

const _badgeOptions = [
  _BadgeOption(id: 'first_sortie', name: '첫 출정', icon: Icons.rocket_launch_rounded, color: DTokens.info),
  _BadgeOption(id: 'rookie_predictor', name: '신인 예측가', icon: Icons.psychology_rounded, color: DTokens.warning),
  _BadgeOption(id: 'night_owl', name: '야행성 팬', icon: Icons.nightlight_rounded, color: Color(0xFF9B6DFF)),
  _BadgeOption(id: 'streak7', name: '7일 연속', icon: Icons.local_fire_department_rounded, color: DTokens.danger),
  _BadgeOption(id: 'first_win', name: '첫 예측 적중', icon: Icons.military_tech_rounded, color: DTokens.success),
  _BadgeOption(id: 'stadium_10', name: '직관 10회', icon: Icons.stadium_rounded, color: Color(0xFF00C4B4)),
];

// ── screen ────────────────────────────────────────────────────────────────────

class FancardCustomizeScreen extends ConsumerStatefulWidget {
  const FancardCustomizeScreen({super.key});
  @override
  ConsumerState<FancardCustomizeScreen> createState() =>
      _FancardCustomizeScreenState();
}

class _FancardCustomizeScreenState
    extends ConsumerState<FancardCustomizeScreen> {
  String _selectedThemeId = 'classic';
  final Set<String> _selectedBadges = {'first_sortie', 'rookie_predictor'};

  _CardTheme get _currentTheme =>
      _cardThemes.firstWhere((t) => t.id == _selectedThemeId);

  void _apply() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '팬카드가 업데이트되었습니다.',
          style: DType.body(16).copyWith(color: Colors.white),
        ),
        backgroundColor: context.team.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DTokens.r12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final team = context.team;
    final user = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: DTokens.bgDark,
      appBar: AppBar(
        backgroundColor: DTokens.bgDark,
        elevation: 0,
        title: Text('프로필 꾸미기',
            style: DType.heading(17, color: Colors.white)),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(DTokens.s16),
              children: [
                // ── 미리보기 (라이브 반영)
                _MiniPreview(
                  user: user,
                  cardTheme: _currentTheme,
                  selectedBadges: _selectedBadges,
                ).animate().fadeIn().slideY(begin: -0.04),

                const SizedBox(height: 28),

                // ── 테마 선택 헤더
                _SectionHeader(
                  label: 'CARD THEME',
                  title: '카드 테마',
                  icon: 'assets/images/icons/scoreboard.png',
                ),
                const SizedBox(height: DTokens.s12),

                // ── 테마 가로 스크롤
                SizedBox(
                  height: 96,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _cardThemes.length,
                    separatorBuilder: (e, s) =>
                        const SizedBox(width: DTokens.s8),
                    itemBuilder: (context, i) {
                      final t = _cardThemes[i];
                      final selected = t.id == _selectedThemeId;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedThemeId = t.id),
                        child: _ThemeCard(
                          theme: t,
                          selected: selected,
                          teamColor: team.primary,
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 28),

                // ── 배지 선택 헤더
                Row(
                  children: [
                    _SectionHeader(
                      label: 'DISPLAY BADGES',
                      title: '표시 배지',
                      icon: 'assets/images/icons/trophy.png',
                    ),
                    const Spacer(),
                    Text(
                      '최대 4개',
                      style: DType.label(12,
                          color: DTokens.textTertiaryDark),
                    ),
                  ],
                ),
                const SizedBox(height: DTokens.s12),

                // ── 배지 그리드 3열
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: DTokens.s8,
                    crossAxisSpacing: DTokens.s8,
                    childAspectRatio: 2.4,
                  ),
                  itemCount: _badgeOptions.length,
                  itemBuilder: (context, i) {
                    final b = _badgeOptions[i];
                    final checked = _selectedBadges.contains(b.id);
                    final canSelect =
                        checked || _selectedBadges.length < 4;
                    return GestureDetector(
                      onTap: () {
                        if (!canSelect) return;
                        setState(() {
                          if (checked) {
                            _selectedBadges.remove(b.id);
                          } else {
                            _selectedBadges.add(b.id);
                          }
                        });
                      },
                      child: _BadgeToggle(
                        badge: b,
                        checked: checked,
                      ),
                    );
                  },
                ),

                const SizedBox(height: DTokens.s16),
              ],
            ),
          ),

          // ── 하단 적용 버튼
          Container(
            padding: EdgeInsets.fromLTRB(
              DTokens.s16,
              DTokens.s12,
              DTokens.s16,
              MediaQuery.of(context).padding.bottom + DTokens.s12,
            ),
            decoration: const BoxDecoration(
              color: DTokens.bgDark,
              border: Border(
                  top: BorderSide(color: DTokens.borderDark)),
            ),
            child: DButton(
              label: '적용하기',
              icon: Icons.check_rounded,
              onPressed: _apply,
            ),
          ),
        ],
      ),
    );
  }
}

// ── mini preview ──────────────────────────────────────────────────────────────

class _MiniPreview extends StatelessWidget {
  final dynamic user;
  final _CardTheme cardTheme;
  final Set<String> selectedBadges;
  const _MiniPreview({
    required this.user,
    required this.cardTheme,
    required this.selectedBadges,
  });

  @override
  Widget build(BuildContext context) {
    final team = context.team;
    final displayBadges = _badgeOptions
        .where((b) => selectedBadges.contains(b.id))
        .take(4)
        .toList();

    return Container(
      height: 168,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: cardTheme.colors,
        ),
        borderRadius: BorderRadius.circular(DTokens.r20),
        border: Border.all(
          color: team.primary.withValues(alpha: 0.45),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: team.primary.withValues(alpha: 0.22),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 마스코트 배경 (라이브 반영)
          Positioned(
            right: -24,
            bottom: -16,
            child: Opacity(
              opacity: 0.22,
              child: Image.asset(
                team.mascotAsset,
                width: 140,
                fit: BoxFit.contain,
                errorBuilder: (e, s, t) =>
                    const SizedBox.shrink(),
              ),
            ),
          ),

          // 스캔라인
          Positioned.fill(
            child: CustomPaint(
              painter: _PreviewScanlinePainter(),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(DTokens.s16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // 실제 KBO 로고 (라이브 반영)
                    Image.asset(
                      team.crestAsset,
                      width: 36,
                      height: 36,
                      fit: BoxFit.contain,
                      errorBuilder: (e, s, t) =>
                          DTeamCrest(team: team, size: 36),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'DUGOUT FAN CARD',
                          style: DType.label(10,
                              color: team.accent.withValues(alpha: 0.6)),
                        ),
                        Text(
                          user.nickname as String,
                          style: DType.heading(16, color: team.accent),
                        ),
                      ],
                    ),
                    const Spacer(),
                    if (cardTheme.shimmer)
                      Icon(Icons.auto_awesome_rounded,
                          size: 16, color: team.primary),
                  ],
                ),
                const Spacer(),
                // 선택된 배지
                Row(
                  children: displayBadges
                      .map((b) => Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: b.color.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: b.color.withValues(alpha: 0.5),
                                ),
                              ),
                              child: Icon(b.icon,
                                  size: 15, color: b.color),
                            ),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── theme card ────────────────────────────────────────────────────────────────

class _ThemeCard extends StatelessWidget {
  final _CardTheme theme;
  final bool selected;
  final Color teamColor;
  const _ThemeCard({
    required this.theme,
    required this.selected,
    required this.teamColor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: 250.ms,
      width: 84,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: theme.colors,
        ),
        borderRadius: BorderRadius.circular(DTokens.r16),
        border: Border.all(
          color: selected ? teamColor : DTokens.borderDark,
          width: selected ? 2.5 : 1,
        ),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: teamColor.withValues(alpha: 0.4),
                  blurRadius: 14,
                ),
              ]
            : null,
      ),
      child: DGlassPanel(
        padding: EdgeInsets.zero,
        radius: DTokens.r16,
        opacity: 0,
        blur: 0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (theme.shimmer)
              Icon(Icons.auto_awesome_rounded,
                  size: 18, color: teamColor),
            const SizedBox(height: 4),
            Text(
              theme.name,
              style: DType.label(12,
                  color: selected
                      ? teamColor
                      : Colors.white.withValues(alpha: 0.7)),
            ),
            if (selected) ...[
              const SizedBox(height: 4),
              Icon(Icons.check_circle_rounded,
                  size: 14, color: teamColor),
            ],
          ],
        ),
      ),
    );
  }
}

// ── badge toggle ──────────────────────────────────────────────────────────────

class _BadgeToggle extends StatelessWidget {
  final _BadgeOption badge;
  final bool checked;
  const _BadgeToggle({required this.badge, required this.checked});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: 200.ms,
      decoration: BoxDecoration(
        color: checked
            ? badge.color.withValues(alpha: 0.15)
            : DTokens.surfaceDark2,
        borderRadius: BorderRadius.circular(DTokens.r12),
        border: Border.all(
          color: checked
              ? badge.color.withValues(alpha: 0.6)
              : DTokens.borderDark,
        ),
      ),
      padding: const EdgeInsets.symmetric(
          horizontal: DTokens.s8, vertical: DTokens.s8),
      child: Row(
        children: [
          Icon(
            badge.icon,
            size: 16,
            color: checked ? badge.color : DTokens.textTertiaryDark,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              badge.name,
              style: DType.body(13, FontWeight.w700).copyWith(
                color: checked
                    ? badge.color
                    : DTokens.textTertiaryDark,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ── section header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  final String title;
  final String icon;
  const _SectionHeader({
    required this.label,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final team = context.team;
    return Row(
      children: [
        Image.asset(
          icon,
          width: 16,
          height: 16,
          errorBuilder: (e, s, t) => Icon(
            Icons.sports_baseball_rounded,
            size: 16,
            color: team.primary,
          ),
        ),
        const SizedBox(width: DTokens.s8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: DType.label(11,
                    color: team.primary.withValues(alpha: 0.7))),
            Text(title,
                style: DType.heading(15, color: Colors.white)),
          ],
        ),
      ],
    );
  }
}

// ── preview scanline ──────────────────────────────────────────────────────────

class _PreviewScanlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.02)
      ..strokeWidth = 1;
    for (double y = 0; y < size.height; y += 3) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
