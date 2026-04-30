import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import '../../app/theme/tokens.dart';

class DPointBadge extends StatelessWidget {
  final int point;
  final bool compact;

  const DPointBadge({super.key, required this.point, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final team = context.team;
    final formatted = _format(point);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? DTokens.s8 : DTokens.s12,
        vertical: compact ? DTokens.s4 : DTokens.s8,
      ),
      decoration: BoxDecoration(
        color: team.primary.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(DTokens.rPill),
        border: Border.all(color: team.primary.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.diamond_rounded,
              size: compact ? 12 : 14, color: team.primary),
          SizedBox(width: compact ? 4 : 6),
          Text(
            '$formatted P',
            style: TextStyle(
              fontSize: compact ? 12 : 14,
              fontWeight: FontWeight.w700,
              color: team.primary,
            ),
          ),
        ],
      ),
    );
  }

  String _format(int v) {
    if (v < 1000) return '$v';
    final s = v.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}
