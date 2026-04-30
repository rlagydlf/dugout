import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import '../../app/theme/tokens.dart';

/// 스코어보드 스타일 숫자 + 라벨. 야구장 기록판 모티프.
class DScoreboard extends StatelessWidget {
  final String value;
  final String label;
  final Color? accent;
  final double valueSize;
  final TextAlign align;

  const DScoreboard({
    super.key,
    required this.value,
    required this.label,
    this.accent,
    this.valueSize = 32,
    this.align = TextAlign.left,
  });

  @override
  Widget build(BuildContext context) {
    final team = context.team;
    final c = accent ?? team.primary;
    return Column(
      crossAxisAlignment: align == TextAlign.left
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        ShaderMask(
          shaderCallback: (rect) => LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, c],
          ).createShader(rect),
          child: Text(
            value,
            style: TextStyle(
              fontSize: valueSize,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              height: 1.0,
              color: Colors.white,
              fontFamilyFallback: const ['Courier', 'monospace'],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label.toUpperCase(),
          textAlign: align,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
            color: DTokens.textSecondaryDark,
          ),
        ),
      ],
    );
  }
}

/// 큰 영문 임팩트 텍스트 (스타디움 LED 같은).
class DImpactText extends StatelessWidget {
  final String text;
  final double size;
  final Color? color;
  final bool gradient;

  const DImpactText({
    super.key,
    required this.text,
    this.size = 56,
    this.color,
    this.gradient = false,
  });

  @override
  Widget build(BuildContext context) {
    final team = context.team;
    final base = TextStyle(
      fontSize: size,
      fontWeight: FontWeight.w900,
      height: 0.95,
      letterSpacing: 4,
      color: color ?? Colors.white,
      fontFamilyFallback: const ['Impact', 'Anton', 'BebasNeue'],
    );
    if (!gradient) return Text(text, style: base);
    return ShaderMask(
      shaderCallback: (rect) => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.white, team.primary],
      ).createShader(rect),
      child: Text(text, style: base),
    );
  }
}
