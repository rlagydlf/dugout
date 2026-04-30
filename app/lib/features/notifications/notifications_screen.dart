import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_theme.dart';
import '../../app/theme/tokens.dart';
import '../../app/theme/typography.dart';
import '../../shared/widgets/d_glass_panel.dart';

// ── mock data ─────────────────────────────────────────────────────────────────

enum _NotiType { sortie, prediction, settlement, reward, notice }

class _Noti {
  final String id;
  final _NotiType type;
  final String title;
  final String body;
  final String time;
  final bool read;
  const _Noti({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.time,
    this.read = false,
  });
  _Noti copyWith({bool? read}) => _Noti(
        id: id,
        type: type,
        title: title,
        body: body,
        time: time,
        read: read ?? this.read,
      );
}

const _seedNotis = [
  _Noti(
      id: 'n1',
      type: _NotiType.sortie,
      title: '오늘 출정하셨나요?',
      body: 'LG 트윈스 vs KIA 타이거즈 경기가 19:00에 시작됩니다. 출정 선언하고 포인트 받으세요!',
      time: '2시간 전'),
  _Noti(
      id: 'n2',
      type: _NotiType.prediction,
      title: '예측 마감 1시간 전',
      body: '오늘의 승리팀 예측이 곧 마감됩니다. 서두르세요!',
      time: '3시간 전'),
  _Noti(
      id: 'n3',
      type: _NotiType.reward,
      title: '리워드 도착!',
      body: '스타벅스 아메리카노 쿠폰이 발급되었습니다. 30일 내 사용하세요.',
      time: '어제',
      read: true),
  _Noti(
      id: 'n4',
      type: _NotiType.settlement,
      title: '예측 정산 완료',
      body: '어젯밤 LG 트윈스 승리 예측 적중! +200P가 적립되었습니다.',
      time: '어제',
      read: true),
  _Noti(
      id: 'n5',
      type: _NotiType.notice,
      title: '서비스 점검 안내',
      body: '4월 30일 새벽 2시~4시 점검 예정입니다. 이용에 참고 바랍니다.',
      time: '2일 전',
      read: true),
  _Noti(
      id: 'n6',
      type: _NotiType.sortie,
      title: '내일 직관 가시나요?',
      body: '잠실야구장 경기 내일 예정! 미리 출정 계획 세워보세요.',
      time: '2일 전',
      read: true),
  _Noti(
      id: 'n7',
      type: _NotiType.prediction,
      title: '예측 결과 발표',
      body: '두산 vs KT 경기 예측 결과가 나왔습니다. 결과 확인하세요.',
      time: '3일 전',
      read: true),
  _Noti(
      id: 'n8',
      type: _NotiType.reward,
      title: '한정 리워드 입고!',
      body: '시즌권 응모권이 5장 입고되었습니다. 빠르게 교환하세요.',
      time: '4일 전',
      read: true),
  _Noti(
      id: 'n9',
      type: _NotiType.settlement,
      title: '주간 기여도 정산',
      body: '이번 주 기여도 +320 포인트 적립! 팀 순위 42위입니다.',
      time: '1주일 전',
      read: true),
  _Noti(
      id: 'n10',
      type: _NotiType.notice,
      title: '새 기능 오픈: 팬카드 꾸미기',
      body: '이제 팬카드 테마와 배지를 직접 커스터마이즈할 수 있습니다!',
      time: '1주일 전',
      read: true),
];

// ── type meta ─────────────────────────────────────────────────────────────────

extension _NotiTypeMeta on _NotiType {
  IconData get icon => switch (this) {
        _NotiType.sortie => Icons.rocket_launch_rounded,
        _NotiType.prediction => Icons.psychology_rounded,
        _NotiType.settlement => Icons.account_balance_wallet_rounded,
        _NotiType.reward => Icons.card_giftcard_rounded,
        _NotiType.notice => Icons.campaign_rounded,
      };

  String get assetPath => switch (this) {
        _NotiType.sortie => 'assets/images/icons/bolt.png',
        _NotiType.prediction => 'assets/images/icons/baseball.png',
        _NotiType.settlement => 'assets/images/icons/trophy.png',
        _NotiType.reward => 'assets/images/icons/mitt.png',
        _NotiType.notice => 'assets/images/icons/megaphone.png',
      };

  Color get color => switch (this) {
        _NotiType.sortie => DTokens.info,
        _NotiType.prediction => DTokens.warning,
        _NotiType.settlement => DTokens.success,
        _NotiType.reward => const Color(0xFF9B6DFF),
        _NotiType.notice => DTokens.textSecondaryDark,
      };

  String get label => switch (this) {
        _NotiType.sortie => '출정',
        _NotiType.prediction => '예측',
        _NotiType.settlement => '정산',
        _NotiType.reward => '리워드',
        _NotiType.notice => '공지',
      };
}

