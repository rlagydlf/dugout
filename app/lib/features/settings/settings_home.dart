import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_theme.dart';
import '../../app/theme/team_theme.dart';
import '../../app/theme/theme_provider.dart';
import '../../app/theme/tokens.dart';
import '../../app/theme/typography.dart';
import '../../core/providers/app_providers.dart';
import '../../shared/widgets/d_card.dart';

class SettingsHomeScreen extends ConsumerWidget {
  const SettingsHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final team = context.team;
    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: ListView(
        padding: const EdgeInsets.all(DTokens.s20),
        children: [
          DCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('응원팀 빠른 변경 (데모)',
                    style: DType.body(16, FontWeight.w700).copyWith(color: DTokens.textPrimaryDark)),
                const SizedBox(height: DTokens.s12),
                SizedBox(
                  height: 64,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: TeamThemes.all.length,
                    separatorBuilder: (e, s) =>
                        const SizedBox(width: DTokens.s8),
                    itemBuilder: (context, i) {
                      final t = TeamThemes.all[i];
                      final selected = team.teamId == t.teamId;
                      return GestureDetector(
                        onTap: () async {
                          await ref
                              .read(currentTeamProvider.notifier)
                              .select(t.teamId);
                          ref.read(userProvider.notifier).selectTeam(t.teamId);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: 64,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [t.primary, t.secondary],
                            ),
                            borderRadius:
                                BorderRadius.circular(DTokens.r12),
                            border: Border.all(
                              color: selected ? Colors.white : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            t.teamShortName,
                            style: DType.label(14, color: t.accent),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: DTokens.s16),
          _SettingsTile(
            icon: Icons.notifications_rounded,
            label: '알림 수신 설정',
          ),
          _SettingsTile(
            icon: Icons.description_rounded,
            label: '약관 / 개인정보 / 오픈소스',
          ),
          _SettingsTile(
            icon: Icons.help_outline_rounded,
            label: 'FAQ / 1:1 문의',
          ),
          const SizedBox(height: DTokens.s24),
          _SettingsTile(
            icon: Icons.logout_rounded,
            label: '로그아웃',
            onTap: () {
              ref.read(authProvider.notifier).signOut();
              context.go('/auth');
            },
          ),
          _SettingsTile(
            icon: Icons.person_remove_rounded,
            label: '회원탈퇴',
            danger: true,
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool danger;
  const _SettingsTile({
    required this.icon,
    required this.label,
    this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = danger ? DTokens.danger : DTokens.textPrimaryDark;
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: DTokens.s4, vertical: 4),
      leading: Icon(icon, color: color),
      title: Text(label, style: DType.body(15).copyWith(color: color)),
      trailing: Icon(Icons.chevron_right_rounded,
          color: DTokens.textTertiaryDark),
      onTap: onTap,
    );
  }
}
