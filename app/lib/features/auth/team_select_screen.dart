import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/team_theme.dart';
import '../../app/theme/theme_provider.dart';
import '../../app/theme/tokens.dart';
import '../../app/theme/typography.dart';
import '../../core/providers/app_providers.dart';
import '../../shared/widgets/d_button.dart';
import '../../shared/widgets/d_team_crest.dart';

class TeamSelectScreen extends ConsumerStatefulWidget {
  const TeamSelectScreen({super.key});
  @override
  ConsumerState<TeamSelectScreen> createState() => _TeamSelectScreenState();
}

class _TeamSelectScreenState extends ConsumerState<TeamSelectScreen>
    with SingleTickerProviderStateMixin {
  String? _previewTeamId;
  late final AnimationController _glowCtrl;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    super.dispose();
  }

  TeamTheme get _selectedTheme =>
      _previewTeamId != null ? TeamThemes.byId(_previewTeamId) : TeamTheme.defaultTheme;

  @override
  Widget build(BuildContext context) {
    final teams = TeamThemes.all;
    final selected = _selectedTheme;

    return Scaffold(
      backgroundColor: DTokens.bgDark,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── 팀 컬러 radial glow (선택 시 즉시 변환)
          AnimatedContainer(
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topCenter,
                radius: 1.2,
                colors: [
                  selected.primary.withValues(alpha: 0.30),
                  selected.primary.withValues(alpha: 0.06),
                  DTokens.bgDark,
                ],
                stops: const [0.0, 0.4, 1.0],
              ),
            ),
          ),

          // ── 마스코트 배경 (선택한 팀)
          if (_previewTeamId != null)
            Positioned(
              right: -60,
              top: MediaQuery.of(context).padding.top + 40,
              child: Opacity(
                opacity: 0.12,
                child: Image.asset(
                  selected.mascotAsset,
                  width: 280,
                  fit: BoxFit.contain,
                  errorBuilder: (e, s, t) => const SizedBox.shrink(),
                ),
              ),
            ).animate().fadeIn(duration: 400.ms),

          // ── 스캔라인
          Positioned.fill(
            child: CustomPaint(painter: _TeamSelectScanlinePainter()),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── 헤더
                _TeamSelectHeader(
                  onBack: () => context.pop(),
                ),

                const SizedBox(height: DTokens.s16),

                // ── 선택 프리뷰 / 타이틀
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: DTokens.s24),
                  child: _PreviewTitle(
                    selected: selected,
                    hasSelection: _previewTeamId != null,
                    glowCtrl: _glowCtrl,
                  ),
                ),

                const SizedBox(height: DTokens.s20),

                // ── 10팀 그리드
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: DTokens.s16,
                      vertical: DTokens.s4,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: DTokens.s12,
                      crossAxisSpacing: DTokens.s12,
                      childAspectRatio: 1.1,
                    ),
                    itemCount: teams.length,
                    itemBuilder: (context, i) {
                      final t = teams[i];
                      final isSelected = _previewTeamId == t.teamId;
                      return _TeamCard(
                        team: t,
                        selected: isSelected,
                        onTap: () =>
                            setState(() => _previewTeamId = t.teamId),
                      )
                          .animate()
                          .fadeIn(
                            delay: Duration(milliseconds: 50 * i),
                            duration: 350.ms,
                          )
                          .slideY(
                            begin: 0.08,
                            delay: Duration(milliseconds: 50 * i),
                            duration: 400.ms,
                            curve: Curves.easeOutCubic,
                          );
                    },
                  ),
                ),

                // ── 하단 CTA
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    DTokens.s24,
                    DTokens.s12,
                    DTokens.s24,
                    MediaQuery.of(context).padding.bottom + DTokens.s16,
                  ),
                  child: DButton(
                    label: _previewTeamId == null
                        ? '팀을 선택해 주세요'
                        : '${selected.teamShortName} 선택 완료',
                    icon: _previewTeamId == null
                        ? null
                        : Icons.check_rounded,
                    onPressed: _previewTeamId == null
                        ? null
                        : () async {
                            final router = GoRouter.of(context);
                            await ref
                                .read(currentTeamProvider.notifier)
                                .select(_previewTeamId!);
                            ref
                                .read(userProvider.notifier)
                                .selectTeam(_previewTeamId!);
                            if (!mounted) return;
                            router.go('/home');
                          },
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

// ── Header ────────────────────────────────────────────────────────────────────

class _TeamSelectHeader extends StatelessWidget {
  final VoidCallback onBack;
  const _TeamSelectHeader({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          DTokens.s16, DTokens.s12, DTokens.s16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: DTokens.surfaceDark,
                borderRadius: BorderRadius.circular(DTokens.r12),
                border: Border.all(color: DTokens.borderDark),
              ),
              child: const Icon(Icons.arrow_back_rounded,
                  size: 20, color: Colors.white),
            ),
          ),
          const SizedBox(width: DTokens.s12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('CHOOSE YOUR TEAM',
                  style: DType.label(12, color: Colors.white.withValues(alpha: 0.7))),
              Text('응원팀 선택',
                  style: DType.heading(20, color: Colors.white)),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}

// ── Preview title ─────────────────────────────────────────────────────────────

class _PreviewTitle extends StatelessWidget {
  final TeamTheme selected;
  final bool hasSelection;
  final AnimationController glowCtrl;

  const _PreviewTitle({
    required this.selected,
    required this.hasSelection,
    required this.glowCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      transitionBuilder: (child, anim) =>
          FadeTransition(opacity: anim, child: child),
      child: hasSelection
          ? _SelectedPreview(
              key: ValueKey(selected.teamId),
              team: selected,
              glowCtrl: glowCtrl,
            )
          : _NoSelectionHint(key: const ValueKey('hint')),
    );
  }
}

class _NoSelectionHint extends StatelessWidget {
  const _NoSelectionHint({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '나의 팀을\n선택하세요',
          style: DType.heading(30, color: Colors.white),
        ),
        const SizedBox(height: DTokens.s8),
        Text(
          '선택한 팀의 컬러로 앱 전체가 바뀝니다',
          style: DType.body(16).copyWith(
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}

class _SelectedPreview extends StatelessWidget {
  final TeamTheme team;
  final AnimationController glowCtrl;
  const _SelectedPreview({
    super.key,
    required this.team,
    required this.glowCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 팀 로고 (실제 KBO PNG)
        AnimatedBuilder(
          animation: glowCtrl,
          builder: (context, child) => Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: team.primary
                      .withValues(alpha: 0.35 + glowCtrl.value * 0.35),
                  blurRadius: 24 + glowCtrl.value * 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: child,
          ),
          child: ClipOval(
            child: Image.asset(
              team.crestAsset,
              width: 72,
              height: 72,
              fit: BoxFit.contain,
              errorBuilder: (e, s, t) =>
                  DTeamCrest(team: team, size: 72, glow: true),
            ),
          ),
        ),
        const SizedBox(width: DTokens.s16),

        // 텍스트 영역
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 영문 ALL CAPS 팀 숏네임
              Text(
                team.teamShortName.toUpperCase(),
                style: DType.label(14, color: team.primary),
              ),
              // 한글 팀명
              Text(
                team.teamName,
                style: DType.heading(22, color: Colors.white),
              ),
              const SizedBox(height: DTokens.s4),
              // tagline
              Text(
                '"${team.tagline}"',
                style: DType.body(14).copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Team card ─────────────────────────────────────────────────────────────────

class _TeamCard extends StatelessWidget {
  final TeamTheme team;
  final bool selected;
  final VoidCallback onTap;
  const _TeamCard({
    required this.team,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(DTokens.r20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.lerp(team.primary, Colors.black, selected ? 0.25 : 0.45)!,
              Color.lerp(team.secondary, Colors.black, selected ? 0.1 : 0.35)!,
            ],
          ),
          border: Border.all(
            color: selected
                ? team.primary
                : Colors.white.withValues(alpha: 0.07),
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: team.primary.withValues(alpha: 0.5),
                    blurRadius: 24,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Stack(
          children: [
            // ── 마스코트 배경 (우하단 cropped)
            Positioned(
              right: -20,
              bottom: -20,
              child: Opacity(
                opacity: selected ? 0.35 : 0.18,
                child: Image.asset(
                  team.mascotAsset,
                  width: 100,
                  fit: BoxFit.contain,
                  errorBuilder: (e, s, t) => const SizedBox.shrink(),
                ),
              ),
            ),

            // ── 패턴 텍스처
            Positioned.fill(
              child: Opacity(
                opacity: 0.08,
                child: Image.asset(
                  team.patternAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (e, s, t) => const SizedBox.shrink(),
                ),
              ),
            ),

            // ── 선택 체크마크
            if (selected)
              Positioned(
                top: DTokens.s8,
                right: DTokens.s8,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: team.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_rounded,
                      size: 13, color: Colors.white),
                ).animate().scale(
                      begin: const Offset(0, 0),
                      duration: 300.ms,
                      curve: Curves.easeOutBack,
                    ),
              ),

            // ── 콘텐츠
            Padding(
              padding: const EdgeInsets.all(DTokens.s14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 실제 KBO 로고
                  Image.asset(
                    team.crestAsset,
                    width: 52,
                    height: 52,
                    fit: BoxFit.contain,
                    errorBuilder: (e, s, t) =>
                        DTeamCrest(team: team, size: 52),
                  ),
                  const Spacer(),
                  // 영문 ALL CAPS
                  Text(
                    team.teamShortName.toUpperCase(),
                    style: DType.label(11,
                        color: selected
                            ? team.primary
                            : Colors.white.withValues(alpha: 0.9)),
                  ),
                  const SizedBox(height: 2),
                  // 한글 팀명
                  Text(
                    team.teamName,
                    style: DType.body(14, FontWeight.w700).copyWith(
                      color: team.accent.withValues(alpha: 0.9),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  // 구장명
                  Text(
                    team.stadium,
                    style: DType.label(11,
                        color: Colors.white.withValues(alpha: 0.6)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Painter ───────────────────────────────────────────────────────────────────

class _TeamSelectScanlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.013)
      ..strokeWidth = 1;
    for (double y = 0; y < size.height; y += 3) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
