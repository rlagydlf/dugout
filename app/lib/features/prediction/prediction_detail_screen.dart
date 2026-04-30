import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_theme.dart';
import '../../app/theme/team_theme.dart';
import '../../app/theme/tokens.dart';
import '../../app/theme/typography.dart';
import '../../core/providers/app_providers.dart';
import '../../shared/widgets/d_button.dart';
import '../../shared/widgets/d_effects.dart';
import '../../shared/widgets/d_glass_panel.dart';
import '../../shared/widgets/d_matchup_card.dart';
import '../../shared/widgets/d_scoreboard.dart';

// ── 로컬 상태 ─────────────────────────────────────────────────────────────

class _PredState {
  final int selectedOption;
  final bool usePoints;
  final int betAmount;

  const _PredState({this.selectedOption = -1, this.usePoints = false, this.betAmount = 100});

  _PredState copyWith({int? selectedOption, bool? usePoints, int? betAmount}) => _PredState(
    selectedOption: selectedOption ?? this.selectedOption,
    usePoints: usePoints ?? this.usePoints,
    betAmount: betAmount ?? this.betAmount,
  );
}

class _PredNotifier extends StateNotifier<_PredState> {
  _PredNotifier() : super(const _PredState());
  void selectOption(int idx) => state = state.copyWith(selectedOption: idx);
  void togglePoints(bool v)  => state = state.copyWith(usePoints: v);
  void setBet(int amount)    => state = state.copyWith(betAmount: amount);
}

final _predStateProvider = StateNotifierProvider.autoDispose<_PredNotifier, _PredState>(
  (ref) => _PredNotifier(),
);

// ── 화면 ──────────────────────────────────────────────────────────────────

class PredictionDetailScreen extends ConsumerStatefulWidget {
  final String? predictionId;
  const PredictionDetailScreen({super.key, this.predictionId});

  @override
  ConsumerState<PredictionDetailScreen> createState() => _PredictionDetailScreenState();
}

class _PredictionDetailScreenState extends ConsumerState<PredictionDetailScreen> {
  bool _submitting = false;
  bool _showParticles = false;

  _PredDetail get _detail => _findDetail(widget.predictionId);

