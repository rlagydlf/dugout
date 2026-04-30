import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_theme.dart';
import '../../app/theme/tokens.dart';
import '../../app/theme/typography.dart';
import '../../core/providers/app_providers.dart';
import '../../shared/widgets/d_glass_panel.dart';
import '../../shared/widgets/d_scoreboard.dart';

// ── icon helpers ──────────────────────────────────────────────────────────────

String _entryIcon(String title) {
  if (title.contains('출정')) return 'assets/images/icons/bolt.png';
  if (title.contains('퀘스트')) return 'assets/images/icons/trophy.png';
  if (title.contains('예측')) return 'assets/images/icons/scoreboard.png';
  if (title.contains('체크인') || title.contains('출석')) return 'assets/images/icons/stadium.png';
  if (title.contains('교환')) return 'assets/images/icons/bats.png';
  if (title.contains('초대') || title.contains('보너스')) return 'assets/images/icons/megaphone.png';
  return 'assets/images/icons/baseball.png';
}

IconData _entryFallback(String title) {
  if (title.contains('출정')) return Icons.rocket_launch_rounded;
  if (title.contains('퀘스트')) return Icons.assignment_turned_in_rounded;
  if (title.contains('예측')) return Icons.psychology_rounded;
  if (title.contains('교환')) return Icons.swap_horiz_rounded;
  if (title.contains('초대')) return Icons.person_add_rounded;
  return Icons.diamond_rounded;
}

// ── mock ──────────────────────────────────────────────────────────────────────

class _Entry {
  final String title;
  final int amount;
  final String category;
  final DateTime time;
  const _Entry({
    required this.title,
    required this.amount,
    required this.category,
    required this.time,
  });
}

DateTime _ago(int hours) => DateTime.now().subtract(Duration(hours: hours));

final _entries = [
  _Entry(title: '출정 완료', amount: 50, category: '적립', time: _ago(0)),
  _Entry(title: '일일 퀘스트 완료', amount: 30, category: '적립', time: _ago(4)),
  _Entry(title: '승리팀 예측 적중', amount: 200, category: '적립', time: _ago(24)),
  _Entry(title: '스타벅스 아메리카노 교환', amount: -4500, category: '사용', time: _ago(48)),
  _Entry(title: '광고 시청', amount: 5, category: '적립', time: _ago(48)),
  _Entry(title: '출석 체크', amount: 10, category: '적립', time: _ago(72)),
  _Entry(title: '예측 첫 참여 보너스', amount: 100, category: '적립', time: _ago(96)),
  _Entry(title: 'CGV 영화 1매 교환', amount: -8500, category: '사용', time: _ago(120)),
  _Entry(title: '경기 응원 댓글 3개', amount: 15, category: '적립', time: _ago(144)),
  _Entry(title: '출정 완료', amount: 50, category: '적립', time: _ago(168)),
  _Entry(title: '친구 초대 보너스', amount: 500, category: '적립', time: _ago(192)),
  _Entry(title: '퀘스트 연속 달성', amount: 80, category: '적립', time: _ago(216)),
  _Entry(title: '응원봉 교환', amount: -12000, category: '사용', time: _ago(240)),
  _Entry(title: '출정 완료', amount: 50, category: '적립', time: _ago(264)),
  _Entry(title: '출석 체크', amount: 10, category: '적립', time: _ago(288)),
];

String _fmt(int v) {
  final s = v.abs().toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return buf.toString();
}

// ── Screen ────────────────────────────────────────────────────────────────────

class PointLedgerScreen extends ConsumerStatefulWidget {
  const PointLedgerScreen({super.key});
  @override
  ConsumerState<PointLedgerScreen> createState() => _PointLedgerScreenState();
}

class _PointLedgerScreenState extends ConsumerState<PointLedgerScreen> {
  String _filter = '전체';

