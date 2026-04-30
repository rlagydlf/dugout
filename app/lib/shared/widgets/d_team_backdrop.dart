import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import '../../app/theme/tokens.dart';

/// 팀 분위기 배경 — 마스코트/패턴/그라디언트가 결합된 hero 영역.
class DTeamBackdrop extends StatelessWidget {
  final Widget child;
  final double height;
  final bool showMascot;
  final bool showPattern;
  final double radius;

  const DTeamBackdrop({
    super.key,
    required this.child,
    this.height = 220,
    this.showMascot = true,
    this.showPattern = true,
    this.radius = DTokens.r24,
  });

  @override
  Widget build(BuildContext context) {
    final team = context.team;
    return Container(
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: team.primary.withValues(alpha: 0.45),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // base gradient (3-stops 깊이)
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  team.primary,
                  Color.lerp(team.primary, team.secondary, 0.45)!,
                  team.secondary.withValues(alpha: 0.85),
                ],
                stops: const [0.0, 0.55, 1.0],
              ),
            ),
          ),
          // pattern overlay (있으면)
          if (showPattern)
            Positioned.fill(
              child: Opacity(
                opacity: 0.18,
                child: Image.asset(
                  team.patternAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (e, s, t) => const SizedBox.shrink(),
                ),
              ),
            ),
          // mascot 살짝 우하단 cropped
          if (showMascot)
            Positioned(
              right: -32,
              bottom: -32,
              child: Image.asset(
                team.mascotAsset,
                width: height * 1.05,
                height: height * 1.05,
                fit: BoxFit.contain,
                errorBuilder: (e, s, t) => Icon(
                  Icons.sports_baseball_rounded,
                  size: height * 0.85,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
          // top vignette to improve text contrast
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.2),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.4),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
          // content
          Padding(
            padding: const EdgeInsets.all(DTokens.s20),
            child: child,
          ),
        ],
      ),
    );
  }
}