  Future<void> _submit() async {
    final s = ref.read(_predStateProvider);
    if (s.selectedOption < 0) return;

    setState(() => _submitting = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    setState(() { _submitting = false; _showParticles = true; });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text('예측 제출 완료! 경기 후 정산됩니다.', style: DType.body(14, FontWeight.w600).copyWith(color: Colors.white)),
          ],
        ),
        backgroundColor: context.team.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DTokens.r12)),
        margin: const EdgeInsets.all(DTokens.s16),
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final state  = ref.watch(_predStateProvider);
    final user   = ref.watch(userProvider);
    final detail = _detail;
    final canSubmit = state.selectedOption >= 0 && (!state.usePoints || user.point >= state.betAmount);
    final home   = TeamThemes.byId(detail.homeTeamId);
    final away   = TeamThemes.byId(detail.awayTeamId);

    return Scaffold(
      backgroundColor: DTokens.bgDark,
      appBar: AppBar(
        title: Text(detail.categoryName, style: DType.heading(17)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: DTokens.borderDark),
        ),
      ),
      body: Stack(
        children: [
          if (_showParticles)
            Positioned.fill(
              child: IgnorePointer(
                child: DExplosionParticles(
                  color: context.team.primary,
                  accentColor: context.team.accent,
                  count: 20,
                ),
              ),
            ),
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(DTokens.s16, DTokens.s16, DTokens.s16, DTokens.s96),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // DMatchupCard 히어로
                DMatchupCard(
                  game: MatchupGameInfo(
                    home: home,
                    away: away,
                    status: GameStatus.preGame,
                    time: detail.time,
                    seriesLabel: detail.categoryName,
                    stadium: detail.stadium,
                  ),
                  height: 210,
                ).animate().fadeIn(duration: 350.ms).slideY(begin: -0.06),

                const SizedBox(height: DTokens.s24),

                Text('예측 선택', style: DType.label(13, color: DTokens.textSecondaryDark, letterSpacing: 1.5)),
                const SizedBox(height: DTokens.s8),
                ...detail.options.asMap().entries.map((entry) {
                  final i   = entry.key;
                  final opt = entry.value;
                  final isSelected = state.selectedOption == i;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: DTokens.s8),
                    child: D3DTiltCard(
                      onTap: () => ref.read(_predStateProvider.notifier).selectOption(i),
                      child: _OptionCard(
                        option: opt,
                        isSelected: isSelected,
                        homeTeam: home,
                        awayTeam: away,
                        optionIndex: i,
                      ),
                    )
                        .animate(delay: Duration(milliseconds: 80 + 60 * i))
                        .fadeIn(duration: 260.ms)
                        .slideX(begin: 0.04),
                  );
                }),

                const SizedBox(height: DTokens.s20),

                Text('참여 방식', style: DType.label(13, color: DTokens.textSecondaryDark, letterSpacing: 1.5)),
                const SizedBox(height: DTokens.s8),
                _ParticipationToggle(
                  usePoints: state.usePoints,
                  onToggle: (v) => ref.read(_predStateProvider.notifier).togglePoints(v),
                ).animate(delay: 300.ms).fadeIn(duration: 260.ms),

                if (state.usePoints) ...[
                  const SizedBox(height: DTokens.s16),
                  _BetAmountPicker(
                    amount: state.betAmount,
                    userPoints: user.point,
                    onSelect: (v) => ref.read(_predStateProvider.notifier).setBet(v),
                  ).animate().fadeIn(duration: 200.ms),
                ],

                if (state.selectedOption >= 0) ...[
                  const SizedBox(height: DTokens.s16),
                  _ExpectedReward(
                    option: detail.options[state.selectedOption],
                    usePoints: state.usePoints,
                    betAmount: state.betAmount,
                  ).animate().fadeIn(duration: 200.ms),
                ],

                const SizedBox(height: DTokens.s20),

                _DeadlineChip(detail: detail)
                    .animate(delay: 360.ms).fadeIn(duration: 260.ms),

                const SizedBox(height: DTokens.s32),

                DButton(
                  label: canSubmit ? '예측 제출하기' : '예측 선택 후 제출',
                  onPressed: canSubmit && !_submitting ? _submit : null,
                  loading: _submitting,
                  icon: Icons.send_rounded,
                ).animate(delay: 400.ms).fadeIn(duration: 280.ms).slideY(begin: 0.1),

                const SizedBox(height: DTokens.s16),
                Text(
                  '※ 더그아웃 포인트는 현금 환급이 불가하며, 앱 내 리워드 교환 전용입니다.',
                  style: DType.micro(12, color: DTokens.textTertiaryDark),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── 옵션 카드 ─────────────────────────────────────────────────────────────

class _OptionCard extends StatelessWidget {
  final _PredOption option;
  final bool isSelected;
  final TeamTheme homeTeam;
  final TeamTheme awayTeam;
  final int optionIndex;

  const _OptionCard({
    required this.option,
    required this.isSelected,
    required this.homeTeam,
    required this.awayTeam,
    required this.optionIndex,
  });

  @override
  Widget build(BuildContext context) {
    final team = context.team;
    final accentColor = optionIndex == 0 ? homeTeam.primary
        : optionIndex == 1 ? awayTeam.primary
        : team.accent.withValues(alpha: 0.8);

    return AnimatedContainer(
      duration: 180.ms,
      padding: const EdgeInsets.all(DTokens.s16),
      decoration: BoxDecoration(
        color: isSelected ? accentColor.withValues(alpha: 0.12) : DTokens.surfaceDark,
        borderRadius: BorderRadius.circular(DTokens.r16),
        border: Border.all(
          color: isSelected ? accentColor : DTokens.borderDark,
          width: isSelected ? 1.5 : 1.0,
        ),
        boxShadow: isSelected
            ? [BoxShadow(color: accentColor.withValues(alpha: 0.3), blurRadius: 14, offset: const Offset(0, 4))]
            : null,
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: 180.ms,
            width: 26, height: 26,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? accentColor : Colors.transparent,
              border: Border.all(color: isSelected ? accentColor : accentColor.withValues(alpha: 0.5), width: 2),
              boxShadow: isSelected ? [BoxShadow(color: accentColor.withValues(alpha: 0.5), blurRadius: 8)] : null,
            ),
            child: isSelected ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
          ),
          const SizedBox(width: DTokens.s12),
          if (optionIndex < 2) ...[
            Image.asset(
              optionIndex == 0 ? homeTeam.crestAsset : awayTeam.crestAsset,
              width: 30, height: 30, fit: BoxFit.contain,
              errorBuilder: (e, s, t) => const SizedBox(width: 30),
            ),
            const SizedBox(width: DTokens.s8),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(option.label,
                    style: DType.body(15, FontWeight.w700).copyWith(
                      color: isSelected ? accentColor : DTokens.textPrimaryDark,
                    )),
                if (option.subLabel != null) ...[
                  const SizedBox(height: 2),
                  Text(option.subLabel!, style: DType.caption(12, color: DTokens.textSecondaryDark)),
                ],
              ],
            ),
          ),
          AnimatedContainer(
            duration: 180.ms,
            padding: const EdgeInsets.symmetric(horizontal: DTokens.s8, vertical: DTokens.s4),
            decoration: BoxDecoration(
              color: isSelected ? accentColor : DTokens.surfaceDark2,
              borderRadius: BorderRadius.circular(DTokens.rPill),
              border: Border.all(color: isSelected ? accentColor : DTokens.borderDark),
            ),
            child: Text('×${option.odds.toStringAsFixed(1)}',
                style: DType.scoreboardDigital(16, color: isSelected ? Colors.white : DTokens.textSecondaryDark)),
          ),
        ],
      ),
    );
  }
}

