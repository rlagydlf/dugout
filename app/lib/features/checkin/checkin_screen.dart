import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_theme.dart';
import '../../app/theme/tokens.dart';
import '../../app/theme/typography.dart';
import '../../core/providers/app_providers.dart';
import '../../shared/widgets/d_glass_panel.dart';
import '../../shared/widgets/d_scoreboard.dart';

// ── mock ──────────────────────────────────────────────────────────────────────

const _kMockLat = 37.5122;
const _kMockLng = 127.0724;
const _kMockStadium = '잠실야구장';
const _kMockAddress = '서울 송파구 올림픽로 19-2';

final _locationGrantedProvider = StateProvider<bool>((ref) => true);
final _checkedInProvider = StateProvider<bool>((ref) => false);

// ── screen ────────────────────────────────────────────────────────────────────

class CheckinScreen extends ConsumerWidget {
  const CheckinScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final team = context.team;
    final user = ref.watch(userProvider);
    final granted = ref.watch(_locationGrantedProvider);
    final checkedIn = ref.watch(_checkedInProvider);

    return Scaffold(
      backgroundColor: DTokens.bgDark,
      appBar: AppBar(
        backgroundColor: DTokens.bgDark,
        elevation: 0,
        leading: const BackButton(),
        title: Row(
          children: [
            Image.asset(
              'assets/images/icons/stadium.png',
              width: 20,
              height: 20,
              errorBuilder: (e, s, t) =>
                  const Icon(Icons.stadium_rounded, size: 20),
            ),
            const SizedBox(width: DTokens.s8),
            Text('직관 체크인', style: DType.heading(17, color: Colors.white)),
          ],
        ),
      ),
      body: Stack(
        children: [
          // ── 팀 컬러 글로우 상단
          Positioned(
            top: -60,
            left: -60,
            right: -60,
            child: Container(
              height: 260,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 0.8,
                  colors: [
                    team.primary.withValues(alpha: 0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          CustomScrollView(
            slivers: [
              // ── 스타디움 히어로
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      DTokens.s16, DTokens.s8, DTokens.s16, 0),
                  child: _StadiumHero(team: team),
                ),
              ),

              const SliverToBoxAdapter(
                  child: SizedBox(height: DTokens.s16)),

              // ── 위치 카드 (DGlassPanel)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: DTokens.s16),
                  child: _LocationCard(
                      granted: granted, ref: ref),
                ),
              ),

              const SliverToBoxAdapter(
                  child: SizedBox(height: DTokens.s16)),

              // ── 체크인 버튼
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: DTokens.s16),
                  child: _CheckinButton(
                    granted: granted,
                    checkedIn: checkedIn,
                    onCheckin: () => _handleCheckin(context, ref),
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                  child: SizedBox(height: DTokens.s24)),

              // ── 시즌 방문 통계
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: DTokens.s16),
                  child: _SeasonVisitCard(
                    visitCount: user.stadiumVisits,
                    team: team,
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                  child: SizedBox(height: DTokens.s16)),

              // ── 어뷰징 안내 (micro)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    DTokens.s16,
                    0,
                    DTokens.s16,
                    MediaQuery.of(context).padding.bottom + DTokens.s40,
                  ),
                  child: Text(
                    '* 직관 체크인은 구장 반경 500m 이내에서만 인증됩니다. '
                    '어뷰징(허위 위치 인증)이 적발되면 포인트가 회수되고 계정이 제한될 수 있습니다.',
                    style: DType.label(12,
                        color: DTokens.textTertiaryDark),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleCheckin(BuildContext context, WidgetRef ref) {
    ref.read(_checkedInProvider.notifier).state = true;
    ref.read(userProvider.notifier).addPoint(200);
    final team = context.team;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Image.asset(
              'assets/images/icons/trophy.png',
              width: 20,
              height: 20,
              errorBuilder: (e, s, t) => const Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: DTokens.s12),
            Text(
              '+200P · 직관 퀘스트 완료!',
              style: DType.body(16, FontWeight.w700)
                  .copyWith(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: team.primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DTokens.r12),
        ),
      ),
    );
  }
}

