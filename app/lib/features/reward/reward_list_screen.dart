import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_theme.dart';
import '../../app/theme/tokens.dart';
import '../../app/theme/typography.dart';
import '../../core/providers/app_providers.dart';
import '../../shared/widgets/d_glass_panel.dart';
import '../../shared/widgets/d_scoreboard.dart';

// ── icon mapping ──────────────────────────────────────────────────────────────

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
    case '디지털 아이템':
      return Icons.palette_rounded;
    case '한정':
      return Icons.timer_rounded;
    default:
      return Icons.star_rounded;
  }
}

// ── mock ──────────────────────────────────────────────────────────────────────

class _Reward {
  final String id;
  final String name;
  final String category;
  final int price;
  final int? stock;
  final bool hot;
  final bool closing;
  final bool featured;
  const _Reward({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    this.stock,
    this.hot = false,
    this.closing = false,
    this.featured = false,
  });
}

const _allRewards = [
  _Reward(id: 'r1', name: '스타벅스 아메리카노 T', category: '기프티콘', price: 4500, hot: true, featured: true),
  _Reward(id: 'r2', name: 'CGV 영화 1매', category: '제휴 쿠폰', price: 8500, hot: true),
  _Reward(id: 'r3', name: '응원봉 야광 스페셜', category: '야구용품', price: 12000, stock: 23, featured: true),
  _Reward(id: 'r4', name: '팬카드 네온 테마', category: '디지털 아이템', price: 3000),
  _Reward(id: 'r5', name: '치킨 세트 30% 쿠폰', category: '제휴 쿠폰', price: 5500, hot: true),
  _Reward(id: 'r6', name: '시즌권 응모권', category: '한정', price: 20000, stock: 5, closing: true, featured: true),
  _Reward(id: 'r7', name: '메가커피 아메리카노', category: '기프티콘', price: 2800),
  _Reward(id: 'r8', name: '경기장 특석 추첨권', category: '한정', price: 15000, stock: 12, closing: true),
  _Reward(id: 'r9', name: '팀 로고 키캡 세트', category: '야구용품', price: 9000, stock: 40),
  _Reward(id: 'r10', name: '더그아웃 프리미엄 배지', category: '디지털 아이템', price: 6000, hot: true),
  _Reward(id: 'r11', name: '버거킹 세트 20% 할인', category: '제휴 쿠폰', price: 4000),
  _Reward(id: 'r12', name: '사인볼 직접배송 추첨', category: '한정', price: 25000, stock: 3, closing: true),
];

const _categories = ['전체', '기프티콘', '야구용품', '제휴 쿠폰', '디지털 아이템', '한정'];

String _fmt(int v) {
  final s = v.toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return buf.toString();
}

// ── Screen ────────────────────────────────────────────────────────────────────

class RewardListScreen extends ConsumerStatefulWidget {
  const RewardListScreen({super.key});
  @override
  ConsumerState<RewardListScreen> createState() => _RewardListScreenState();
}

class _RewardListScreenState extends ConsumerState<RewardListScreen> {
  int _catIndex = 0;

  List<_Reward> get _filtered {
    if (_catIndex == 0) return _allRewards;
    return _allRewards.where((r) => r.category == _categories[_catIndex]).toList();
  }