// ── 참여 방식 토글 ────────────────────────────────────────────────────────

class _ParticipationToggle extends StatelessWidget {
  final bool usePoints;
  final ValueChanged<bool> onToggle;

  const _ParticipationToggle({required this.usePoints, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final team = context.team;
    return Row(
      children: [
        Expanded(
          child: _ToggleOption(
            label: '무료 참여',
            iconAsset: 'assets/images/icons/baseball.png',
            description: '포인트 없이 참여',
            isSelected: !usePoints,
            color: DTokens.success,
            onTap: () => onToggle(false),
          ),
        ),
        const SizedBox(width: DTokens.s8),
        Expanded(
          child: _ToggleOption(
            label: '포인트 베팅',
            iconAsset: 'assets/images/icons/trophy.png',
            description: '배당 × 포인트 획득',
            isSelected: usePoints,
            color: team.primary,
            onTap: () => onToggle(true),
          ),
        ),
      ],
    );
  }
}

class _ToggleOption extends StatelessWidget {
  final String label;
  final String iconAsset;
  final String description;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _ToggleOption({
    required this.label, required this.iconAsset, required this.description,
    required this.isSelected, required this.color, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: 200.ms,
        padding: const EdgeInsets.all(DTokens.s12),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : DTokens.surfaceDark,
          borderRadius: BorderRadius.circular(DTokens.r16),
          border: Border.all(color: isSelected ? color : DTokens.borderDark, width: isSelected ? 1.5 : 1.0),
          boxShadow: isSelected ? [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 12)] : null,
        ),
        child: Row(
          children: [
            Image.asset(iconAsset, width: 18, height: 18,
                color: isSelected ? color : DTokens.textSecondaryDark,
                errorBuilder: (e, s, t) => Icon(Icons.sports_baseball_rounded, size: 18,
                    color: isSelected ? color : DTokens.textSecondaryDark)),
            const SizedBox(width: DTokens.s8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: DType.label(12, color: isSelected ? color : DTokens.textPrimaryDark)),
                  Text(description, style: DType.micro(11, color: DTokens.textTertiaryDark)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 베팅 금액 선택 ─────────────────────────────────────────────────────────

class _BetAmountPicker extends StatelessWidget {
  final int amount;
  final int userPoints;
  final ValueChanged<int> onSelect;

  const _BetAmountPicker({required this.amount, required this.userPoints, required this.onSelect});

  static const _quickAmounts = [100, 500, 1000, 3000];

  @override
  Widget build(BuildContext context) {
    final team = context.team;
    return DGlassPanel(
      padding: const EdgeInsets.all(DTokens.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('베팅 포인트', style: DType.label(13, color: DTokens.textSecondaryDark)),
              const Spacer(),
              Text('보유 ${_fmt(userPoints)} P', style: DType.mono(12, color: team.primary)),
            ],
          ),
          const SizedBox(height: DTokens.s12),
          Row(
            children: _quickAmounts.map((v) {
              final isSelected   = amount == v;
              final insufficient = userPoints < v;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: v != _quickAmounts.last ? DTokens.s8 : 0),
                  child: GestureDetector(
                    onTap: insufficient ? null : () => onSelect(v),
                    child: AnimatedContainer(
                      duration: 180.ms,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isSelected ? team.primary : insufficient ? DTokens.surfaceDark : DTokens.surfaceDark2,
                        borderRadius: BorderRadius.circular(DTokens.r12),
                        border: Border.all(color: isSelected ? team.primary : DTokens.borderDark),
                        boxShadow: isSelected ? [BoxShadow(color: team.primary.withValues(alpha: 0.45), blurRadius: 8)] : null,
                      ),
                      child: Center(
                        child: Text('${_fmt(v)}P',
                            style: DType.mono(13,
                                color: isSelected ? Colors.white : insufficient ? DTokens.textTertiaryDark : DTokens.textPrimaryDark)),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _fmt(int v) {
    if (v < 1000) return '$v';
    final s   = v.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

// ── 예상 보상 (DShimmerSweep) ─────────────────────────────────────────────

class _ExpectedReward extends StatelessWidget {
  final _PredOption option;
  final bool usePoints;
  final int betAmount;

  const _ExpectedReward({required this.option, required this.usePoints, required this.betAmount});

  @override
  Widget build(BuildContext context) {
    final team   = context.team;
    final reward = usePoints ? (betAmount * option.odds).toInt() : 50;

    return DShimmerSweep(
      period: const Duration(milliseconds: 2400),
      highlightOpacity: 0.18,
      child: DGlassPanel(
        teamBorder: true,
        padding: const EdgeInsets.all(DTokens.s16),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: team.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(color: team.primary.withValues(alpha: 0.35)),
              ),
              child: Center(
                child: Image.asset('assets/images/icons/trophy.png', width: 22, height: 22, color: team.primary,
                    errorBuilder: (e, s, t) => Icon(Icons.emoji_events_rounded, color: team.primary, size: 22)),
              ),
            ),
            const SizedBox(width: DTokens.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('예측 적중 시 예상 보상', style: DType.caption(13, color: DTokens.textSecondaryDark)),
                  const SizedBox(height: 2),
                  Text(
                    usePoints ? '$betAmount P × ×${option.odds.toStringAsFixed(1)} = $reward P' : '무료 참여 보상 +50 P',
                    style: DType.body(13, FontWeight.w700).copyWith(color: DTokens.textPrimaryDark),
                  ),
                ],
              ),
            ),
            DScoreboard(value: '+$reward', label: 'P', accent: team.primary, valueSize: 26),
          ],
        ),
      ),
    );
  }
}

// ── 마감 카운트다운 칩 ────────────────────────────────────────────────────

class _DeadlineChip extends StatelessWidget {
  final _PredDetail detail;
  const _DeadlineChip({required this.detail});

  @override
  Widget build(BuildContext context) {
    final isUrgent = detail.minutesLeft <= 30;
    final color    = isUrgent ? DTokens.danger : DTokens.textSecondaryDark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.timer_outlined, size: 16, color: color),
        const SizedBox(width: DTokens.s4),
        Text(detail.deadline, style: DType.mono(13, color: color)),
        if (isUrgent) ...[
          const SizedBox(width: DTokens.s8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: DTokens.danger.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(DTokens.rPill),
              border: Border.all(color: DTokens.danger.withValues(alpha: 0.3)),
            ),
            child: Text('마감 임박', style: DType.label(11, color: DTokens.danger)),
          ).animate(onPlay: (c) => c.repeat(reverse: true)).fade(begin: 0.6, end: 1.0, duration: 600.ms),
        ],
      ],
    );
  }
}

// ── 데이터 모델 ───────────────────────────────────────────────────────────

class _PredOption {
  final String label;
  final String? subLabel;
  final double odds;
  const _PredOption({required this.label, this.subLabel, required this.odds});
}

class _PredDetail {
  final String id;
  final String categoryName;
  final String title;
  final String homeTeamId;
  final String awayTeamId;
  final String time;
  final String stadium;
  final String deadline;
  final int minutesLeft;
  final List<_PredOption> options;

