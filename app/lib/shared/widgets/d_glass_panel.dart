import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import '../../app/theme/tokens.dart';

/// 글래스모피즘 패널 — Impeller 호환을 위해 BackdropFilter 제거,
/// 다크 surface + 그라데이션 라이팅 + 보더로 동일한 시각 표현.
class DGlassPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double radius;
  final double blur; // 호환성 유지 (사용되지 않음)
  final double opacity;
  final bool teamBorder;
  final VoidCallback? onTap;

  const DGlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(DTokens.s16),
    this.radius = DTokens.r20,
    this.blur = DTokens.blurMd,
    this.opacity = 0.55,
    this.teamBorder = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final team = context.team;
    final content = Container(
      decoration: BoxDecoration(
        color: DTokens.surfaceDark.withValues(alpha: opacity.clamp(0.3, 1.0)),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: teamBorder
              ? team.primary.withValues(alpha: 0.45)
              : Colors.white.withValues(alpha: 0.06),
          width: 1,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.04),
            Colors.transparent,
          ],
        ),
      ),
      padding: padding,
      child: child,
    );

    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: content,
      ),
    );
  }
}