  @override
  Widget build(BuildContext context) {
    final team = context.team;
    final user = ref.watch(userProvider);
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: DTokens.bgDark,
      appBar: AppBar(
        backgroundColor: DTokens.bgDark,
        elevation: 0,
        leading: const BackButton(),
        title: Row(
          children: [
            Image.asset(
              'assets/images/icons/trophy.png',
              width: 20,
              height: 20,
              errorBuilder: (e, s, t) =>
                  Icon(Icons.emoji_events_rounded, size: 20, color: team.primary),
            ),
            const SizedBox(width: DTokens.s8),
            Text('리워드 샵', style: DType.heading(17, color: Colors.white)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: DTokens.s16),
            child: _PointChip(point: user.point, teamColor: team.primary),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // ── 포인트 요약 배너
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(DTokens.s16, DTokens.s8, DTokens.s16, 0),
              child: _BalanceBanner(point: user.point),
            ),
          ),

          // ── 카테고리 필터
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, DTokens.s16, 0, DTokens.s8),
              child: _CategoryFilter(
                selected: _catIndex,
                onSelect: (i) => setState(() => _catIndex = i),
              ),
            ),
          ),

          // ── 추천 가로 스크롤 (전체 탭만)
          if (_catIndex == 0) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(DTokens.s16, DTokens.s4, DTokens.s16, 0),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/icons/bolt.png',
                      width: 14,
                      height: 14,
                      errorBuilder: (e, s, t) =>
                          Icon(Icons.bolt_rounded, size: 14, color: DTokens.warning),
                    ),
                    const SizedBox(width: DTokens.s8),
                    Text('FEATURED', style: DType.badge(11, color: DTokens.warning)),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 196,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(DTokens.s16, DTokens.s12, DTokens.s16, DTokens.s8),
                  itemCount: _allRewards.where((r) => r.featured).length,
                  separatorBuilder: (e, s) => const SizedBox(width: DTokens.s12),
                  itemBuilder: (context, i) {
                    final r = _allRewards.where((r) => r.featured).toList()[i];
                    return _FeaturedCard(reward: r, userPoint: user.point)
                        .animate()
                        .fadeIn(delay: Duration(milliseconds: 80 * i))
                        .slideX(begin: 0.08);
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(DTokens.s16, DTokens.s16, DTokens.s16, 0),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/icons/megaphone.png',
                      width: 14,
                      height: 14,
                      errorBuilder: (e, s, t) =>
                          Icon(Icons.local_fire_department_rounded, size: 14, color: DTokens.danger),
                    ),
                    const SizedBox(width: DTokens.s8),
                    Text('HOT ITEMS', style: DType.badge(11, color: DTokens.danger)),
                  ],
                ),
              ),
            ),
          ],

          // ── 메인 그리드
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(DTokens.s16, DTokens.s12, DTokens.s16, DTokens.s16),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final list = _catIndex == 0
                      ? _allRewards.where((r) => r.hot || !r.featured).toList()
                      : filtered;
                  if (i >= list.length) return null;
                  return _RewardCard(reward: list[i], userPoint: user.point)
                      .animate()
                      .fadeIn(delay: Duration(milliseconds: 50 * i))
                      .slideY(begin: 0.06);
                },
                childCount: _catIndex == 0
                    ? _allRewards.where((r) => r.hot || !r.featured).length
                    : filtered.length,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: DTokens.s12,
                crossAxisSpacing: DTokens.s12,
                childAspectRatio: 0.78,
              ),
            ),
          ),

          // ── 마감임박 섹션 (전체 탭만)
          if (_catIndex == 0) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(DTokens.s16, DTokens.s8, DTokens.s16, 0),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/icons/scoreboard.png',
                      width: 14,
                      height: 14,
                      errorBuilder: (e, s, t) =>
                          Icon(Icons.timer_rounded, size: 14, color: DTokens.warning),
                    ),
                    const SizedBox(width: DTokens.s8),
                    Text('CLOSING SOON', style: DType.badge(11, color: DTokens.warning)),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                DTokens.s16,
                DTokens.s12,
                DTokens.s16,
                MediaQuery.of(context).padding.bottom + DTokens.s40,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final closing = _allRewards.where((r) => r.closing).toList();
                    if (i >= closing.length) return null;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: DTokens.s8),
                      child: _ClosingTile(reward: closing[i], userPoint: user.point)
                          .animate()
                          .fadeIn(delay: Duration(milliseconds: 60 * i)),
                    );
                  },
                  childCount: _allRewards.where((r) => r.closing).length,
                ),
              ),
            ),
          ] else ...[
            SliverToBoxAdapter(
              child: SizedBox(height: MediaQuery.of(context).padding.bottom + DTokens.s24),
            ),
          ],
        ],
      ),
    );
  }
}

// ── balance banner ────────────────────────────────────────────────────────────

class _BalanceBanner extends StatelessWidget {
  final int point;
  const _BalanceBanner({required this.point});