  const _PredDetail({
    required this.id, required this.categoryName, required this.title,
    required this.homeTeamId, required this.awayTeamId,
    required this.time, required this.stadium,
    required this.deadline, required this.minutesLeft, required this.options,
  });
}

const _allPredDetails = [
  _PredDetail(id: '1', categoryName: '승리팀 예측', title: '오늘의 승리팀 예측', homeTeamId: 'lg', awayTeamId: 'doosan', time: '18:30', stadium: '잠실야구장', deadline: '18:00 마감 (47분 남음)', minutesLeft: 47, options: [_PredOption(label: 'LG 승', subLabel: 'LG 트윈스 승리', odds: 2.0), _PredOption(label: '두산 승', subLabel: '두산 베어스 승리', odds: 2.0), _PredOption(label: '무승부', subLabel: '연장 포함 동점', odds: 7.0)]),
  _PredDetail(id: '2', categoryName: '키플레이어 예측', title: '오늘 활약할 키플레이어', homeTeamId: 'ssg', awayTeamId: 'kia', time: '18:30', stadium: '인천SSG랜더스필드', deadline: '18:30 마감 (77분 남음)', minutesLeft: 77, options: [_PredOption(label: '최정', subLabel: 'SSG 3루수', odds: 3.5), _PredOption(label: '나성범', subLabel: 'KIA 외야수', odds: 4.0), _PredOption(label: '채은성', subLabel: 'SSG 1루수', odds: 4.5), _PredOption(label: '기타', subLabel: '위 선수 외', odds: 5.0)]),
  _PredDetail(id: '3', categoryName: '장타 예측', title: '오늘 홈런/장타 선수 예측', homeTeamId: 'hanwha', awayTeamId: 'samsung', time: '18:30', stadium: '대전한화생명이글스파크', deadline: '경기 시작까지 (120분 남음)', minutesLeft: 120, options: [_PredOption(label: '노시환', subLabel: '한화 3루수', odds: 4.5), _PredOption(label: '피렐라', subLabel: '삼성 외야수', odds: 5.0), _PredOption(label: '기타 한화', subLabel: '한화 타자 중', odds: 6.0), _PredOption(label: '기타 삼성', subLabel: '삼성 타자 중', odds: 6.5), _PredOption(label: '홈런 없음', subLabel: '양팀 모두 홈런 없음', odds: 3.0)]),
  _PredDetail(id: '4', categoryName: '라이벌전 특별 예측', title: '라이벌전 최다 득점 이닝', homeTeamId: 'lg', awayTeamId: 'doosan', time: '18:30', stadium: '잠실야구장', deadline: '19:00 마감 (107분 남음)', minutesLeft: 107, options: [_PredOption(label: '1~3이닝', subLabel: '초반 집중 득점', odds: 3.0), _PredOption(label: '4~6이닝', subLabel: '중반 득점 집중', odds: 3.5), _PredOption(label: '7~9이닝', subLabel: '후반 역전 드라마', odds: 4.0)]),
  _PredDetail(id: '5', categoryName: '승리팀 예측', title: '키움 vs NC 승리팀', homeTeamId: 'kiwoom', awayTeamId: 'nc', time: '17:30', stadium: '고척스카이돔', deadline: '17:30 마감 (17분 남음)', minutesLeft: 17, options: [_PredOption(label: '키움 승', subLabel: '키움 히어로즈 승리', odds: 2.0), _PredOption(label: 'NC 승', subLabel: 'NC 다이노스 승리', odds: 2.0), _PredOption(label: '무승부', subLabel: '동점', odds: 7.0)]),
  _PredDetail(id: '6', categoryName: '라이벌전 특별 예측', title: '잠실 더비 선취점 팀', homeTeamId: 'lg', awayTeamId: 'doosan', time: '18:30', stadium: '잠실야구장', deadline: '18:00 마감 (47분 남음)', minutesLeft: 47, options: [_PredOption(label: 'LG 선취점', subLabel: 'LG가 먼저 득점', odds: 1.8), _PredOption(label: '두산 선취점', subLabel: '두산이 먼저 득점', odds: 1.8)]),
];

_PredDetail _findDetail(String? id) =>
    _allPredDetails.firstWhere((d) => d.id == id, orElse: () => _allPredDetails.first);
