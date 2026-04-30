import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_theme.dart';
import '../../app/theme/tokens.dart';
import '../../app/theme/typography.dart';
import '../../core/providers/app_providers.dart';
import '../../shared/widgets/d_button.dart';
import '../../shared/widgets/d_glass_panel.dart';
import '../../shared/widgets/d_scoreboard.dart';

// ── 퀴즈 상세 데이터 모델 ─────────────────────────────────────────────────

enum _QuizCat { history, rules, players }

class _QuizDetailData {
  final String id;
  final _QuizCat category;
  final String categoryName;
  final String question;
  final List<String> options;
  final int answerIndex;
  final String explanation;
  final int reward;
  final int timeLimitSecs;

  const _QuizDetailData({
    required this.id, required this.category, required this.categoryName,
    required this.question, required this.options, required this.answerIndex,
    required this.explanation, required this.reward, required this.timeLimitSecs,
  });
}

const _allQuizDetails = [
  _QuizDetailData(id: 'q1', category: _QuizCat.history, categoryName: '역사', question: 'KBO 리그가 처음 출범한 연도는?', options: ['1980년', '1982년', '1985년', '1990년'], answerIndex: 1, explanation: 'KBO 리그(한국프로야구)는 1982년 6개 구단으로 출범하였습니다. 첫 우승팀은 OB 베어스(현 두산 베어스)입니다.', reward: 20, timeLimitSecs: 30),
  _QuizDetailData(id: 'q2', category: _QuizCat.players, categoryName: '선수', question: 'KBO 리그 통산 최다 홈런 기록을 보유한 선수는?', options: ['이승엽', '박병호', '최정', '장종훈'], answerIndex: 2, explanation: '최정(SSG 랜더스)은 KBO 리그 통산 최다 홈런 기록 보유자입니다. 이승엽의 기존 기록을 2023년에 경신했습니다.', reward: 40, timeLimitSecs: 45),
  _QuizDetailData(id: 'q3', category: _QuizCat.rules, categoryName: '규칙', question: '타자가 삼진 아웃되는 경우 몇 스트라이크인가?', options: ['2스트라이크', '3스트라이크', '4스트라이크', '5스트라이크'], answerIndex: 1, explanation: '야구에서 타자는 3스트라이크를 당하면 삼진 아웃이 됩니다. 단, 3스트라이크 시 포수가 공을 놓치면 타자는 1루로 뛸 수 있습니다.', reward: 15, timeLimitSecs: 20),
  _QuizDetailData(id: 'q4', category: _QuizCat.history, categoryName: '역사', question: '잠실구장에서 최초로 노히트노런을 달성한 투수는?', options: ['선동열', '최동원', '박동희', '장명부'], answerIndex: 0, explanation: '선동열(전 해태 타이거즈)은 잠실야구장에서 역사적인 노히트노런을 달성한 KBO 역사의 레전드 투수입니다.', reward: 80, timeLimitSecs: 60),
  _QuizDetailData(id: 'q5', category: _QuizCat.rules, categoryName: '규칙', question: '인필드 플라이 룰이 적용되는 조건은?', options: ['주자 1루, 아웃카운트 무관', '주자 1·2루 또는 만루, 아웃 2개 미만', '주자 만루, 아웃카운트 무관', '주자 없이 타자가 내야 뜬공'], answerIndex: 1, explanation: '인필드 플라이는 무사 또는 1사에 1·2루 또는 만루 상황에서 내야수가 쉽게 잡을 수 있는 페어 플라이볼에 심판이 선언합니다.', reward: 35, timeLimitSecs: 45),
];

_QuizDetailData _findQuiz(String? id) =>
    _allQuizDetails.firstWhere((q) => q.id == id, orElse: () => _allQuizDetails.first);

// ── 화면 상태 ─────────────────────────────────────────────────────────────

enum _QuizPhase { answering, correct, wrong }

// ── 화면 ──────────────────────────────────────────────────────────────────

class QuizDetailScreen extends ConsumerStatefulWidget {
  final String? quizId;
  const QuizDetailScreen({super.key, this.quizId});

