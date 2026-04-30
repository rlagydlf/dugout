import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_theme.dart';
import '../../app/theme/tokens.dart';
import '../../app/theme/typography.dart';
import '../../core/providers/app_providers.dart';
import '../../shared/widgets/d_button.dart';
import '../../shared/widgets/d_effects.dart';
import '../../shared/widgets/d_glass_panel.dart';
import '../../shared/widgets/d_scoreboard.dart';

// ── 퀘스트 상세 화면 ─────────────────────────────────────────────────────

class QuestDetailScreen extends ConsumerWidget {
  final String? questId;
  const QuestDetailScreen({super.key, this.questId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quest = _findQuest(questId);

    return Scaffold(
      backgroundColor: DTokens.bgDark,
      appBar: AppBar(
        title: Text(quest.typeName, style: DType.heading(17)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: DTokens.borderDark),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(DTokens.s16, DTokens.s16, DTokens.s16, DTokens.s32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeroCard(quest: quest)
                .animate().fadeIn(duration: 350.ms).slideY(begin: -0.06),
            const SizedBox(height: DTokens.s16),
            _RewardRow(quest: quest)
                .animate(delay: 80.ms).fadeIn(duration: 300.ms),
            const SizedBox(height: DTokens.s16),
            _HowToCard(quest: quest)
                .animate(delay: 140.ms).fadeIn(duration: 300.ms),
            const SizedBox(height: DTokens.s16),
            if (!quest.completed)
              _ProgressCard(quest: quest)
                  .animate(delay: 200.ms).fadeIn(duration: 300.ms),
            if (!quest.completed) const SizedBox(height: DTokens.s24),
            if (!quest.completed)
              _CtaButton(quest: quest)
                  .animate(delay: 260.ms).fadeIn(duration: 300.ms).slideY(begin: 0.1),
            if (quest.completed) ...[
              const SizedBox(height: DTokens.s8),
              _CompletedBanner()
                  .animate(delay: 200.ms).fadeIn(duration: 400.ms),
            ],
          ],
        ),
      ),
    );
  }

  _QuestDetail _findQuest(String? id) =>
      _allDetails.firstWhere((q) => q.id == id, orElse: () => _allDetails.first);
}

// ── 히어로 카드 (D3DTiltCard + DParticleEffect + DDiamondGridPainter) ─────

class _HeroCard extends StatelessWidget {
  final _QuestDetail quest;
  const _HeroCard({required this.quest});

