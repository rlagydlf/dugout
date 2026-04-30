import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_theme.dart';
import '../../app/theme/team_theme.dart';
import '../../app/theme/theme_provider.dart';
import '../../app/theme/tokens.dart';
import '../../app/theme/typography.dart';
import '../../core/providers/app_providers.dart';
import '../../shared/widgets/d_effects.dart';
import '../../shared/widgets/d_glass_panel.dart';

class SettingsHomeScreen extends ConsumerWidget {
  const SettingsHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final team = context.team;
    ref.watch(userProvider);

    return Scaffold(
      backgroundColor: DTokens.bgDark,
      appBar: AppBar(
        backgroundColor: DTokens.bgDark,
        elevation: 0,
        title: Text('설정', style: DType.heading(17, color: Colors.white)),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          DTokens.s20,
          DTokens.s8,
          DTokens.s20,
          MediaQuery.of(context).padding.bottom + DTokens.s32,
        ),
        children: [
          // ── 응원팀 빠른 변경 (3D tilt 가로 스크롤)
          _TeamQuickSwitcher(
            currentTeamId: team.teamId,
            ref: ref,
          ).animate().fadeIn(duration: 400.ms),

          const SizedBox(height: DTokens.s24),

          // ── 메뉴 섹션 레이블
          Text(
            'SETTINGS',
            style: DType.label(11,
                color: DTokens.textTertiaryDark, letterSpacing: 2.5),
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: DTokens.s12),

          // ── 메뉴 리스트
          _MenuGroup(
            items: [
              _MenuItem(
                icon: Icons.notifications_rounded,
                color: team.primary,
                label: '알림 수신 설정',
                onTap: () => context.push('/settings/notifications'),
              ),
              _MenuItem(
                icon: Icons.swap_horiz_rounded,
                color: DTokens.info,
                label: '응원팀 변경',
                onTap: () => context.push('/settings/team'),
              ),
            ],
          ).animate().fadeIn(delay: 150.ms),

          const SizedBox(height: DTokens.s12),

          _MenuGroup(
            items: [
              _MenuItem(
                icon: Icons.description_rounded,
                color: DTokens.textSecondaryDark,
                label: '약관 및 개인정보 처리방침',
                onTap: () => context.push('/settings/legal'),
              ),
              _MenuItem(
                icon: Icons.help_outline_rounded,
                color: DTokens.textSecondaryDark,
                label: 'FAQ / 1:1 문의',
                onTap: () => context.push('/settings/support'),
              ),
            ],
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: DTokens.s12),

          _MenuGroup(
            items: [
              _MenuItem(
                icon: Icons.logout_rounded,
                color: DTokens.textSecondaryDark,
                label: '로그아웃',
                onTap: () {
                  ref.read(authProvider.notifier).signOut();
                  context.go('/auth');
                },
              ),
              _MenuItem(
                icon: Icons.person_remove_rounded,
                color: DTokens.danger,
                label: '회원탈퇴',
                danger: true,
                onTap: () => context.push('/settings/withdraw'),
              ),
            ],
          ).animate().fadeIn(delay: 250.ms),
        ],
      ),
    );
  }
}

// ── 팀 빠른 전환 가로 스크롤 ──────────────────────────────────────────────────

class _TeamQuickSwitcher extends StatelessWidget {
  final String currentTeamId;
  final WidgetRef ref;
  const _TeamQuickSwitcher(
      {required this.currentTeamId, required this.ref});

  @override
  Widget build(BuildContext context) {
    final team = context.team;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3,
              height: 16,
              decoration: BoxDecoration(
                color: team.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: DTokens.s8),
            Text(
              '응원팀 빠른 변경',
              style:
                  DType.body(15, FontWeight.w700).copyWith(color: Colors.white),
            ),
            const Spacer(),
            Text(
              'QUICK SWITCH',
              style: DType.label(10,
                  color: DTokens.textTertiaryDark, letterSpacing: 1.5),
            ),
          ],
        ),
        const SizedBox(height: DTokens.s12),
        SizedBox(
          height: 88,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: TeamThemes.all.length,
            separatorBuilder: (_, _) =>
                const SizedBox(width: DTokens.s8),
            itemBuilder: (context, i) {
              final t = TeamThemes.all[i];
              final selected = currentTeamId == t.teamId;
              return D3DTiltCard(
                maxTiltDeg: 8,
                onTap: () async {
                  await ref
                      .read(currentTeamProvider.notifier)
                      .select(t.teamId);
                  ref
                      .read(userProvider.notifier)
                      .selectTeam(t.teamId);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        t.primary.withValues(alpha: selected ? 1.0 : 0.75),
                        t.secondary.withValues(alpha: selected ? 1.0 : 0.75),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(DTokens.r16),
                    border: Border.all(
                      color: selected
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.08),
                      width: selected ? 2 : 1,
                    ),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: t.primary.withValues(alpha: 0.45),
                              blurRadius: 16,
                              spreadRadius: 1,
                            )
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 팀 로고 이미지
                      ClipOval(
                        child: Image.asset(
                          t.crestAsset,
                          width: 36,
                          height: 36,
                          fit: BoxFit.cover,
                          errorBuilder: (e, s, t2) => Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                            child: Center(
                              child: Text(
                                t.teamShortName.isNotEmpty
                                    ? t.teamShortName[0]
                                    : '?',
                                style: DType.label(14, color: t.accent),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        t.teamShortName,
                        style: DType.label(11, color: t.accent),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── 메뉴 그룹 ─────────────────────────────────────────────────────────────────

class _MenuItem {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback? onTap;
  final bool danger;
  const _MenuItem({
    required this.icon,
    required this.color,
    required this.label,
    this.onTap,
    this.danger = false,
  });
}

class _MenuGroup extends StatelessWidget {
  final List<_MenuItem> items;
  const _MenuGroup({required this.items});

  @override
  Widget build(BuildContext context) {
    return DGlassPanel(
      padding: EdgeInsets.zero,
      radius: DTokens.r20,
      child: Column(
        children: items.asMap().entries.map((e) {
          final item = e.value;
          final isLast = e.key == items.length - 1;
          return Column(
            children: [
              InkWell(
                onTap: item.onTap,
                borderRadius: BorderRadius.circular(DTokens.r20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: DTokens.s16, vertical: DTokens.s14),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: item.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(DTokens.r8),
                        ),
                        child: Icon(item.icon, size: 18, color: item.color),
                      ),
                      const SizedBox(width: DTokens.s12),
                      Expanded(
                        child: Text(
                          item.label,
                          style: DType.body(15).copyWith(
                            color: item.danger
                                ? DTokens.danger
                                : DTokens.textPrimaryDark,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: DTokens.textTertiaryDark,
                      ),
                    ],
                  ),
                ),
              ),
              if (!isLast)
                const Divider(
                    color: DTokens.borderDark, height: 1, indent: 64),
            ],
          );
        }).toList(),
      ),
    );
  }
}