// ── stadium hero ──────────────────────────────────────────────────────────────

class _StadiumHero extends StatelessWidget {
  final dynamic team;
  const _StadiumHero({required this.team});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 210,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(DTokens.r24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            (team.primary as Color),
            Color.lerp(team.primary as Color, team.secondary as Color, 0.5)!,
            (team.secondary as Color),
          ],
          stops: const [0.0, 0.55, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: (team.primary as Color).withValues(alpha: 0.4),
            blurRadius: 32,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 패턴 텍스처
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Image.asset(
                (team.patternAsset as String),
                fit: BoxFit.cover,
                errorBuilder: (e, s, t) => const SizedBox.shrink(),
              ),
            ),
          ),

          // 스타디움 아이콘 대형 (우하단)
          Positioned(
            right: -20,
            bottom: -20,
            child: Opacity(
              opacity: 0.18,
              child: Image.asset(
                'assets/images/icons/stadium.png',
                width: 200,
                errorBuilder: (e, s, t) => Icon(
                  Icons.stadium_rounded,
                  size: 180,
                  color: Colors.white.withValues(alpha: 0.15),
                ),
              ),
            ),
          ),

          // 다크 그라데이션 (텍스트 가독성)
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.4),
                  ],
                ),
              ),
            ),
          ),

          // 콘텐츠
          Padding(
            padding: const EdgeInsets.all(DTokens.s24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // LIVE CHECK-IN 배지
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: DTokens.s8, vertical: DTokens.s4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(DTokens.rPill),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      )
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .fade(begin: 0.3, end: 1.0, duration: 800.ms),
                      const SizedBox(width: 6),
                      Text(
                        'LIVE CHECK-IN',
                        style: DType.badge(9, color: Colors.white),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // 구장명 + 주소
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _kMockStadium,
                            style: DType.impact(28,
                                color: Colors.white,
                                letterSpacing: 1.5),
                          ),
                          const SizedBox(height: DTokens.s4),
                          Text(
                            _kMockAddress,
                            style: DType.body(15).copyWith(
                              color: Colors.white.withValues(alpha: 0.75),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 팀 로고
                    Image.asset(
                      (team.crestAsset as String),
                      width: 52,
                      height: 52,
                      fit: BoxFit.contain,
                      errorBuilder: (e, s, t) => Icon(
                        Icons.sports_baseball_rounded,
                        size: 52,
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.07);
  }
}

// ── location card ─────────────────────────────────────────────────────────────

class _LocationCard extends StatelessWidget {
  final bool granted;
  final WidgetRef ref;
  const _LocationCard({required this.granted, required this.ref});

  @override
  Widget build(BuildContext context) {
    final team = context.team;
    return DGlassPanel(
      teamBorder: true,
      padding: const EdgeInsets.all(DTokens.s16),
      radius: DTokens.r20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: (granted ? DTokens.success : DTokens.danger)
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(DTokens.r8),
                ),
                child: Icon(
                  granted
                      ? Icons.location_on_rounded
                      : Icons.location_off_rounded,
                  size: 18,
                  color: granted ? DTokens.success : DTokens.danger,
                ),
              ),
              const SizedBox(width: DTokens.s12),
              Text(
                '현재 위치 확인',
                style: DType.heading(15, color: Colors.white),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => ref
                    .read(_locationGrantedProvider.notifier)
                    .state = !granted,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: DTokens.s4),
                  decoration: BoxDecoration(
                    color: DTokens.borderDark,
                    borderRadius: BorderRadius.circular(DTokens.rPill),
                  ),
                  child: Text(
                    granted ? '권한 ON' : '권한 OFF',
                    style: DType.label(11,
                        color: granted ? DTokens.success : DTokens.danger),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: DTokens.s16),
          if (granted) ...[
            _LocationRow(
              assetPath: 'assets/images/icons/plate.png',
              fallback: Icons.my_location_rounded,
              label: '좌표',
              value:
                  '${_kMockLat.toStringAsFixed(4)}, ${_kMockLng.toStringAsFixed(4)}',
              valueStyle:
                  DType.mono(12, color: DTokens.textPrimaryDark),
            ),
            const SizedBox(height: 10),
            _LocationRow(
              assetPath: 'assets/images/icons/stadium.png',
              fallback: Icons.stadium_rounded,
              label: '매칭 구장',
              value: _kMockStadium,
              valueStyle: DType.mono(12, color: team.primary),
            ),
            const SizedBox(height: 10),
            _LocationRow(
              assetPath: 'assets/images/icons/bats.png',
              fallback: Icons.social_distance_rounded,
              label: '거리',
              value: '약 120m',
              valueStyle:
                  DType.mono(12, color: DTokens.success),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(DTokens.s12),
              decoration: BoxDecoration(
                color: DTokens.danger.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DTokens.r12),
                border: Border.all(
                    color: DTokens.danger.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_rounded,
                      color: DTokens.danger, size: 16),
                  const SizedBox(width: DTokens.s8),
                  Expanded(
                    child: Text(
                      '위치 권한이 거부됐습니다. 체크인하려면 권한을 허용해 주세요.',
                      style: DType.body(15).copyWith(
                        color: DTokens.danger,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ).animate(delay: 100.ms).fadeIn(duration: 400.ms).slideY(begin: 0.06);
  }
}

class _LocationRow extends StatelessWidget {
  final String assetPath;
  final IconData fallback;
  final String label;
  final String value;
  final TextStyle valueStyle;

  const _LocationRow({
    required this.assetPath,
    required this.fallback,
    required this.label,
    required this.value,
    required this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          assetPath,
          width: 14,
          height: 14,
          errorBuilder: (e, s, t) =>
              Icon(fallback, size: 14, color: DTokens.textSecondaryDark),
        ),
        const SizedBox(width: DTokens.s8),
        Text(
          '$label  ',
          style: DType.body(15)
              .copyWith(color: DTokens.textSecondaryDark),
        ),
        Expanded(
          child: Text(value, style: valueStyle, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}

// ── checkin button ────────────────────────────────────────────────────────────

class _CheckinButton extends StatelessWidget {
  final bool granted;
  final bool checkedIn;
  final VoidCallback onCheckin;

  const _CheckinButton({
    required this.granted,
    required this.checkedIn,
    required this.onCheckin,
  });

  @override
  Widget build(BuildContext context) {
    final team = context.team;

    if (checkedIn) {
      return Container(
        height: 68,
        decoration: BoxDecoration(
          color: DTokens.success.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(DTokens.r20),
          border: Border.all(
              color: DTokens.success.withValues(alpha: 0.45)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_rounded,
                color: DTokens.success, size: 28),
            const SizedBox(width: DTokens.s12),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '직관 체크인 완료!',
                  style: DType.heading(18).copyWith(
                      color: DTokens.success, letterSpacing: 1),
                ),
                Text(
                  '+200P 적립 · 직관 퀘스트 완료',
                  style: DType.body(14).copyWith(
                    color: DTokens.success.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ],
        ),
      ).animate().scale(duration: 320.ms, curve: Curves.easeOutBack);
    }

    return GestureDetector(
      onTap: granted ? onCheckin : null,
      child: Container(
        height: 68,
        decoration: BoxDecoration(
          gradient: granted
              ? LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    team.primary,
                    Color.lerp(team.primary, team.secondary, 0.6)!,
                  ],
                )
              : null,
          color: granted ? null : DTokens.surfaceDark,
          borderRadius: BorderRadius.circular(DTokens.r20),
          border: granted
              ? null
              : Border.all(color: DTokens.borderDark),
          boxShadow: granted
              ? [
                  BoxShadow(
                    color: team.primary.withValues(alpha: 0.5),
                    blurRadius: 24,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        padding: const EdgeInsets.symmetric(horizontal: DTokens.s20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/icons/stadium.png',
              width: 26,
              height: 26,
              errorBuilder: (e, s, t) => Icon(
                Icons.location_on_rounded,
                size: 26,
                color: granted
                    ? Colors.white
                    : DTokens.textTertiaryDark,
              ),
            ),
            const SizedBox(width: DTokens.s12),
            Text(
              granted ? '직관 체크인' : '위치 권한 필요',
              style: DType.impact(20,
                  color: granted
                      ? Colors.white
                      : DTokens.textTertiaryDark,
                  letterSpacing: 1),
            ),
            if (granted) ...[
              const SizedBox(width: DTokens.s12),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: DTokens.s4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(DTokens.rPill),
                ),
                child: Text(
                  '+200P',
                  style: DType.badge(12, color: Colors.white),
                ),
              ),
            ],
          ],
        ),
      ),
    ).animate(delay: 200.ms).fadeIn(duration: 400.ms).slideY(begin: 0.08);
  }
}

// ── season visit card ─────────────────────────────────────────────────────────

class _SeasonVisitCard extends StatelessWidget {
  final int visitCount;
  final dynamic team;
  const _SeasonVisitCard({required this.visitCount, required this.team});

  @override
  Widget build(BuildContext context) {
    final t = context.team;
    return DGlassPanel(
      teamBorder: false,
      padding: const EdgeInsets.all(DTokens.s20),
      radius: DTokens.r20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/images/icons/scoreboard.png',
                width: 18,
                height: 18,
                errorBuilder: (e, s, t) =>
                    const Icon(Icons.scoreboard_rounded, size: 18, color: Colors.white54),
              ),
              const SizedBox(width: DTokens.s8),
              Text(
                '이번 시즌 내 직관',
                style: DType.heading(15, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: DTokens.s20),

          // DScoreboard 3개
          Row(
            children: [
              Expanded(
                child: DScoreboard(
                  value: '$visitCount',
                  label: '총 직관',
                  accent: t.primary,
                  valueSize: 28,
                  align: TextAlign.center,
                ),
              ),
              Container(width: 1, height: 44, color: DTokens.borderDark),
              Expanded(
                child: DScoreboard(
                  value: '잠실',
                  label: '최근 구장',
                  accent: DTokens.info,
                  valueSize: 22,
                  align: TextAlign.center,
                ),
              ),
              Container(width: 1, height: 44, color: DTokens.borderDark),
              Expanded(
                child: DScoreboard(
                  value: '04.22',
                  label: '마지막 방문',
                  accent: DTokens.textSecondaryDark,
                  valueSize: 22,
                  align: TextAlign.center,
                ),
              ),
            ],
          ),

          const SizedBox(height: DTokens.s16),

          // 진행률 바
          Row(
            children: List.generate(10, (i) {
              final filled = i < visitCount;
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  height: 6,
                  decoration: BoxDecoration(
                    color: filled ? t.primary : DTokens.borderDark,
                    borderRadius: BorderRadius.circular(DTokens.rPill),
                    boxShadow: filled
                        ? [
                            BoxShadow(
                              color: t.primary.withValues(alpha: 0.4),
                              blurRadius: 4,
                            )
                          ]
                        : null,
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: DTokens.s8),
          Text(
            '$visitCount / 10 직관 달성 시 골드 뱃지 획득',
            style: DType.label(12,
                color: DTokens.textTertiaryDark),
          ),
        ],
      ),
    ).animate(delay: 300.ms).fadeIn(duration: 400.ms).slideY(begin: 0.06);
  }
}
