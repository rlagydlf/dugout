import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/tokens.dart';
import '../../app/theme/typography.dart';
import '../../shared/widgets/d_button.dart';
import '../../shared/widgets/d_effects.dart';
import '../../shared/widgets/d_glass_panel.dart';

class BannedScreen extends ConsumerWidget {
  final String? reason;
  final String? bannedUntil;
  const BannedScreen({super.key, this.reason, this.bannedUntil});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayReason = reason ?? '서비스 이용약관 위반 (어뷰징 감지)';
    final displayUntil = bannedUntil ?? '2026-05-14';

    return Scaffold(
      backgroundColor: DTokens.bgDark,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── 배경 danger glow
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.4),
                radius: 1.2,
                colors: [
                  DTokens.danger.withValues(alpha: 0.14),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // ── diamond grid
          Positioned.fill(
            child: CustomPaint(
              painter: DDiamondGridPainter(
                DTokens.danger.withValues(alpha: 0.03),
                step: 44,
              ),
            ),
          ),

          // ── scanline
          Positioned.fill(
            child: CustomPaint(painter: DScanlinePainter()),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: DTokens.s20),
              child: Column(
                children: [
                  const SizedBox(height: DTokens.s32),

                  // ── 아이콘 (gavel + pulse glow)
                  _BannedIcon()
                      .animate()
                      .scale(
                        begin: const Offset(0.5, 0.5),
                        duration: 800.ms,
                        curve: Curves.easeOutBack,
                      )
                      .fadeIn(),

                  const SizedBox(height: DTokens.s24),

                  // ── 제목
                  Text(
                    '이용이 제한된 계정입니다',
                    style: DType.heading(22, color: Colors.white),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.08),

                  const SizedBox(height: DTokens.s8),

                  Text(
                    '아래 사유로 서비스 이용이 일시 제한되었습니다.',
                    style: DType.body(14).copyWith(
                      color: DTokens.textSecondaryDark,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 280.ms),

                  const SizedBox(height: DTokens.s28),

                  // ── 제재 상세 카드
                  DGlassPanel(
                    padding: const EdgeInsets.all(DTokens.s20),
                    radius: DTokens.r20,
                    child: Column(
                      children: [
                        _InfoRow(
                          icon: Icons.report_rounded,
                          label: '제재 사유',
                          value: displayReason,
                          valueColor: DTokens.danger,
                        ),
                        Divider(
                          color: DTokens.borderDark,
                          height: DTokens.s24,
                        ),
                        _InfoRow(
                          icon: Icons.event_busy_rounded,
                          label: '제재 기간',
                          value: '$displayUntil 까지',
                          valueColor: DTokens.warning,
                        ),
                        Divider(
                          color: DTokens.borderDark,
                          height: DTokens.s24,
                        ),
                        _InfoRow(
                          icon: Icons.hourglass_top_rounded,
                          label: '처리 상태',
                          value: '검토 중',
                          valueColor: DTokens.textSecondaryDark,
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 340.ms).slideY(begin: 0.06),

                  const SizedBox(height: DTokens.s16),

                  // ── 이의신청 안내
                  Container(
                    padding: const EdgeInsets.all(DTokens.s16),
                    decoration: BoxDecoration(
                      color: DTokens.surfaceDark2,
                      borderRadius: BorderRadius.circular(DTokens.r16),
                      border: Border.all(color: DTokens.borderDark),
                    ),
                    child: Text(
                      '제재 조치에 이의가 있으시면 아래 이의신청 버튼을 눌러 주세요. '
                      '접수 후 영업일 기준 3일 이내 검토 결과를 알려드립니다.',
                      style: DType.caption(12,
                              color: DTokens.textSecondaryDark)
                          .copyWith(height: 1.7),
                      textAlign: TextAlign.center,
                    ),
                  ).animate().fadeIn(delay: 400.ms),

                  const Spacer(),

                  // ── 버튼
                  DButton(
                    label: '이의신청 하기',
                    icon: Icons.send_rounded,
                    onPressed: () {
                      showDialog<void>(
                        context: context,
                        builder: (_) => _AppealDialog(),
                      );
                    },
                  ).animate().fadeIn(delay: 460.ms),

                  const SizedBox(height: DTokens.s12),

                  DButton(
                    label: '로그아웃',
                    variant: DButtonVariant.outline,
                    icon: Icons.logout_rounded,
                    onPressed: () => context.go('/auth'),
                  ).animate().fadeIn(delay: 510.ms),

                  SizedBox(
                      height: MediaQuery.of(context).padding.bottom +
                          DTokens.s16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Banned icon ───────────────────────────────────────────────────────────────

class _BannedIcon extends StatefulWidget {
  @override
  State<_BannedIcon> createState() => _BannedIconState();
}

class _BannedIconState extends State<_BannedIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: DTokens.danger.withValues(
                        alpha: 0.12 + _pulse.value * 0.16),
                    blurRadius: 50 + _pulse.value * 28,
                    spreadRadius: _pulse.value * 6,
                  ),
                ],
              ),
            ),
            Container(
              width: 108,
              height: 108,
              decoration: BoxDecoration(
                color: DTokens.danger.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: DTokens.danger
                      .withValues(alpha: 0.28 + _pulse.value * 0.22),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.gavel_rounded,
                size: 50,
                color: DTokens.danger,
              ),
            ),
          ],
        );
      },
    );
  }
}

// ── Info row ──────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  const _InfoRow(
      {required this.icon,
      required this.label,
      required this.value,
      this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon,
            size: 18,
            color:
                valueColor?.withValues(alpha: 0.7) ?? DTokens.textSecondaryDark),
        const SizedBox(width: DTokens.s12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: DType.caption(11,
                      color: DTokens.textTertiaryDark)),
              const SizedBox(height: 2),
              Text(
                value,
                style: DType.body(14, FontWeight.w700)
                    .copyWith(color: valueColor ?? DTokens.textPrimaryDark),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Appeal dialog ─────────────────────────────────────────────────────────────

class _AppealDialog extends StatelessWidget {
  final _ctrl = TextEditingController();

  _AppealDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: DTokens.surfaceDark,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DTokens.r20)),
      title: Text('이의신청',
          style: DType.body(17, FontWeight.w800)
              .copyWith(color: Colors.white)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '제재 사유에 대한 의견을 작성해 주세요.',
            style: DType.caption(13, color: DTokens.textSecondaryDark),
          ),
          const SizedBox(height: DTokens.s12),
          TextField(
            controller: _ctrl,
            minLines: 3,
            maxLines: 5,
            style: DType.body(14).copyWith(color: Colors.white),
            decoration: InputDecoration(
              hintText: '이의신청 내용을 입력하세요',
              hintStyle: DType.body(14).copyWith(
                  color: Colors.white.withValues(alpha: 0.3)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DTokens.r12),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('취소',
              style: DType.body(14)
                  .copyWith(color: DTokens.textSecondaryDark)),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('이의신청이 접수되었습니다.',
                    style:
                        DType.body(14).copyWith(color: Colors.white)),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          child: Text('제출',
              style: DType.body(14, FontWeight.w700)
                  .copyWith(color: Colors.white)),
        ),
      ],
    );
  }
}
