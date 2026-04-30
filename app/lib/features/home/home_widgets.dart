import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../app/theme/team_theme.dart';
import '../../app/theme/tokens.dart';
import '../../app/theme/typography.dart';

// ── constants ─────────────────────────────────────────────────────────────────

const kHomeRivalId = 'doosan';
const kHomeRivalFraction = 0.38;
const kHomeSortieCount = '12,408';
const kHomeActivePred = '3';
const kHomeContrib = '78%';

const kHomeNewsItems = [
  ('scoreboard.png', '오늘의 시리즈', 'LG vs 두산 잠실 1차전'),
  ('stadium.png', '이번 주 미션', '도전 미션 3개 진행 중'),
  ('baseball.png', '오스틴 키플레이어', '3안타 1홈런 페이스'),
];

// ── scanline painter ──────────────────────────────────────────────────────────

class ScanlinePainter extends CustomPainter {
  const ScanlinePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.18)
      ..strokeWidth = 1;
    for (double y = 0; y < size.height; y += 3) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ── stat LED panel ────────────────────────────────────────────────────────────

class HomeStatLedPanel extends StatelessWidget {
  final TeamTheme team;
  const HomeStatLedPanel({super.key, required this.team});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D1017),
        borderRadius: BorderRadius.circular(DTokens.r16),
        border: Border.all(color: team.primary.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: team.primary.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(DTokens.r16),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(painter: ScanlinePainter()),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: DTokens.s16, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _LedStat(
                      value: kHomeSortieCount,
                      label: '오늘 출정',
                      accent: team.primary,
                    ),
                  ),
                  Container(
                      width: 1,
                      height: 40,
                      color: team.primary.withValues(alpha: 0.2)),
                  Expanded(
                    child: _LedStat(
                      value: kHomeActivePred,
                      label: '예측 진행',
                      accent: DTokens.warning,
                    ),
                  ),
                  Container(
                      width: 1,
                      height: 40,
                      color: team.primary.withValues(alpha: 0.2)),
                  Expanded(
                    child: _LedStat(
                      value: kHomeContrib,
                      label: '기여도',
                      accent: DTokens.success,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate(delay: 70.ms).fadeIn(duration: 380.ms);
  }
}

class _LedStat extends StatelessWidget {
  final String value;
  final String label;
  final Color accent;
  const _LedStat(
      {required this.value, required this.label, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(value,
            textAlign: TextAlign.center,
            style: DType.scoreboardDigital(32, color: accent)),
        const SizedBox(height: 3),
        Text(label.toUpperCase(),
            style: DType.micro(11, color: DTokens.textTertiaryDark),
            textAlign: TextAlign.center),
      ],
    );
  }
}

// ── action tile ───────────────────────────────────────────────────────────────

class HomeActionTile extends StatelessWidget {
  final String iconAsset;
  final String label;
  final String sublabel;
  final String? badge;
  final bool isLive;
  final Color accent;
  final VoidCallback onTap;

  const HomeActionTile({
    super.key,
    required this.iconAsset,
    required this.label,
    required this.sublabel,
    required this.badge,
    required this.isLive,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: DTokens.surfaceDark,
          borderRadius: BorderRadius.circular(DTokens.r20),
          border: Border.all(color: accent.withValues(alpha: 0.22)),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              left: -24,
              top: -24,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent.withValues(alpha: 0.08),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(DTokens.s16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(DTokens.r12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(11),
                      child: Image.asset(
                        iconAsset,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.sports_baseball,
                                size: 22, color: accent),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(sublabel,
                          style: DType.micro(10,
                              color: accent.withValues(alpha: 0.75))),
                      const SizedBox(height: 3),
                      Text(label,
                          style: DType.body(15, FontWeight.w800).copyWith(
                              color: DTokens.textPrimaryDark,
                              height: 1.2)),
                    ],
                  ),
                ],
              ),
            ),
            if (badge != null)
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: isLive ? DTokens.danger : accent,
                    borderRadius: BorderRadius.circular(DTokens.rPill),
                    boxShadow: [
                      BoxShadow(
                        color: (isLive ? DTokens.danger : accent)
                            .withValues(alpha: 0.55),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Text(badge!,
                      style: DType.badge(11, color: Colors.white)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