  @override
  ConsumerState<QuizDetailScreen> createState() => _QuizDetailScreenState();
}

class _QuizDetailScreenState extends ConsumerState<QuizDetailScreen> {
  int _selected = -1;
  _QuizPhase _phase = _QuizPhase.answering;
  bool _submitting = false;

  _QuizDetailData get _quiz => _findQuiz(widget.quizId);

  Future<void> _submit() async {
    if (_selected < 0) return;
    setState(() => _submitting = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    final isCorrect = _selected == _quiz.answerIndex;
    if (isCorrect) ref.read(userProvider.notifier).addPoint(_quiz.reward);

    setState(() {
      _phase = isCorrect ? _QuizPhase.correct : _QuizPhase.wrong;
      _submitting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final quiz = _quiz;
    return Scaffold(
      backgroundColor: DTokens.bgDark,
      appBar: AppBar(
        title: Text('${quiz.categoryName} 퀴즈', style: DType.heading(17)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: DTokens.borderDark),
        ),
      ),
      body: _phase == _QuizPhase.answering
          ? _buildAnswering(quiz)
          : _buildResult(quiz),
    );
  }

  // ── 답변 화면 ────────────────────────────────────────────────────────────

  Widget _buildAnswering(_QuizDetailData quiz) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(DTokens.s16, DTokens.s16, DTokens.s16, DTokens.s32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _QuestionCard(quiz: quiz)
              .animate().fadeIn(duration: 350.ms).slideY(begin: -0.06),
          const SizedBox(height: DTokens.s20),
          Padding(
            padding: const EdgeInsets.only(bottom: DTokens.s8),
            child: Text('정답을 선택하세요', style: DType.label(13, color: DTokens.textSecondaryDark)),
          ),
          ...quiz.options.asMap().entries.map((entry) {
            final i   = entry.key;
            final opt = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: DTokens.s8),
              child: _AnswerOption(
                index: i, label: opt, isSelected: _selected == i,
                phase: _QuizPhase.answering, correctIndex: quiz.answerIndex,
                onTap: () => setState(() => _selected = i),
              )
                  .animate(delay: Duration(milliseconds: 80 + 60 * i))
                  .fadeIn(duration: 260.ms)
                  .slideX(begin: 0.04),
            );
          }),
          const SizedBox(height: DTokens.s24),
          DButton(
            label: _selected >= 0 ? '정답 제출' : '보기를 선택해주세요',
            onPressed: _selected >= 0 && !_submitting ? _submit : null,
            loading: _submitting,
            icon: Icons.check_rounded,
          ).animate(delay: 380.ms).fadeIn(duration: 260.ms).slideY(begin: 0.1),
        ],
      ),
    );
  }

  // ── 결과 화면 ────────────────────────────────────────────────────────────

  Widget _buildResult(_QuizDetailData quiz) {
    final isCorrect = _phase == _QuizPhase.correct;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(DTokens.s16, DTokens.s24, DTokens.s16, DTokens.s32),
      child: Column(
        children: [
          _ResultBanner(isCorrect: isCorrect, reward: quiz.reward)
              .animate()
              .scale(begin: const Offset(0.85, 0.85), duration: 350.ms, curve: Curves.elasticOut)
              .fadeIn(duration: 250.ms),
          const SizedBox(height: DTokens.s20),
          _ExplanationCard(quiz: quiz, selectedIndex: _selected, isCorrect: isCorrect)
              .animate(delay: 200.ms).fadeIn(duration: 280.ms),
          const SizedBox(height: DTokens.s20),
          ...quiz.options.asMap().entries.map((entry) {
            final i   = entry.key;
            final opt = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: DTokens.s8),
              child: _AnswerOption(
                index: i, label: opt, isSelected: _selected == i,
                phase: _phase, correctIndex: quiz.answerIndex, onTap: null,
              ).animate(delay: Duration(milliseconds: 250 + 50 * i)).fadeIn(duration: 220.ms),
            );
          }),
          const SizedBox(height: DTokens.s24),
          DButton(
            label: '목록으로 돌아가기',
            onPressed: () => Navigator.of(context).pop(),
            icon: Icons.arrow_back_rounded,
          ).animate(delay: 500.ms).fadeIn(duration: 260.ms),
          if (!isCorrect) ...[
            const SizedBox(height: DTokens.s12),
            DButton(
              label: '다시 풀기',
              onPressed: () => setState(() { _selected = -1; _phase = _QuizPhase.answering; }),
              variant: DButtonVariant.outline,
              icon: Icons.refresh_rounded,
            ).animate(delay: 560.ms).fadeIn(duration: 260.ms),
          ],
        ],
      ),
    );
  }
}

