import 'package:flutter/material.dart';

import '../../app/theme/team_theme.dart';

/// 팀 엠블럼 표시. 이미지 없을 시 팀 이니셜 + 컬러 배경 fallback.
class DTeamCrest extends StatelessWidget {
  final TeamTheme team;
  final double size;
  final bool glow;

  const DTeamCrest({
    super.key,
    required this.team,
    this.size = 64,
    this.glow = false,
  });

  @override
  Widget build(BuildContext context) {
    final initial = team.teamShortName.isNotEmpty
        ? team.teamShortName.substring(0, 1)
        : '?';

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [team.primary, team.secondary],
        ),
        boxShadow: glow
            ? [
                BoxShadow(
                  color: team.primary.withValues(alpha: 0.55),
                  blurRadius: size * 0.6,
                  spreadRadius: size * 0.05,
                ),
              ]
            : null,
      ),
      alignment: Alignment.center,
      child: ClipOval(
        child: Image.asset(
          team.crestAsset,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (e, s, t) => Center(
            child: Text(
              initial,
              style: TextStyle(
                fontSize: size * 0.42,
                fontWeight: FontWeight.w900,
                color: team.accent,
                letterSpacing: -1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
