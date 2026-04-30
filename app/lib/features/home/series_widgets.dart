import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../app/theme/team_theme.dart';
import '../../app/theme/tokens.dart';
import '../../app/theme/typography.dart';

// ── shared mock constants ─────────────────────────────────────────────────────

const kSeriesInningScores = <(int, int)>[
  (0, 0), (1, 0), (0, 1), (1, 0), (1, 1),
  (-1, -1), (-1, -1), (-1, -1), (-1, -1),
];
const kSeriesCurrentInning = 5;

const kSeriesTimeline = <(String, String, String)>[
  ('bolt.png',     '5회 말', 'LG 오스틴 딘 솔로 홈런 — 3:2'),
  ('baseball.png', '4회 말', 'LG 박동원 2루타'),
  ('mitt.png',     '4회 초', '두산 김택연 삼진 아웃'),
  ('baseball.png', '3회 초', '두산 양의지 적시타 — 1:1'),
];

const kSeriesQuests = <(String, String, int)>[
  ('경기일',   '경기 시작 전 출정 완료', 50),
  ('예측',     '승리팀 예측 참여',       30),
  ('라이벌전', '이닝 키플레이어 맞추기', 80),
];

const kSeriesPredictions = <(String, String, String)>[
  ('승리팀',    'LG 트윈스', '1.85'),
  ('키플레이어', '오스틴 딘', '2.40'),
  ('장타 여부', '있음',      '1.60'),
];

const kSeriesFanRows = <(String, String, String, double)>[
  ('출정 인원',    '12,408', '9,871',  0.65),
  ('퀘스트 완료율', '68%',   '51%',   0.68),
  ('기여도 합산',  '48,220', '37,640', 0.56),
];

// ── pitcher cards ─────────────────────────────────────────────────────────────

class SeriesPitcherCards extends StatelessWidget {
  final TeamTheme home;
  final TeamTheme away;
  const SeriesPitcherCards(
      {super.key, required this.home, required this.away});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _PitcherCard(
              team: home, name: '임찬규', number: '39', era: '3.12'),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _PitcherCard(
              team: away, name: '곽빈', number: '13', era: '3.87'),
        ),
      ],
    );
  }
}

class _PitcherCard extends StatelessWidget {
  final TeamTheme team;
  final String name;
  final String number;
  final String era;
  const _PitcherCard({
    required this.team,
    required this.name,
    required this.number,
    required this.era,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: DTokens.surfaceDark,
        borderRadius: BorderRadius.circular(DTokens.r16),
        border: Border.all(color: team.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('선발 투수',
              style: DType.label(11,
                  color: team.primary.withValues(alpha: 0.7))),
          const SizedBox(height: DTokens.s4),
          Row(
            children: [
              Text('#$number',
                  style: DType.scoreboardDigital(20, color: team.primary)),
              const SizedBox(width: DTokens.s8),
              Text(name,
                  style: DType.body(15, FontWeight.w800)
                      .copyWith(color: DTokens.textPrimaryDark)),
            ],
          ),
          const SizedBox(height: DTokens.s8),
          Row(
            children: [
              Text('ERA',
                  style: DType.label(11, color: DTokens.textTertiaryDark)),
              const SizedBox(width: 6),
              Text(era,
                  style: DType.mono(14, color: DTokens.textSecondaryDark)),
            ],
          ),
        ],
      ),
    ).animate(delay: 80.ms).fadeIn(duration: 350.ms).slideY(begin: 0.05);
  }
}

// ── live timeline ─────────────────────────────────────────────────────────────

class SeriesTimeline extends StatelessWidget {
  const SeriesTimeline({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SeriesSectionLabel(
            text: '라이브 이벤트', accent: DTokens.danger),
        const SizedBox(height: 14),
        ...List.generate(kSeriesTimeline.length, (i) {
          final item = kSeriesTimeline[i];
          return _TimelineRow(
            iconAsset: 'assets/images/icons/${item.$1}',
            inning: item.$2,
            desc: item.$3,
            accent: i == 0 ? DTokens.warning : DTokens.textTertiaryDark,
          ).animate(delay: Duration(milliseconds: 80 + 50 * i))
              .fadeIn(duration: 320.ms)
              .slideX(begin: -0.03);
        }),
      ],
    );
  }
}

class _TimelineRow extends StatelessWidget {
  final String iconAsset;
  final String inning;
  final String desc;
  final Color accent;
  const _TimelineRow({
    required this.iconAsset,
    required this.inning,
    required this.desc,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DTokens.s8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 28,
            child: Center(
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: accent.withValues(alpha: 0.5),
                        blurRadius: 6),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: DTokens.s12, vertical: DTokens.s8),
              decoration: BoxDecoration(
                color: DTokens.surfaceDark,
                borderRadius: BorderRadius.circular(DTokens.r12),
                border: Border.all(color: DTokens.borderDark),
              ),
              child: Row(
                children: [
                  Image.asset(
                    iconAsset,
                    width: 18,
                    height: 18,
                    color: accent,
                    colorBlendMode: BlendMode.srcIn,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.sports_baseball, size: 16, color: accent),
                  ),
                  const SizedBox(width: DTokens.s8),
                  Text(inning,
                      style: DType.mono(13,
                          color: DTokens.textTertiaryDark,
                          weight: FontWeight.w500)),
                  const SizedBox(width: DTokens.s8),
                  Expanded(
                    child: Text(desc,
                        style: DType.body(15, FontWeight.w600)
                            .copyWith(color: DTokens.textPrimaryDark)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── section label ─────────────────────────────────────────────────────────────

class SeriesSectionLabel extends StatelessWidget {
  final String text;
  final Color accent;
  const SeriesSectionLabel(
      {super.key, required this.text, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: accent,
            borderRadius: BorderRadius.circular(2),
            boxShadow: [
              BoxShadow(
                  color: accent.withValues(alpha: 0.5), blurRadius: 6),
            ],
          ),
        ),
        const SizedBox(width: DTokens.s8),
        Text(text,
            style: DType.body(16, FontWeight.w800)
                .copyWith(color: DTokens.textPrimaryDark)),
      ],
    );
  }
}

// ── diagonal slash painter ────────────────────────────────────────────────────

class DiagonalSlashPainter extends CustomPainter {
  const DiagonalSlashPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.35)
      ..strokeWidth = size.width * 0.015
      ..style = PaintingStyle.stroke;
    final cx = size.width / 2;
    canvas.drawLine(
        Offset(cx - 2, 0), Offset(cx + 2, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