// ── 문제 카드 ─────────────────────────────────────────────────────────────

class _QuestionCard extends StatelessWidget {
  final _QuizDetailData quiz;
  const _QuestionCard({required this.quiz});

  static const _catIconAssets = {
    _QuizCat.history: 'assets/images/icons/trophy.png',
    _QuizCat.rules:   'assets/images/icons/plate.png',
    _QuizCat.players: 'assets/images/icons/helmet.png',
  };

  @override
  Widget build(BuildContext context) {
    final team = context.team;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DTokens.s24),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(DTokens.r20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [team.primary.withValues(alpha: 0.25), team.secondary.withValues(alpha: 0.15)],
        ),
        border: Border.all(color: team.primary.withValues(alpha: 0.3)),
      ),
      child: Stack(
        children: [
          // 배경 야구 PNG 아이콘
          Positioned(
            right: -16, bottom: -16,
            child: Image.asset(
              _catIconAssets[quiz.category]!,
              width: 110, height: 110,
              color: team.primary.withValues(alpha: 0.12),
              errorBuilder: (e, s, t) => const SizedBox.shrink(),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: DTokens.s8, vertical: DTokens.s4),
                    decoration: BoxDecoration(
                      color: team.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(DTokens.rPill),
                      border: Border.all(color: team.primary.withValues(alpha: 0.35)),
                    ),
                    child: Text(quiz.categoryName, style: DType.label(11, color: team.primary)),
                  ),
                  const Spacer(),
                  Image.asset('assets/images/icons/scoreboard.png', width: 14, height: 14,
                      color: DTokens.textSecondaryDark,
                      errorBuilder: (e, s, t) => const Icon(Icons.timer_outlined, size: 14, color: DTokens.textSecondaryDark)),
                  const SizedBox(width: 4),
                  Text('${quiz.timeLimitSecs}초', style: DType.mono(13, color: DTokens.textSecondaryDark)),
                ],
              ),
              const SizedBox(height: DTokens.s16),
              Text('Q.', style: DType.impact(28, color: team.primary)),
              const SizedBox(height: DTokens.s8),
              Text(quiz.question, style: DType.heading(18, color: DTokens.textPrimaryDark)),
              const SizedBox(height: DTokens.s16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: DTokens.s8, vertical: DTokens.s4),
                decoration: BoxDecoration(
                  color: DTokens.warning.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(DTokens.rPill),
                ),
                child: Text('정답 시 +${quiz.reward} P 지급', style: DType.mono(12, color: DTokens.warning)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── 답변 옵션 ─────────────────────────────────────────────────────────────

class _AnswerOption extends StatelessWidget {
  final int index;
  final String label;
  final bool isSelected;
  final _QuizPhase phase;
  final int correctIndex;
  final VoidCallback? onTap;

  const _AnswerOption({
    required this.index, required this.label, required this.isSelected,
    required this.phase, required this.correctIndex, required this.onTap,
  });

  static const _numbers = ['①', '②', '③', '④'];

  @override
  Widget build(BuildContext context) {
    final team        = context.team;
    final isAnswering = phase == _QuizPhase.answering;

    Color borderColor;
    Color textColor;
    Widget? trailingIcon;

    if (isAnswering) {
      if (isSelected) {
        borderColor = team.primary;
        textColor   = team.primary;
      } else {
        borderColor = DTokens.borderDark;
        textColor   = DTokens.textPrimaryDark;
      }
    } else {
      final isCorrect      = index == correctIndex;
      final isWrongSelected = isSelected && !isCorrect;
      if (isCorrect) {
        borderColor  = DTokens.success;
        textColor    = DTokens.success;
        trailingIcon = const Icon(Icons.check_circle_rounded, color: DTokens.success, size: 20);
      } else if (isWrongSelected) {
        borderColor  = DTokens.danger;
        textColor    = DTokens.danger;
        trailingIcon = const Icon(Icons.cancel_rounded, color: DTokens.danger, size: 20);
      } else {
        borderColor = DTokens.borderDark;
        textColor   = DTokens.textTertiaryDark;
      }
    }

    return DGlassPanel(
      onTap: onTap,
      padding: const EdgeInsets.all(DTokens.s16),
      child: Row(
        children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(color: borderColor.withValues(alpha: 0.18), shape: BoxShape.circle,
                border: isSelected && isAnswering ? Border.all(color: borderColor, width: 2) : null),
            child: Center(child: Text(_numbers[index], style: DType.badge(14, color: textColor))),
          ),
          const SizedBox(width: DTokens.s12),
          Expanded(child: Text(label, style: DType.body(15, FontWeight.w600).copyWith(color: textColor, height: 1.4))),
          if (trailingIcon != null) ...[
            const SizedBox(width: DTokens.s8),
            trailingIcon,
          ],
        ],
      ),
    );
  }
}