  @override
  Widget build(BuildContext context) {
    final team = context.team;
    return D3DTiltCard(
      maxTiltDeg: 5,
      child: Container(
        width: double.infinity,
        height: 220,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(DTokens.r20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [team.primary, Color.lerp(team.primary, team.secondary, 0.6)!],
          ),
          boxShadow: [
            BoxShadow(color: team.primary.withValues(alpha: 0.5), blurRadius: 36, offset: const Offset(0, 14)),
          ],
        ),
        child: Stack(
          children: [
            // 다이아몬드 그리드
            Positioned.fill(
              child: CustomPaint(
                painter: DDiamondGridPainter(Colors.white.withValues(alpha: 0.08), step: 36),
              ),
            ),
            // 스캔라인
            Positioned.fill(
              child: CustomPaint(painter: DScanlinePainter(opacity: 0.015)),
            ),
            // 파티클 효과
            Positioned.fill(
              child: DParticleEffect(
                color: Colors.white,
                accentColor: team.accent,
                count: 16,
                active: true,
              ),
            ),
            // 야구 아이콘 PNG (우하단 대형)
            Positioned(
              right: -20,
              bottom: -20,
              child: Image.asset(
                quest.heroIconAsset,
                width: 160, height: 160,
                color: Colors.white.withValues(alpha: 0.13),
                errorBuilder: (e, s, t) => const SizedBox.shrink(),
              ),
            ),
            // 어두운 비네팅
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black.withValues(alpha: 0.15), Colors.transparent, Colors.black.withValues(alpha: 0.45)],
                    stops: const [0, 0.45, 1],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(DTokens.s24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: DTokens.s8, vertical: DTokens.s4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(DTokens.rPill),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                    ),
                    child: Text(quest.typeName, style: DType.label(11, color: Colors.white)),
                  ),
                  const Spacer(),
                  Text(quest.title, style: DType.heading(22, color: Colors.white)),
                  const SizedBox(height: DTokens.s8),
                  Text(
                    quest.subtitle,
                    style: DType.body(15).copyWith(color: Colors.white.withValues(alpha: 0.82), height: 1.45),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 보상 행 (DScoreboard 3개 + DShimmerSweep) ────────────────────────────

class _RewardRow extends StatelessWidget {
  final _QuestDetail quest;
  const _RewardRow({required this.quest});

  @override
  Widget build(BuildContext context) {
    final team = context.team;
    return DShimmerSweep(
      period: const Duration(milliseconds: 3000),
      highlightOpacity: 0.16,
      child: DGlassPanel(
        teamBorder: true,
        padding: const EdgeInsets.symmetric(horizontal: DTokens.s20, vertical: DTokens.s16),
        child: Row(
          children: [
            Expanded(
              child: DScoreboard(
                value: '+${quest.reward}',
                label: 'POINTS',
                accent: team.primary,
                valueSize: 28,
                align: TextAlign.center,
              ),
            ),
            Container(width: 1, height: 40, color: DTokens.borderDark),
            Expanded(
              child: DScoreboard(
                value: '+${quest.contribution}',
                label: '기여도',
                accent: DTokens.danger,
                valueSize: 28,
                align: TextAlign.center,
              ),
            ),
            Container(width: 1, height: 40, color: DTokens.borderDark),
            Expanded(
              child: DScoreboard(
                value: '+${quest.exp}',
                label: 'XP',
                accent: DTokens.warning,
                valueSize: 28,
                align: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 달성 방법 카드 ────────────────────────────────────────────────────────

class _HowToCard extends StatelessWidget {
  final _QuestDetail quest;
  const _HowToCard({required this.quest});

  @override
  Widget build(BuildContext context) {
    final team = context.team;
    return DGlassPanel(
      padding: const EdgeInsets.all(DTokens.s20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset('assets/images/icons/bats.png', width: 18, height: 18,
                  color: DTokens.textSecondaryDark,
                  errorBuilder: (e, s, t) => const Icon(Icons.list_alt_rounded, size: 18, color: DTokens.textSecondaryDark)),
              const SizedBox(width: DTokens.s8),
              Text('달성 조건', style: DType.label(13, color: DTokens.textSecondaryDark)),
            ],
          ),
          const SizedBox(height: DTokens.s12),
          ...quest.conditions.asMap().entries.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: DTokens.s8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 20, height: 20,
                    margin: const EdgeInsets.only(top: 1, right: 10),
                    decoration: BoxDecoration(
                      color: team.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: team.primary.withValues(alpha: 0.4)),
                    ),
                    child: Center(
                      child: Text('${e.key + 1}', style: DType.mono(10, color: team.primary, weight: FontWeight.w700)),
                    ),
                  ),
                  Expanded(child: Text(e.value, style: DType.body(14).copyWith(color: DTokens.textPrimaryDark, height: 1.5))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 진행도 카드 ───────────────────────────────────────────────────────────

class _ProgressCard extends StatelessWidget {
  final _QuestDetail quest;
  const _ProgressCard({required this.quest});

  @override
  Widget build(BuildContext context) {
    final team     = context.team;
    final progress = quest.total == 0 ? 0.0 : quest.progress / quest.total;

    return DGlassPanel(
      teamBorder: true,
      padding: const EdgeInsets.all(DTokens.s20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('진행 현황', style: DType.label(13, color: DTokens.textSecondaryDark)),
              const Spacer(),
              Text('${quest.progress} / ${quest.total}',
                  style: DType.scoreboardDigital(22, color: team.primary)),
            ],
          ),
          const SizedBox(height: DTokens.s12),
          Stack(
            children: [
              Container(height: 10, decoration: BoxDecoration(color: DTokens.borderDark, borderRadius: BorderRadius.circular(DTokens.rPill))),
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [team.primary, team.accent.withValues(alpha: 0.7)]),
                    borderRadius: BorderRadius.circular(DTokens.rPill),
                    boxShadow: [BoxShadow(color: team.primary.withValues(alpha: 0.7), blurRadius: 8)],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: DTokens.s8),
          Text(
            quest.total > 1
                ? '${quest.total - quest.progress}번 더 수행하면 완료!'
                : '아직 시작하지 않았어요',
            style: DType.body(14).copyWith(color: DTokens.textSecondaryDark),
          ),
        ],
      ),
    );
  }
}

// ── CTA 버튼 (파티클 오버레이) ────────────────────────────────────────────

class _CtaButton extends ConsumerStatefulWidget {
  final _QuestDetail quest;
  const _CtaButton({required this.quest});

  @override
  ConsumerState<_CtaButton> createState() => _CtaButtonState();
}

class _CtaButtonState extends ConsumerState<_CtaButton> {
  bool _loading = false;
  bool _showParticles = false;

  Future<void> _submit() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    ref.read(userProvider.notifier).addPoint(widget.quest.reward);
    setState(() { _loading = false; _showParticles = true; });
    _showComplete();
  }

  void _showComplete() {
    final team = context.team;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: DTokens.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DTokens.r20),
          side: BorderSide(color: team.primary.withValues(alpha: 0.3)),
        ),
        title: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: DExplosionParticles(
                color: team.primary,
                accentColor: team.accent,
                count: 22,
              ),
            ),
            Column(
              children: [
                DImpactText(text: '완료!', size: 56, gradient: true)
                    .animate().scale(begin: const Offset(0.5, 0.5), duration: 420.ms, curve: Curves.elasticOut),
                const SizedBox(height: DTokens.s8),
                Text('퀘스트 클리어', style: DType.heading(18, color: DTokens.textPrimaryDark)),
              ],
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.quest.title, textAlign: TextAlign.center,
                style: DType.body(14).copyWith(color: DTokens.textSecondaryDark)),
            const SizedBox(height: DTokens.s16),
            Container(
              padding: const EdgeInsets.all(DTokens.s16),
              decoration: BoxDecoration(
                color: team.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(DTokens.r12),
                border: Border.all(color: team.primary.withValues(alpha: 0.3)),
              ),
              child: Text('+${widget.quest.reward} P 적립 완료',
                  style: DType.scoreboardDigital(24, color: team.primary)),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pop();
              },
              child: Text('확인', style: DType.label(15)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        if (_showParticles)
          Positioned.fill(
            child: IgnorePointer(
              child: DExplosionParticles(
                color: context.team.primary,
                accentColor: context.team.accent,
                count: 18,
              ),
            ),
          ),
        DButton(
          label: widget.quest.total > 1 ? '진행 상황 업데이트' : '수행 인증',
          onPressed: _loading ? null : _submit,
          loading: _loading,
          icon: Icons.check_rounded,
        ),
      ],
    );
  }
}

// ── 완료 배너 ─────────────────────────────────────────────────────────────

class _CompletedBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DGlassPanel(
      padding: const EdgeInsets.all(DTokens.s20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_rounded, color: DTokens.success, size: 24),
          const SizedBox(width: DTokens.s12),
          Text('이미 완료한 퀘스트입니다', style: DType.body(15, FontWeight.w700).copyWith(color: DTokens.success)),
        ],
      ),
    );
  }
}

// ── 데이터 모델 ───────────────────────────────────────────────────────────

class _QuestDetail {
  final String id;
  final String typeName;
  final String heroIconAsset;
  final String title;
  final String subtitle;
  final int reward;
  final int contribution;
  final int exp;
  final List<String> conditions;
  final int progress;
  final int total;
  final bool completed;

