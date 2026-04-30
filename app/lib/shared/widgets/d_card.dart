import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import '../../app/theme/tokens.dart';

/// 기본 카드. 팀 액센트가 살짝 입혀진 surface.
class DCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final Color? color;
  final bool gradientHeader;

  const DCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(DTokens.s16),
    this.onTap,
    this.color,
    this.gradientHeader = false,
  });

  @override
  Widget build(BuildContext context) {
    final team = context.team;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(DTokens.r16),
      side: BorderSide(color: DTokens.borderDark),
    );

    final content = Container(
      decoration: BoxDecoration(
        color: color ?? DTokens.surfaceDark,
        borderRadius: BorderRadius.circular(DTokens.r16),
        border: Border.all(color: DTokens.borderDark),
        gradient: gradientHeader
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  team.primary.withValues(alpha: 0.18),
                  DTokens.surfaceDark,
                ],
              )
            : null,
      ),
      padding: padding,
      child: child,
    );

    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      shape: shape,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DTokens.r16),
        child: content,
      ),
    );
  }
}