// ── 결과 배너 ─────────────────────────────────────────────────────────────

class _ResultBanner extends StatelessWidget {
  final bool isCorrect;
  final int reward;
  const _ResultBanner({required this.isCorrect, required this.reward});

  @override
  Widget build(BuildContext context) {
    final team  = context.team;
    final color = isCorrect ? DTokens.success : DTokens.danger;

    return DGlassPanel(
      padding: const EdgeInsets.all(DTokens.s24),
      child: Column(
        children: [
          // 큰 DImpactText 결과 표시
          DImpactText(
            text: isCorrect ? '정답!' : '오답',
            size: 64,
            color: color,
            gradient: isCorrect,
          ).animate().scale(begin: const Offset(0.6, 0.6), duration: 450.ms, curve: Curves.elasticOut),
          const SizedBox(height: DTokens.s16),
          if (isCorrect) ...[
            DScoreboard(value: '+$reward', label: 'POINTS EARNED', accent: team.primary, valueSize: 36, align: TextAlign.center),
          ] else ...[
            Text('다시 도전해보세요!', style: DType.body(14).copyWith(color: DTokens.textSecondaryDark)),
          ],
        ],
      ),
    );
  }
}

// ── 해설 카드 ─────────────────────────────────────────────────────────────

class _ExplanationCard extends StatelessWidget {
  final _QuizDetailData quiz;
  final int selectedIndex;
  final bool isCorrect;

  const _ExplanationCard({required this.quiz, required this.selectedIndex, required this.isCorrect});

  @override
  Widget build(BuildContext context) {
    return DGlassPanel(
      padding: const EdgeInsets.all(DTokens.s20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset('assets/images/icons/baseball.png', width: 18, height: 18, color: DTokens.warning,
                  errorBuilder: (e, s, t) => const Icon(Icons.lightbulb_rounded, size: 18, color: DTokens.warning)),
              const SizedBox(width: DTokens.s8),
              Text('정답 해설', style: DType.label(13, color: DTokens.textSecondaryDark)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: DTokens.s8, vertical: DTokens.s4),
                decoration: BoxDecoration(
                  color: DTokens.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(DTokens.rPill),
                ),
                child: Text('정답: ${quiz.options[quiz.answerIndex]}', style: DType.label(11, color: DTokens.success)),
              ),
            ],
          ),
          const SizedBox(height: DTokens.s12),
          Text(quiz.explanation, style: DType.body(16).copyWith(color: DTokens.textPrimaryDark, height: 1.6)),
        ],
      ),
    );
  }
}
