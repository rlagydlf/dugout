import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_theme.dart';
import '../../app/theme/tokens.dart';
import '../../app/theme/typography.dart';
import '../../core/providers/app_providers.dart';
import '../../shared/widgets/d_effects.dart';
import '../../shared/widgets/d_glass_panel.dart';
import '../../shared/widgets/d_scoreboard.dart';

// ── icon helpers ──────────────────────────────────────────────────────────────

String _categoryIcon(String cat) {
  switch (cat) {
    case '기프티콘':
      return 'assets/images/icons/trophy.png';
    case '야구용품':
      return 'assets/images/icons/bats.png';
    case '제휴 쿠폰':
      return 'assets/images/icons/scoreboard.png';
    case '디지털 아이템':
      return 'assets/images/icons/bolt.png';
    case '한정':
      return 'assets/images/icons/megaphone.png';
    default:
      return 'assets/images/icons/baseball.png';
  }
}

IconData _categoryFallback(String cat) {
  switch (cat) {
    case '기프티콘':
      return Icons.card_giftcard_rounded;
    case '야구용품':
      return Icons.sports_baseball_rounded;
    case '제휴 쿠폰':
      return Icons.percent_rounded;
    case '한정':
      return Icons.timer_rounded;
    default:
      return Icons.star_rounded;
  }
}

String _fmt(int v) {
  final s = v.abs().toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return buf.toString();
}

// ── model ─────────────────────────────────────────────────────────────────────

class RewardItem {
  final String id;
  final String name;
  final String category;
  final int price;
  final int? stock;
  final String validUntil;
  final String notice;
  const RewardItem({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    this.stock,
    this.validUntil = '2025-12-31',
    this.notice = '본 쿠폰은 발급일로부터 30일 이내 사용 가능합니다. 환불 및 양도 불가.',
  });
}

const _defaultItem = RewardItem(
  id: 'r1',
  name: '스타벅스 아메리카노 T',
  category: '기프티콘',
  price: 4500,
  validUntil: '2025-12-31',
  notice: '본 쿠폰은 발급일로부터 30일 이내에 사용 가능합니다.\n'
      '유효기간 내 미사용 시 자동 소멸되며, 환불 및 타인 양도는 불가합니다.\n'
      '매장 내 실물 교환 전용입니다.',
);

// ── Screen ────────────────────────────────────────────────────────────────────

class RewardDetailScreen extends ConsumerStatefulWidget {
  final RewardItem? item;
  const RewardDetailScreen({super.key, this.item});

  @override
  ConsumerState<RewardDetailScreen> createState() => _RewardDetailScreenState();
}

class _RewardDetailScreenState extends ConsumerState<RewardDetailScreen> {
  bool _loading = false;
  bool _showParticles = false;

  RewardItem get _item => widget.item ?? _defaultItem;

  Future<void> _onExchange() async {
    final user = ref.read(userProvider);
    if (user.point < _item.price) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => _ConfirmDialog(item: _item, userPoint: user.point),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    ref.read(userProvider.notifier).addPoint(-_item.price);
    if (!mounted) return;
    setState(() { _loading = false; _showParticles = true; });

    await showDialog<void>(
      context: context,
      builder: (_) => _CouponDialog(item: _item),
    );
    if (mounted) setState(() => _showParticles = false);
  }

