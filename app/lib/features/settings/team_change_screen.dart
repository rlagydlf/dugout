import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_theme.dart';
import '../../app/theme/team_theme.dart';
import '../../app/theme/theme_provider.dart';
import '../../app/theme/tokens.dart';
import '../../app/theme/typography.dart';
import '../../core/providers/app_providers.dart';
import '../../shared/widgets/d_button.dart';
import '../../shared/widgets/d_card.dart';
import '../../shared/widgets/d_team_crest.dart';

class TeamChangeScreen extends ConsumerStatefulWidget {
  const TeamChangeScreen({super.key});
  @override
  ConsumerState<TeamChangeScreen> createState() => _TeamChangeScreenState();
}

class _TeamChangeScreenState extends ConsumerState<TeamChangeScreen> {
  String? _selectedId;
  bool _loading = false;

  Future<void> _confirm() async {
    if (_selectedId == null) return;
    setState(() => _loading = true);
    await ref.read(currentTeamProvider.notifier).select(_selectedId!);
    ref.read(userProvider.notifier).selectTeam(_selectedId!);
    if (!mounted) return;
    setState(() => _loading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('응원팀이 ${TeamThemes.byId(_selectedId).teamName}으로 변경되었습니다.'),
        backgroundColor: context.team.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DTokens.r12)),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final team = context.team;
    final teams = TeamThemes.all;
    final preview = _selectedId != null ? TeamThemes.byId(_selectedId) : team;

    return Scaffold(
      appBar: AppBar(title: const Text('응원팀 변경')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(DTokens.s16),
              children: [
                // 정책 카드
                DCard(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: DTokens.warning.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.policy_rounded, size: 20, color: DTokens.warning),
                      ),
                      const SizedBox(width: DTokens.s12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('응원팀 변경 정책',
                                style: DType.body(16, FontWeight.w800).copyWith(color: DTokens.textPrimaryDark)),
                            SizedBox(height: DTokens.s8),
                            Text(
                              '• 응원팀 변경은 시즌 중 1회만 가능합니다.\n'
                              '• 변경 후 기존 팀 기반 기여도는 초기화됩니다.\n'
                              '• 포인트·배지는 유지됩니다.\n'
                              '• 다음 시즌(2026)에 다시 변경 가능합니다.',
                              style: DType.body(14).copyWith(
                                color: DTokens.textSecondaryDark,
                                height: 1.7,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(),

                const SizedBox(height: DTokens.s20),

                // 미리보기 헤더
                AnimatedContainer(
                  duration: 300.ms,
                  padding: const EdgeInsets.all(DTokens.s16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        preview.primary.withValues(alpha: 0.2),
                        preview.secondary.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(DTokens.r16),
                    border: Border.all(color: preview.primary.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      DTeamCrest(team: preview, size: 48, glow: _selectedId != null),
                      const SizedBox(width: DTokens.s12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedId == null ? '팀을 선택하세요' : preview.teamName,
                            style: DType.heading(18, color: DTokens.textPrimaryDark),
                          ),
                          Text(
                            _selectedId == null ? '아래에서 팀을 선택해 주세요' : preview.slogan,
                            style: DType.body(14).copyWith(color: DTokens.textSecondaryDark),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: DTokens.s20),

                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: DTokens.s8,
                    crossAxisSpacing: DTokens.s8,
                    childAspectRatio: 1.6,
                  ),
                  itemCount: teams.length,
                  itemBuilder: (context, i) {
                    final t = teams[i];
                    final selected = _selectedId == t.teamId;
                    final isCurrent = team.teamId == t.teamId;
                    return GestureDetector(
                      onTap: isCurrent ? null : () => setState(() => _selectedId = t.teamId),
                      child: AnimatedContainer(
                        duration: 200.ms,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              t.primary.withValues(alpha: isCurrent ? 0.4 : (selected ? 1.0 : 0.7)),
                              t.secondary.withValues(alpha: isCurrent ? 0.4 : (selected ? 1.0 : 0.7)),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(DTokens.r16),
                          border: Border.all(
                            color: selected ? Colors.white : Colors.transparent,
                            width: 2,
                          ),
                          boxShadow: selected
                              ? [BoxShadow(color: t.primary.withValues(alpha: 0.45), blurRadius: 18)]
                              : null,
                        ),
                        padding: const EdgeInsets.all(DTokens.s12),
                        child: Row(
                          children: [
                            DTeamCrest(team: t, size: 36),
                            const SizedBox(width: DTokens.s8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(t.teamName,
                                      style: DType.body(14, FontWeight.w800).copyWith(color: t.accent),
                                      overflow: TextOverflow.ellipsis),
                                  if (isCurrent)
                                    Text('현재 팀',
                                        style: DType.label(11, color: t.accent.withValues(alpha: 0.7))),
                                ],
                              ),
                            ),
                            if (selected)
                              Icon(Icons.check_circle_rounded, size: 16, color: Colors.white),
                          ],
                        ),
                      ).animate().fadeIn(delay: Duration(milliseconds: 40 * i)),
                    );
                  },
                ),
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
              label: _selectedId == null ? '팀을 선택해 주세요' : '변경하기',
              icon: Icons.swap_horiz_rounded,
              loading: _loading,
              onPressed: _selectedId == null ? null : _confirm,
            ),
          ),
        ],
      ),
    );
  }
}
