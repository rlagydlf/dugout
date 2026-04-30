import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../app/theme/app_theme.dart';
import '../../app/theme/tokens.dart';
import '../../app/theme/typography.dart';

/// 빈 상태 표시 — 리스트가 비어있을 때 (필터 결과 0건, 알림 없음 등).
class DEmptyState extends StatelessWidget {
  final IconData icon;
  final String? iconAsset;
  final String title;
  final String? body;
  final String? ctaLabel;
  final VoidCallback? onCta;
  final EdgeInsets padding;

  const DEmptyState({
    super.key,
    this.icon = Icons.inbox_rounded,
    this.iconAsset,
    required this.title,
    this.body,
    this.ctaLabel,
    this.onCta,
    this.padding = const EdgeInsets.all(DTokens.s32),
  });

  @override
  Widget build(BuildContext context) {
    final team = context.team;
    return Center(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    team.primary.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Center(
                child: iconAsset != null
                    ? Image.asset(
                        iconAsset!,
                        width: 48,
                        errorBuilder: (e, s, t) => Icon(icon, size: 44, color: team.primary.withValues(alpha: 0.6)),
                      )
                    : Icon(icon, size: 44, color: team.primary.withValues(alpha: 0.6)),
              ),
            ).animate().fadeIn(duration: 320.ms).scale(begin: const Offset(0.9, 0.9), curve: Curves.easeOutBack),
            const SizedBox(height: DTokens.s16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: DType.heading(18, color: DTokens.textPrimaryDark, weight: FontWeight.w700),
            ).animate().fadeIn(delay: 120.ms),
            if (body != null) ...[
              const SizedBox(height: DTokens.s8),
              Text(
                body!,
                textAlign: TextAlign.center,
                style: DType.body(14, FontWeight.w400).copyWith(
                  color: DTokens.textSecondaryDark,
                ),
              ).animate().fadeIn(delay: 200.ms),
            ],
            if (ctaLabel != null && onCta != null) ...[
              const SizedBox(height: DTokens.s20),
              TextButton(
                onPressed: onCta,
                style: TextButton.styleFrom(
                  foregroundColor: team.primary,
                  padding: const EdgeInsets.symmetric(horizontal: DTokens.s20, vertical: DTokens.s12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DTokens.rPill),
                    side: BorderSide(color: team.primary.withValues(alpha: 0.4)),
                  ),
                ),
                child: Text(ctaLabel!, style: DType.label(13, color: team.primary, weight: FontWeight.w700)),
              ).animate().fadeIn(delay: 280.ms),
            ],
          ],
        ),
      ),
    );
  }
}