  @override
  Widget build(BuildContext context) {
    final team = context.team;
    return ClipRRect(
      borderRadius: BorderRadius.circular(DTokens.r20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: DTokens.s20, vertical: DTokens.s16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              team.primary.withValues(alpha: 0.22),
              team.secondary.withValues(alpha: 0.12),
            ],
          ),
          border: Border.all(color: team.primary.withValues(alpha: 0.28)),
          borderRadius: BorderRadius.circular(DTokens.r20),
        ),
        child: Row(
          children: [
            Icon(Icons.diamond_rounded, size: 20, color: team.primary),
            const SizedBox(width: DTokens.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '보유 포인트',
                    style: DType.label(11, color: DTokens.textTertiaryDark),
                  ),
                  Text(
                    '${_fmt(point)} P',
                    style: DType.mono(22, color: Colors.white, weight: FontWeight.w900),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: DTokens.s12, vertical: DTokens.s8),
              decoration: BoxDecoration(
                color: team.primary,
                borderRadius: BorderRadius.circular(DTokens.rPill),
                boxShadow: [
                  BoxShadow(
                    color: team.primary.withValues(alpha: 0.4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Text('충전', style: DType.badge(12, color: Colors.white)),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05);
  }
}

// ── category filter ───────────────────────────────────────────────────────────

class _CategoryFilter extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelect;
  const _CategoryFilter({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final team = context.team;
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: DTokens.s16),
        itemCount: _categories.length,
        separatorBuilder: (e, s) => const SizedBox(width: DTokens.s8),
        itemBuilder: (context, i) {
          final active = selected == i;
          return GestureDetector(
            onTap: () => onSelect(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: DTokens.s16, vertical: DTokens.s8),
              decoration: BoxDecoration(
                color: active ? team.primary : DTokens.surfaceDark,
                borderRadius: BorderRadius.circular(DTokens.rPill),
                border: Border.all(
                  color: active ? team.primary : DTokens.borderDark,
                ),
                boxShadow: active
                    ? [
                        BoxShadow(
                          color: team.primary.withValues(alpha: 0.4),
                          blurRadius: 10,
                        ),
                      ]
                    : null,
              ),
              child: Text(
                _categories[i],
                style: DType.label(12, color: active ? Colors.white : DTokens.textSecondaryDark),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── featured card (horizontal scroll) ─────────────────────────────────────────

class _FeaturedCard extends StatelessWidget {
  final _Reward reward;
  final int userPoint;
  const _FeaturedCard({required this.reward, required this.userPoint});

  @override
  Widget build(BuildContext context) {
    final team = context.team;
    final canBuy = userPoint >= reward.price;

    return Container(
      width: 156,
      decoration: BoxDecoration(
        color: DTokens.surfaceDark,
        borderRadius: BorderRadius.circular(DTokens.r20),
        border: Border.all(color: team.primary.withValues(alpha: 0.28)),
        boxShadow: [
          BoxShadow(
            color: team.primary.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 아이콘 영역
          Container(
            height: 84,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  team.primary.withValues(alpha: 0.22),
                  team.secondary.withValues(alpha: 0.12),
                ],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(DTokens.r20)),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(
                  _categoryIcon(reward.category),
                  width: 52,
                  height: 52,
                  color: team.primary,
                  colorBlendMode: BlendMode.srcIn,
                  errorBuilder: (e, s, t) =>
                      Icon(_categoryFallback(reward.category), size: 48, color: team.primary),
                ),
                if (reward.closing)
                  Positioned(
                    top: DTokens.s8,
                    right: DTokens.s8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: DTokens.danger,
                        borderRadius: BorderRadius.circular(DTokens.rPill),
                      ),
                      child: Text('마감임박', style: DType.label(11, color: Colors.white)),
                    )
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .fade(begin: 0.6, end: 1.0, duration: 700.ms),
                  ),
              ],
            ),
          ),
          // 정보 영역
          Padding(
            padding: const EdgeInsets.all(DTokens.s12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reward.category,
                  style: DType.label(11, color: DTokens.textTertiaryDark),
                ),
                const SizedBox(height: DTokens.s4),
                Text(
                  reward.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: DType.body(14, FontWeight.w700)
                      .copyWith(color: DTokens.textPrimaryDark, height: 1.3),
                ),
                const SizedBox(height: DTokens.s4),
                Text(
                  '${_fmt(reward.price)} P',
                  style: DType.mono(14,
                      color: canBuy ? team.primary : DTokens.textTertiaryDark,
                      weight: FontWeight.w900),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── reward grid card ──────────────────────────────────────────────────────────

class _RewardCard extends StatelessWidget {
  final _Reward reward;
  final int userPoint;
  const _RewardCard({required this.reward, required this.userPoint});

  @override
  Widget build(BuildContext context) {
    final team = context.team;
    final canBuy = userPoint >= reward.price;

    return DGlassPanel(
      padding: EdgeInsets.zero,
      radius: DTokens.r16,
      onTap: () {},
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 아이콘 영역
          Expanded(
            flex: 5,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    team.primary.withValues(alpha: 0.18),
                    team.secondary.withValues(alpha: 0.08),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(DTokens.r16)),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Image.asset(
                      _categoryIcon(reward.category),
                      width: 44,
                      height: 44,
                      color: team.primary,
                      colorBlendMode: BlendMode.srcIn,
                      errorBuilder: (e, s, t) =>
                          Icon(_categoryFallback(reward.category), size: 44, color: team.primary),
                    ),
                  ),
                  if (reward.stock != null)
                    Positioned(
                      top: DTokens.s8,
                      right: DTokens.s8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: reward.closing
                              ? DTokens.danger.withValues(alpha: 0.9)
                              : DTokens.surfaceDark2,
                          borderRadius: BorderRadius.circular(DTokens.rPill),
                        ),
                        child: Text(
                          '${reward.stock}개',
                          style: DType.label(11, color: Colors.white),
                        ),
                      ),
                    ),
                  if (reward.hot)
                    Positioned(
                      top: DTokens.s8,
                      left: DTokens.s8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: DTokens.danger.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(DTokens.r4),
                        ),
                        child: Text('HOT', style: DType.badge(8, color: Colors.white)),
                      ),
                    ),
                ],
              ),
            ),
          ),
          // 텍스트 영역
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.all(DTokens.s12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(reward.category, style: DType.label(11, color: DTokens.textTertiaryDark)),
                  const SizedBox(height: DTokens.s4),
                  Expanded(
                    child: Text(
                      reward.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: DType.body(15, FontWeight.w700)
                          .copyWith(color: DTokens.textPrimaryDark, height: 1.3),
                    ),
                  ),
                  const SizedBox(height: DTokens.s4),
                  Text(
                    '${_fmt(reward.price)} P',
                    style: DType.mono(15,
                        color: canBuy ? team.primary : DTokens.textTertiaryDark,
                        weight: FontWeight.w900),
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

// ── closing tile ──────────────────────────────────────────────────────────────

class _ClosingTile extends StatelessWidget {
  final _Reward reward;
  final int userPoint;
  const _ClosingTile({required this.reward, required this.userPoint});

  @override
  Widget build(BuildContext context) {
    final team = context.team;
    final canBuy = userPoint >= reward.price;

    return DGlassPanel(
      padding: const EdgeInsets.all(DTokens.s16),
      radius: DTokens.r16,
      onTap: () {},
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: team.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(DTokens.r12),
            ),
            child: Center(
              child: Image.asset(
                _categoryIcon(reward.category),
                width: 28,
                height: 28,
                color: team.primary,
                colorBlendMode: BlendMode.srcIn,
                errorBuilder: (e, s, t) =>
                    Icon(_categoryFallback(reward.category), size: 28, color: team.primary),
              ),
            ),
          ),
          const SizedBox(width: DTokens.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reward.name,
                  style: DType.body(14, FontWeight.w700)
                      .copyWith(color: DTokens.textPrimaryDark),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(reward.category, style: DType.label(11, color: DTokens.textTertiaryDark)),
                    if (reward.stock != null) ...[
                      const SizedBox(width: DTokens.s8),
                      Text(
                        '잔여 ${reward.stock}개',
                        style: DType.label(11, color: DTokens.danger),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${_fmt(reward.price)} P',
                style: DType.mono(15,
                    color: canBuy ? team.primary : DTokens.textTertiaryDark,
                    weight: FontWeight.w900),
              ),
              const SizedBox(height: 2),
              Text('마감임박', style: DType.label(11, color: DTokens.warning)),
            ],
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
          Image.asset(
            'assets/images/icons/baseball.png',
            width: 12,
            height: 12,
            color: teamColor,
            colorBlendMode: BlendMode.srcIn,
            errorBuilder: (e, s, t) => Icon(Icons.diamond_rounded, size: 12, color: teamColor),
          ),
          const SizedBox(width: DTokens.s4),
          Text('${_fmt(point)} P', style: DType.mono(12, color: teamColor, weight: FontWeight.w700)),
        ],
      ),
    );
  }
}