  const _QuestDetail({
    required this.id,
    required this.typeName,
    required this.heroIconAsset,
    required this.title,
    required this.subtitle,
    required this.reward,
    required this.contribution,
    required this.exp,
    required this.conditions,
    required this.progress,
    required this.total,
    required this.completed,
  });
}

const _allDetails = [
  _QuestDetail(id: '1', typeName: '일일 퀘스트', heroIconAsset: 'assets/images/icons/baseball.png', title: '오늘의 출석 체크', subtitle: '하루를 야구와 함께 시작하세요.\n출석만으로도 포인트를 드립니다!', reward: 10, contribution: 5, exp: 20, conditions: ['앱을 실행하고 홈 화면으로 이동', '출석 완료 버튼 탭'], progress: 1, total: 1, completed: true),
  _QuestDetail(id: '2', typeName: '경기일 퀘스트', heroIconAsset: 'assets/images/icons/trophy.png', title: '경기 시작 30분 전 입장', subtitle: '경기 시작 30분 전에 앱에서\n출정 버튼을 눌러 전투 태세를 갖추세요!', reward: 30, contribution: 15, exp: 50, conditions: ['오늘 홈팀 경기가 예정된 날만 활성화', '경기 시작 30분 전 ~ 경기 시작 시각 사이에 출정 완료', '홈 화면의 "출정하기" 버튼을 탭'], progress: 0, total: 1, completed: false),
  _QuestDetail(id: '3', typeName: '라이벌전 퀘스트', heroIconAsset: 'assets/images/icons/bolt.png', title: '라이벌전 예측 1회 참여', subtitle: '전통의 라이벌 매치에서\n예측으로 팬심을 증명하세요!', reward: 50, contribution: 25, exp: 80, conditions: ['라이벌 팀과의 경기 당일만 활성화', '예측 탭에서 라이벌전 예측 항목 1개 제출', '포인트 베팅 또는 무료 참여 모두 인정'], progress: 0, total: 1, completed: false),
  _QuestDetail(id: '4', typeName: '일일 퀘스트', heroIconAsset: 'assets/images/icons/baseball.png', title: '예측 3회 참여', subtitle: '오늘 하루 예측 3번!\n적극적인 팬이 팀을 이긴다.', reward: 40, contribution: 20, exp: 60, conditions: ['예측 탭에서 어떤 종류든 예측 3회 제출', '무료 참여도 횟수에 포함', '당일 자정까지 누적 카운트'], progress: 1, total: 3, completed: false),
  _QuestDetail(id: '5', typeName: '시리즈 퀘스트', heroIconAsset: 'assets/images/icons/trophy.png', title: '3연전 출정 완료', subtitle: '같은 팀과의 3연전 기간 동안\n매일 빠짐없이 출정하세요!', reward: 150, contribution: 60, exp: 200, conditions: ['3연전 시작일부터 마지막 날까지 매일 출정', '하루라도 빠지면 초기화', '3일 연속 출정 완료 시 보상 지급'], progress: 1, total: 3, completed: false),
  _QuestDetail(id: '6', typeName: '직관 퀘스트', heroIconAsset: 'assets/images/icons/stadium.png', title: '구장 방문 인증', subtitle: '직접 구장에 방문해서\n현장 응원의 열정을 인증하세요!', reward: 200, contribution: 80, exp: 300, conditions: ['경기 당일 구장 반경 500m 이내에서 인증', '앱의 "직관 인증" 버튼을 통해 GPS 확인', '1일 1회 인증 가능'], progress: 0, total: 1, completed: false),
  _QuestDetail(id: '7', typeName: '일일 퀘스트', heroIconAsset: 'assets/images/icons/baseball.png', title: '퀴즈 1문제 풀기', subtitle: '야구 지식을 뽐내세요!\n퀴즈 하나로 팬 레벨을 높이세요.', reward: 20, contribution: 10, exp: 30, conditions: ['퀴즈 탭에서 문제 1개 이상 정답 처리', '오답이어도 참여 횟수에 포함 안 됨'], progress: 0, total: 1, completed: false),
  _QuestDetail(id: '8', typeName: '경기일 퀘스트', heroIconAsset: 'assets/images/icons/scoreboard.png', title: '경기 결과 예측 적중', subtitle: '오늘 경기 결과를 정확히 예측하면\n특별 보너스 포인트가 지급됩니다.', reward: 100, contribution: 40, exp: 120, conditions: ['오늘 예측 탭에서 승리팀 예측 제출', '경기 종료 후 자동 정산', '정답 적중 시 배당 포인트 + 퀘스트 보상 중복 지급'], progress: 0, total: 1, completed: false),
  _QuestDetail(id: '9', typeName: '라이벌전 퀘스트', heroIconAsset: 'assets/images/icons/megaphone.png', title: '라이벌전 응원 댓글 3개', subtitle: '라이벌전에서 댓글로\n팬심을 마음껏 표현하세요!', reward: 60, contribution: 30, exp: 90, conditions: ['라이벌 팀과의 경기 당일 활성화', '경기 관련 게시물에 응원 댓글 3개 이상 작성', '최소 10자 이상 댓글만 인정'], progress: 1, total: 3, completed: false),
  _QuestDetail(id: '10', typeName: '시리즈 퀘스트', heroIconAsset: 'assets/images/icons/trophy.png', title: '시리즈 MVP 예측', subtitle: '3연전이 끝나기 전에\nMVP를 먼저 예측하세요!', reward: 300, contribution: 100, exp: 400, conditions: ['3연전 시작 전날 또는 1차전 당일에만 제출 가능', '예측 탭 > 시리즈 특별 예측 항목에서 제출', '3연전 마지막 날 자동 정산'], progress: 0, total: 1, completed: false),
];