// ── screen ────────────────────────────────────────────────────────────────────

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});
  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  late List<_Noti> _notis;

  @override
  void initState() {
    super.initState();
    _notis = List.from(_seedNotis);
    _tab = TabController(length: 2, vsync: this);
    _tab.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  void _markAllRead() {
    setState(() {
      _notis = _notis.map((n) => n.copyWith(read: true)).toList();
    });
  }

  void _markRead(String id) {
    setState(() {
      _notis = _notis.map((n) => n.id == id ? n.copyWith(read: true) : n).toList();
    });
  }

  List<_Noti> get _current =>
      _tab.index == 0 ? _notis : _notis.where((n) => !n.read).toList();

  int get _unreadCount => _notis.where((n) => !n.read).length;

  @override
  Widget build(BuildContext context) {
    final team = context.team;
    final list = _current;

    return Scaffold(
      backgroundColor: DTokens.bgDark,
      appBar: AppBar(
        backgroundColor: DTokens.bgDark,
        elevation: 0,
        title: Text('알림', style: DType.heading(17, color: Colors.white)),
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllRead,
              child: Text(
                '모두 읽음',
                style: DType.label(12,
                    color: team.primary.withValues(alpha: 0.85)),
              ),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: _NotiTabBar(
            controller: _tab,
            team: team,
            unreadCount: _unreadCount,
          ),
        ),
      ),
      body: list.isEmpty
          ? _EmptyState(isUnreadTab: _tab.index == 1)
          : ListView.separated(
              padding: EdgeInsets.fromLTRB(
                DTokens.s16,
                DTokens.s12,
                DTokens.s16,
                MediaQuery.of(context).padding.bottom + DTokens.s24,
              ),
              itemCount: list.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: DTokens.s8),
              itemBuilder: (context, i) => _NotiCard(
                noti: list[i],
                onTap: () => _markRead(list[i].id),
              )
                  .animate()
                  .fadeIn(delay: Duration(milliseconds: 36 * i))
                  .slideY(begin: 0.04),
            ),
    );
  }
}

// ── tab bar ───────────────────────────────────────────────────────────────────

class _NotiTabBar extends StatelessWidget {
  final TabController controller;
  final dynamic team;
  final int unreadCount;
  const _NotiTabBar(
      {required this.controller,
      required this.team,
      required this.unreadCount});

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: controller,
      indicatorColor: team.primary as Color,
      indicatorWeight: 2,
      labelColor: team.primary as Color,
      unselectedLabelColor: DTokens.textTertiaryDark,
      labelStyle: DType.label(13),
      unselectedLabelStyle: DType.label(13),
      tabs: [
        const Tab(text: '전체'),
        Tab(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('읽지 않음', style: DType.label(13)),
              if (unreadCount > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: team.primary as Color,
                    borderRadius:
                        BorderRadius.circular(DTokens.rPill),
                  ),
                  child: Text(
                    '$unreadCount',
                    style: DType.label(10, color: Colors.white),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ── noti card ─────────────────────────────────────────────────────────────────

class _NotiCard extends StatelessWidget {
  final _Noti noti;
  final VoidCallback onTap;
  const _NotiCard({required this.noti, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = noti.type.color;

    return GestureDetector(
      onTap: onTap,
      child: DGlassPanel(
        padding: const EdgeInsets.all(DTokens.s16),
        radius: DTokens.r16,
        opacity: noti.read ? 0.32 : 0.52,
        teamBorder: !noti.read,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 아이콘
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                      color.withValues(alpha: noti.read ? 0.18 : 0.42),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Image.asset(
                  noti.type.assetPath,
                  errorBuilder: (e, s, t) =>
                      Icon(noti.type.icon, size: 18, color: color),
                ),
              ),
            ),

            const SizedBox(width: DTokens.s12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 카테고리 + 시간 + 읽음 dot
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius:
                              BorderRadius.circular(DTokens.r4),
                        ),
                        child: Text(
                          noti.type.label,
                          style: DType.label(10, color: color),
                        ),
                      ),
                      const SizedBox(width: DTokens.s8),
                      Expanded(
                        child: Text(
                          noti.time,
                          style: DType.mono(10,
                              color: DTokens.textTertiaryDark,
                              weight: FontWeight.w400),
                        ),
                      ),
                      if (!noti.read)
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: color.withValues(alpha: 0.6),
                                blurRadius: 5,
                              ),
                            ],
                          ),
                        )
                            .animate(
                                onPlay: (c) => c.repeat(reverse: true))
                            .fade(
                                begin: 0.45,
                                end: 1.0,
                                duration: 900.ms),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // 제목
                  Text(
                    noti.title,
                    style: DType.body(14, FontWeight.w700).copyWith(
                      color: noti.read
                          ? DTokens.textSecondaryDark
                          : DTokens.textPrimaryDark,
                    ),
                  ),

                  const SizedBox(height: DTokens.s4),

                  // 본문
                  Text(
                    noti.body,
                    style: DType.body(13).copyWith(
                      color: DTokens.textSecondaryDark,
                      height: 1.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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

// ── empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final bool isUnreadTab;
  const _EmptyState({required this.isUnreadTab});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isUnreadTab
                ? Icons.mark_email_read_rounded
                : Icons.notifications_off_outlined,
            size: 64,
            color: DTokens.textTertiaryDark,
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(0.95, 0.95),
                end: const Offset(1.05, 1.05),
                duration: 2000.ms,
              ),
          const SizedBox(height: DTokens.s16),
          Text(
            isUnreadTab ? '읽지 않은 알림이 없습니다' : '알림이 없습니다',
            style: DType.heading(16, color: DTokens.textSecondaryDark),
          ),
          const SizedBox(height: DTokens.s8),
          Text(
            isUnreadTab
                ? '모든 알림을 확인하셨습니다'
                : '새로운 알림이 도착하면 여기에 표시됩니다',
            style: DType.body(14)
                .copyWith(color: DTokens.textTertiaryDark),
          ),
        ],
      ),
    );
  }
}