  @override
  Widget build(BuildContext context) {
    final team = context.team;
    final user = ref.watch(userProvider);
    final canBuy = user.point >= _item.price;

    return Scaffold(
      backgroundColor: DTokens.bgDark,
      appBar: AppBar(
        backgroundColor: DTokens.bgDark,
        elevation: 0,
        leading: const BackButton(),
        title: Text(_item.category, style: DType.heading(17, color: Colors.white)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: DTokens.s16),
            child: _PointChip(point: user.point, teamColor: team.primary),
          ),
        ],
      ),
      body: Stack(
        children: [
          // 파티클 오버레이 (교환 완료)
          if (_showParticles)
            Positioned.fill(
              child: IgnorePointer(
                child: DExplosionParticles(
                  color: team.primary,
                  accentColor: team.accent,
                  count: 24,
                ),
              ),
            ),
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── 히어로 영역 (D3DTiltCard + DShimmerSweep)
                      _HeroPanel(item: _item),

                      // ── 상품명 + 가격
                      Padding(
                        padding: const EdgeInsets.fromLTRB(DTokens.s20, DTokens.s24, DTokens.s20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _item.name,
                              style: DType.heading(24, color: Colors.white),
                            ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.08),

                            const SizedBox(height: DTokens.s16),

                            // 가격 + 잔여 포인트 (DShimmerSweep)
                            DShimmerSweep(
                              period: const Duration(milliseconds: 2600),
                              highlightOpacity: 0.16,
                              child: DGlassPanel(
                                teamBorder: true,
                                padding: const EdgeInsets.all(DTokens.s16),
                                radius: DTokens.r16,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: DScoreboard(
                                        value: '${_fmt(_item.price)} P',
                                        label: '교환 포인트',
                                        accent: canBuy ? team.primary : DTokens.textTertiaryDark,
                                        valueSize: 28,
                                      ),
                                    ),
                                    Container(width: 1, height: 44, color: DTokens.borderDark),
                                    Expanded(
                                      child: DScoreboard(
                                        value: '${_fmt(user.point)} P',
                                        label: '보유 포인트',
                                        accent: team.primary,
                                        valueSize: 22,
                                        align: TextAlign.center,
                                      ),
                                    ),
                                    if (!canBuy) ...[
                                      Container(width: 1, height: 44, color: DTokens.borderDark),
                                      Expanded(
                                        child: DScoreboard(
                                          value: '${_fmt(_item.price - user.point)} P',
                                          label: '부족',
                                          accent: DTokens.danger,
                                          valueSize: 20,
                                          align: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ).animate(delay: 150.ms).fadeIn().slideY(begin: 0.06),

                            const SizedBox(height: DTokens.s20),

                            _MetaPanel(item: _item),
                            const SizedBox(height: DTokens.s16),
                            _NoticePanel(notice: _item.notice),
                            const SizedBox(height: DTokens.s24),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── 교환 버튼
              _ExchangeBar(
                canBuy: canBuy,
                loading: _loading,
                onPressed: canBuy ? _onExchange : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── hero panel (D3DTiltCard + DShimmerSweep + DParticleEffect ambient) ────────

class _HeroPanel extends StatelessWidget {
  final RewardItem item;
  const _HeroPanel({required this.item});

  @override
  Widget build(BuildContext context) {
    final team = context.team;
    return D3DTiltCard(
      maxTiltDeg: 4,
      child: SizedBox(
        height: 280,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 그라데이션 배경
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    team.primary.withValues(alpha: 0.32),
                    team.secondary.withValues(alpha: 0.18),
                    DTokens.bgDark,
                  ],
                  stops: const [0, 0.5, 1],
                ),
              ),
            ),
            // 다이아몬드 그리드
            Positioned.fill(
              child: CustomPaint(
                painter: DDiamondGridPainter(team.primary.withValues(alpha: 0.08), step: 32),
              ),
            ),
            // 스캔라인
            Positioned.fill(
              child: CustomPaint(painter: DScanlinePainter(opacity: 0.012)),
            ),
            // 앰비언트 파티클
            Positioned.fill(
              child: DParticleEffect(
                color: team.primary,
                accentColor: team.accent,
                count: 12,
                active: true,
              ),
            ),
            // 글로우 오버레이
            Center(
              child: Container(
                width: 220, height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [team.primary.withValues(alpha: 0.18), Colors.transparent],
                  ),
                ),
              ),
            ),
            // DShimmerSweep
            Positioned.fill(
              child: DShimmerSweep(
                period: const Duration(milliseconds: 3000),
                highlightOpacity: 0.10,
                child: const SizedBox.expand(),
              ),
            ),
            // 아이콘
            Center(
              child: Image.asset(
                _categoryIcon(item.category),
                width: 120, height: 120,
                color: team.primary,
                colorBlendMode: BlendMode.srcIn,
                errorBuilder: (e, s, t) => Icon(
                  _categoryFallback(item.category),
                  size: 110, color: team.primary,
                ),
              )
                  .animate()
                  .scale(begin: const Offset(0.65, 0.65), curve: Curves.elasticOut, duration: 700.ms)
                  .fadeIn(),
            ),
            // 카테고리 배지 (좌하단)
            Positioned(
              bottom: DTokens.s20, left: DTokens.s20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: DTokens.s12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [team.primary, Color.lerp(team.primary, team.secondary, 0.5)!]),
                  borderRadius: BorderRadius.circular(DTokens.rPill),
                  boxShadow: [BoxShadow(color: team.primary.withValues(alpha: 0.6), blurRadius: 14)],
                ),
                child: Text(item.category, style: DType.badge(12, color: Colors.white)),
              ).animate(delay: 200.ms).fadeIn().slideX(begin: -0.1),
            ),
            // 재고 배지 (우상단)
            if (item.stock != null)
              Positioned(
                top: DTokens.s20, right: DTokens.s20,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: DTokens.s12, vertical: 6),
                  decoration: BoxDecoration(
                    color: DTokens.danger,
                    borderRadius: BorderRadius.circular(DTokens.rPill),
                    boxShadow: [BoxShadow(color: DTokens.danger.withValues(alpha: 0.5), blurRadius: 10)],
                  ),
                  child: Text('잔여 ${item.stock}개', style: DType.label(11, color: Colors.white)),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .fade(begin: 0.7, end: 1.0, duration: 800.ms),
              ),
          ],
        ),
      ),
    );
  }
}