  List<_Entry> get _filtered {
    if (_filter == '전체') return _entries;
    return _entries.where((e) => e.category == _filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final team = context.team;
    final user = ref.watch(userProvider);
    final filtered = _filtered;

    final earned = _entries.where((e) => e.amount > 0).fold(0, (a, b) => a + b.amount);
    final spent = _entries.where((e) => e.amount < 0).fold(0, (a, b) => a + b.amount.abs());

    return Scaffold(
      backgroundColor: DTokens.bgDark,
      appBar: AppBar(
        backgroundColor: DTokens.bgDark,
        elevation: 0,
        leading: const BackButton(),
        title: Row(
          children: [
            Image.asset(
              'assets/images/icons/scoreboard.png',
              width: 20,
              height: 20,
              errorBuilder: (e, s, t) =>
                  Icon(Icons.account_balance_wallet_rounded, size: 20, color: team.primary),
            ),
            const SizedBox(width: DTokens.s8),
            Text('포인트 내역', style: DType.heading(17, color: Colors.white)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: DTokens.s16),
            child: _PointChip(point: user.point, teamColor: team.primary),
          ),
        ],
      ),
      body: Stack(
        children: [
          // 팀컬러 글로우
          Positioned(
            top: -40,
            left: -40,
            right: -40,
            child: Container(
              height: 240,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 0.8,
                  colors: [
                    team.primary.withValues(alpha: 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          CustomScrollView(
            slivers: [
              // ── 잔액 카드
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(DTokens.s16, DTokens.s8, DTokens.s16, 0),
                  child: _BalanceCard(
                    point: user.point,
                    earned: earned,
                    spent: spent,
                  ),
                ),
              ),

              // ── 필터 칩
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(DTokens.s16, DTokens.s20, DTokens.s16, DTokens.s12),
                  child: _FilterRow(
                    filter: _filter,
                    onSelect: (v) => setState(() => _filter = v),
                  ),
                ),
              ),

              // ── 내역 리스트
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  DTokens.s16,
                  0,
                  DTokens.s16,
                  MediaQuery.of(context).padding.bottom + DTokens.s24,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      if (i >= filtered.length) return null;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: DTokens.s8),
                        child: _EntryTile(entry: filtered[i])
                            .animate()
                            .fadeIn(delay: Duration(milliseconds: 30 * i))
                            .slideX(begin: -0.04),
                      );
                    },
                    childCount: filtered.length,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── balance card ──────────────────────────────────────────────────────────────

class _BalanceCard extends StatelessWidget {
  final int point;
  final int earned;
  final int spent;
  const _BalanceCard({required this.point, required this.earned, required this.spent});

  @override
  Widget build(BuildContext context) {
    final team = context.team;
    final total = (earned + spent).toDouble();
    final earnedRatio = total == 0 ? 0.5 : earned / total;

    return ClipRRect(
      borderRadius: BorderRadius.circular(DTokens.r24),
      child: Container(
        height: 8,
        decoration: BoxDecoration(
          color: team.primary,
          boxShadow: [
            BoxShadow(
              color: team.primary.withValues(alpha: 0.5),
              blurRadius: 6,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 450.ms).slideY(begin: 0.05);
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  final int value;
  const _Legend({required this.color, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: DType.body(11).copyWith(color: DTokens.textSecondaryDark)),
        const SizedBox(width: DTokens.s4),
        Text(
          '${_fmt(value)} P',
          style: DType.mono(12, color: color, weight: FontWeight.w700),
        ),
      ],
    );
  }
}

// ── filter row ────────────────────────────────────────────────────────────────

class _FilterRow extends StatelessWidget {
  final String filter;
  final ValueChanged<String> onSelect;
  const _FilterRow({required this.filter, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final team = context.team;
    return Row(
      children: ['전체', '적립', '사용'].map((label) {
        final selected = filter == label;
        return Padding(
          padding: const EdgeInsets.only(right: DTokens.s8),
          child: GestureDetector(
            onTap: () => onSelect(label),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: DTokens.s16, vertical: DTokens.s8),
              decoration: BoxDecoration(
                color: selected ? team.primary : DTokens.surfaceDark,
                borderRadius: BorderRadius.circular(DTokens.rPill),
                border: Border.all(
                  color: selected ? team.primary : DTokens.borderDark,
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: team.primary.withValues(alpha: 0.4),
                          blurRadius: 10,
                        ),
                      ]
                    : null,
              ),
              child: Text(
                label,
                style: DType.label(13, color: selected ? Colors.white : DTokens.textSecondaryDark),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── entry tile ────────────────────────────────────────────────────────────────

class _EntryTile extends StatelessWidget {
  final _Entry entry;
  const _EntryTile({required this.entry});

  String _timeLabel(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    return '${diff.inDays}일 전';
  }

  @override
  Widget build(BuildContext context) {
    final team = context.team;
    final isPlus = entry.amount > 0;
    final color = isPlus ? team.primary : DTokens.danger;

    return DGlassPanel(
      padding: const EdgeInsets.symmetric(horizontal: DTokens.s16, vertical: DTokens.s12),
      radius: DTokens.r16,
      child: Row(
        children: [
          // 아이콘 버블
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Image.asset(
                _entryIcon(entry.title),
                width: 20,
                height: 20,
                color: color,
                colorBlendMode: BlendMode.srcIn,
                errorBuilder: (e, s, t) =>
                    Icon(_entryFallback(entry.title), size: 20, color: color),
              ),
            ),
          ),
          const SizedBox(width: DTokens.s12),

          // 제목 + 시간
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.title,
                  style: DType.body(14, FontWeight.w600)
                      .copyWith(color: DTokens.textPrimaryDark),
                ),
                const SizedBox(height: 2),
                Text(
                  _timeLabel(entry.time),
                  style: DType.mono(11, color: DTokens.textTertiaryDark),
                ),
              ],
            ),
          ),

          // 금액
          Text(
            '${isPlus ? "+" : ""}${isPlus ? _fmt(entry.amount) : "-${_fmt(entry.amount.abs())}"} P',
            style: DType.mono(16, color: color, weight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

// ── point chip ────────────────────────────────────────────────────────────────

class _PointChip extends StatelessWidget {
  final int point;
  final Color teamColor;
  const _PointChip({required this.point, required this.teamColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: DTokens.s12, vertical: DTokens.s4),
      decoration: BoxDecoration(
        color: teamColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(DTokens.rPill),
        border: Border.all(color: teamColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.diamond_rounded, size: 12, color: teamColor),
          const SizedBox(width: DTokens.s4),
          Text('${_fmt(point)} P', style: DType.mono(12, color: teamColor, weight: FontWeight.w700)),
        ],
      ),
    );
  }
}
