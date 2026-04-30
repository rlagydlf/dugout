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
import '../../shared/widgets/d_effects.dart';
import '../../shared/widgets/d_glass_panel.dart';
import '../../shared/widgets/d_team_crest.dart';

class TeamChangeScreen extends ConsumerStatefulWidget {
  const TeamChangeScreen({super.key});
  @override
  ConsumerState<TeamChangeScreen> createState() => _TeamChangeScreenState();
}

class _TeamChangeScreenState extends ConsumerState<TeamChangeScreen> {
  String? _selectedId;
  bool _loading = false;
  bool _showParticles = false;

  Future<void> _confirm() async {
    if (_selectedId == null) return;
    setState(() => _loading = true);
    await ref.read(currentTeamProvider.notifier).select(_selectedId!);
    ref.read(userProvider.notifier).selectTeam(_selectedId!);
    if (!mounted) return;
    setState(() {
      _loading = false;
      _showParticles = true;
    });
    await Future.delayed(const Duration(milliseconds: 1600));
    if (!mounted) return;
    setState(() => _showParticles = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '응원팀이 ${TeamThemes.byId(_selectedId).teamName}으로 변경되었습니다.',
          style: DType.body(14).copyWith(color: Colors.white),
        ),
        backgroundColor: context.team.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DTokens.r12)),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final team = context.team;
    final teams = TeamThemes.all;
    final preview =
        _selectedId != null ? TeamThemes.byId(_selectedId) : team;

    return Scaffold(
      backgroundColor: DTokens.bgDark,
      appBar: AppBar(
        backgroundColor: DTokens.bgDark,
        elevation: 0,
        title: Text('응원팀 변경', style: DType.heading(17, color: Colors.white)),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(DTokens.s16),
                  children: [
                    // ── 정책 안내
                    DGlassPanel(
                      padding: const EdgeInsets.all(DTokens.s16),
                      radius: DTokens.r20,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: DTokens.warning.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.policy_rounded,
                                size: 18, color: DTokens.warning),
                          ),
                          const SizedBox(width: DTokens.s12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '응원팀 변경 정책',
                                  style: DType.body(14, FontWeight.w800)
                                      .copyWith(color: DTokens.warning),
                                ),
                                const SizedBox(height: DTokens.s8),
                                Text(
                                  '• 시즌 중 1회만 변경 가능합니다\n'
                                  '• 기존 팀 기여도는 초기화됩니다\n'
                                  '• 포인트·배지는 유지됩니다\n'
                                  '• 다음 시즌(2027)에 재변경 가능',
                                  style: DType.body(13).copyWith(
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

                    const SizedBox(height: DTokens.s16),

                    // ── 선택 미리보기
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.all(DTokens.s16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            preview.primary.withValues(alpha: 0.22),
                            preview.secondary.withValues(alpha: 0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(DTokens.r20),
                        border: Border.all(
                            color: preview.primary.withValues(alpha: 0.35)),
                      ),
                      child: Row(
                        children: [
                          DTeamCrest(
                              team: preview,
                              size: 52,
                              glow: _selectedId != null),
                          const SizedBox(width: DTokens.s14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedId == null
                                    ? '팀을 선택하세요'
                                    : preview.teamName,
                                style: DType.heading(17,
                                    color: DTokens.textPrimaryDark),
                              ),
                              Text(
                                _selectedId == null
                                    ? '아래 그리드에서 팀을 선택해 주세요'
                                    : preview.slogan,
                                style: DType.caption(13,
                                    color: DTokens.textSecondaryDark),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: DTokens.s20),

                    // ── 10팀 그리드 (마스코트 cropped + 3D tilt)
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: DTokens.s8,
                        crossAxisSpacing: DTokens.s8,
                        childAspectRatio: 1.55,
                      ),
                      itemCount: teams.length,
                      itemBuilder: (context, i) {
                        final t = teams[i];
                        final selected = _selectedId == t.teamId;
                        final isCurrent = team.teamId == t.teamId;
                        return D3DTiltCard(
                          maxTiltDeg: 7,
                          onTap: isCurrent
                              ? null
                              : () =>
                                  setState(() => _selectedId = t.teamId),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  t.primary.withValues(
                                      alpha: isCurrent
                                          ? 0.35
                                          : (selected ? 1.0 : 0.72)),
                                  t.secondary.withValues(
                                      alpha: isCurrent
                                          ? 0.35
                                          : (selected ? 1.0 : 0.72)),
                                ],
                              ),
                              borderRadius:
                                  BorderRadius.circular(DTokens.r16),
                              border: Border.all(
                                color: selected
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.08),
                                width: selected ? 2 : 1,
                              ),
                              boxShadow: selected
                                  ? [
                                      BoxShadow(
                                        color: t.primary
                                            .withValues(alpha: 0.45),
                                        blurRadius: 20,
                                        spreadRadius: 1,
                                      )
                                    ]
                                  : null,
                            ),
                            child: Stack(
                              children: [
                                // 마스코트 배경 (cropped)
                                Positioned(
                                  right: -8,
                                  bottom: -4,
                                  child: Opacity(
                                    opacity: 0.22,
                                    child: Image.asset(
                                      t.mascotAsset,
                                      height: 60,
                                      fit: BoxFit.contain,
                                      errorBuilder: (e, s, _) =>
                                          const SizedBox.shrink(),
                                    ),
                                  ),
                                ),
                                // 콘텐츠
                                Padding(
                                  padding: const EdgeInsets.all(DTokens.s12),
                                  child: Row(
                                    children: [
                                      DTeamCrest(team: t, size: 36),
                                      const SizedBox(width: DTokens.s8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              t.teamName,
                                              style: DType.body(
                                                      13, FontWeight.w800)
                                                  .copyWith(color: t.accent),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            if (isCurrent)
                                              Text(
                                                '현재 팀',
                                                style: DType.label(10,
                                                    color: t.accent
                                                        .withValues(
                                                            alpha: 0.7)),
                                              ),
                                          ],
                                        ),
                                      ),
                                      if (selected)
                                        const Icon(
                                            Icons.check_circle_rounded,
                                            size: 16,
                                            color: Colors.white),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ).animate().fadeIn(
                            delay: Duration(milliseconds: 40 * i));
                      },
                    ),
                  ],
                ),
              ),

              // ── 변경 CTA
              Container(
                padding: EdgeInsets.fromLTRB(
                  DTokens.s16,
                  DTokens.s12,
                  DTokens.s16,
                  MediaQuery.of(context).padding.bottom + DTokens.s12,
                ),
                decoration: const BoxDecoration(
                  color: DTokens.bgDark,
                  border:
                      Border(top: BorderSide(color: DTokens.borderDark)),
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

          // ── 파티클 (변경 확정 시)
          if (_showParticles)
            Positioned.fill(
              child: IgnorePointer(
                child: DExplosionParticles(
                  color: team.primary,
                  accentColor: team.accent,
                  count: 28,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