// ── meta panel ────────────────────────────────────────────────────────────────

class _MetaPanel extends StatelessWidget {
  final RewardItem item;
  const _MetaPanel({required this.item});

  @override
  Widget build(BuildContext context) {
    return DGlassPanel(
      padding: const EdgeInsets.all(DTokens.s16),
      radius: DTokens.r16,
      child: Column(
        children: [
          _MetaRow(
            fallback: Icons.calendar_today_rounded,
            label: '유효기간',
            value: item.validUntil,
            valueColor: DTokens.textPrimaryDark,
          ),
          if (item.stock != null) ...[
            const Divider(color: DTokens.borderDark, height: DTokens.s20),
            _MetaRow(
              fallback: Icons.inventory_2_rounded,
              label: '잔여 수량',
              value: '${item.stock}개',
              valueColor: DTokens.danger,
            ),
          ],
        ],
      ),
    ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.06);
  }
}

class _MetaRow extends StatelessWidget {
  final IconData fallback;
  final String label;
  final String value;
  final Color valueColor;
  const _MetaRow({
    required this.fallback,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(fallback, size: 14, color: DTokens.textTertiaryDark),
        const SizedBox(width: DTokens.s8),
        SizedBox(
          width: 72,
          child: Text(label, style: DType.caption(13, color: DTokens.textSecondaryDark)),
        ),
        Expanded(
          child: Text(value, style: DType.mono(13, color: valueColor, weight: FontWeight.w700)),
        ),
      ],
    );
  }
}

// ── notice panel ──────────────────────────────────────────────────────────────

class _NoticePanel extends StatelessWidget {
  final String notice;
  const _NoticePanel({required this.notice});

  @override
  Widget build(BuildContext context) {
    return DGlassPanel(
      padding: const EdgeInsets.all(DTokens.s16),
      radius: DTokens.r16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline_rounded, size: 14, color: DTokens.warning),
              const SizedBox(width: DTokens.s8),
              Text('유의사항', style: DType.heading(13, color: DTokens.textPrimaryDark)),
            ],
          ),
          const SizedBox(height: DTokens.s12),
          Text(
            notice,
            style: DType.body(13).copyWith(color: DTokens.textSecondaryDark, height: 1.7),
          ),
        ],
      ),
    ).animate(delay: 280.ms).fadeIn().slideY(begin: 0.05);
  }
}

// ── exchange bar (파티클 효과) ────────────────────────────────────────────────

class _ExchangeBar extends StatelessWidget {
  final bool canBuy;
  final bool loading;
  final VoidCallback? onPressed;
  const _ExchangeBar({
    required this.canBuy,
    required this.loading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final team = context.team;
    return Container(
      padding: EdgeInsets.fromLTRB(
        DTokens.s20,
        DTokens.s12,
        DTokens.s20,
        MediaQuery.of(context).padding.bottom + DTokens.s12,
      ),
      decoration: const BoxDecoration(
        color: DTokens.bgDark,
        border: Border(top: BorderSide(color: DTokens.borderDark)),
      ),
      child: GestureDetector(
        onTap: onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 60,
          decoration: BoxDecoration(
            gradient: canBuy
                ? LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [team.primary, Color.lerp(team.primary, team.secondary, 0.6)!],
                  )
                : null,
            color: canBuy ? null : DTokens.surfaceDark,
            borderRadius: BorderRadius.circular(DTokens.r20),
            border: canBuy ? null : Border.all(color: DTokens.borderDark),
            boxShadow: canBuy
                ? [BoxShadow(color: team.primary.withValues(alpha: 0.55), blurRadius: 22, offset: const Offset(0, 4))]
                : null,
          ),
          child: Center(
            child: loading
                ? const SizedBox(
                    width: 24, height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        canBuy ? Icons.swap_horiz_rounded : Icons.lock_rounded,
                        size: 22,
                        color: canBuy ? Colors.white : DTokens.textTertiaryDark,
                      ),
                      const SizedBox(width: DTokens.s12),
                      Text(
                        canBuy ? '교환하기' : '포인트 부족',
                        style: DType.heading(18, color: canBuy ? Colors.white : DTokens.textTertiaryDark)
                            .copyWith(letterSpacing: 1),
                      ),
                    ],
                  ),
          ),
        ),
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

// ── confirm dialog ────────────────────────────────────────────────────────────

class _ConfirmDialog extends StatelessWidget {
  final RewardItem item;
  final int userPoint;
  const _ConfirmDialog({required this.item, required this.userPoint});

  @override
  Widget build(BuildContext context) {
    final team = context.team;
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(DTokens.r20),
        child: Container(
          color: DTokens.surfaceDark,
          padding: const EdgeInsets.all(DTokens.s24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('포인트 교환', style: DType.heading(18, color: Colors.white)),
              const SizedBox(height: DTokens.s16),
              Text(
                '${_fmt(item.price)} P를 사용하여\n${item.name}(을)를 교환하시겠습니까?',
                textAlign: TextAlign.center,
                style: DType.body(14).copyWith(color: DTokens.textSecondaryDark, height: 1.6),
              ),
              const SizedBox(height: DTokens.s24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context, false),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: DTokens.surfaceDark2,
                          borderRadius: BorderRadius.circular(DTokens.r12),
                          border: Border.all(color: DTokens.borderDark),
                        ),
                        child: Center(child: Text('취소', style: DType.label(14, color: DTokens.textSecondaryDark))),
                      ),
                    ),
                  ),
                  const SizedBox(width: DTokens.s12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context, true),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [team.primary, Color.lerp(team.primary, team.secondary, 0.6)!],
                          ),
                          borderRadius: BorderRadius.circular(DTokens.r12),
                          boxShadow: [BoxShadow(color: team.primary.withValues(alpha: 0.45), blurRadius: 12)],
                        ),
                        child: Center(child: Text('교환하기', style: DType.label(14, color: Colors.white))),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── coupon dialog (DExplosionParticles) ───────────────────────────────────────

class _CouponDialog extends StatelessWidget {
  final RewardItem item;
  const _CouponDialog({required this.item});

  String get _code {
    final base = item.id.toUpperCase().padRight(4, 'X');
    return 'DGT-$base-2025';
  }

  @override
  Widget build(BuildContext context) {
    final team = context.team;
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(DTokens.r20),
        child: Container(
          color: DTokens.surfaceDark,
          padding: const EdgeInsets.all(DTokens.s24),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // 폭발 파티클
              Positioned.fill(
                child: DExplosionParticles(
                  color: team.primary,
                  accentColor: team.accent,
                  count: 20,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 60, height: 60,
                    decoration: BoxDecoration(
                      color: team.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: team.primary.withValues(alpha: 0.4)),
                    ),
                    child: Center(
                      child: Icon(Icons.check_rounded, size: 32, color: team.primary),
                    ),
                  ).animate().scale(begin: const Offset(0.5, 0.5), duration: 400.ms, curve: Curves.elasticOut),
                  const SizedBox(height: DTokens.s16),
                  Text('교환 완료!', style: DType.heading(22, color: Colors.white)),
                  const SizedBox(height: DTokens.s8),
                  Text(item.name, textAlign: TextAlign.center,
                      style: DType.body(14).copyWith(color: DTokens.textSecondaryDark)),
                  const SizedBox(height: DTokens.s20),
                  // 쿠폰 코드 박스
                  DShimmerSweep(
                    period: const Duration(milliseconds: 2000),
                    highlightOpacity: 0.20,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: DTokens.s14, horizontal: DTokens.s16),
                      decoration: BoxDecoration(
                        color: DTokens.bgDark,
                        borderRadius: BorderRadius.circular(DTokens.r12),
                        border: Border.all(color: team.primary.withValues(alpha: 0.5)),
                        boxShadow: [BoxShadow(color: team.primary.withValues(alpha: 0.25), blurRadius: 12)],
                      ),
                      child: Text(
                        _code,
                        textAlign: TextAlign.center,
                        style: DType.mono(18, color: team.primary, weight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(height: DTokens.s24),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [team.primary, Color.lerp(team.primary, team.secondary, 0.6)!],
                        ),
                        borderRadius: BorderRadius.circular(DTokens.r12),
                        boxShadow: [BoxShadow(color: team.primary.withValues(alpha: 0.45), blurRadius: 14)],
                      ),
                      child: Center(child: Text('확인', style: DType.label(15, color: Colors.white))),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
