import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_theme.dart';
import '../../app/theme/tokens.dart';
import '../../app/theme/typography.dart';
import '../../shared/widgets/d_glass_panel.dart';

// ── state ─────────────────────────────────────────────────────────────────────

class _NotiSettings {
  final bool pushEnabled;
  final bool inAppEnabled;
  final bool emailEnabled;
  final bool sortieReminder;
  final bool predictionDeadline;
  final bool settlement;
  final bool reward;
  const _NotiSettings({
    this.pushEnabled = true,
    this.inAppEnabled = true,
    this.emailEnabled = false,
    this.sortieReminder = true,
    this.predictionDeadline = true,
    this.settlement = true,
    this.reward = true,
  });
  _NotiSettings copyWith({
    bool? pushEnabled,
    bool? inAppEnabled,
    bool? emailEnabled,
    bool? sortieReminder,
    bool? predictionDeadline,
    bool? settlement,
    bool? reward,
  }) =>
      _NotiSettings(
        pushEnabled: pushEnabled ?? this.pushEnabled,
        inAppEnabled: inAppEnabled ?? this.inAppEnabled,
        emailEnabled: emailEnabled ?? this.emailEnabled,
        sortieReminder: sortieReminder ?? this.sortieReminder,
        predictionDeadline: predictionDeadline ?? this.predictionDeadline,
        settlement: settlement ?? this.settlement,
        reward: reward ?? this.reward,
      );
}

// ── Screen ────────────────────────────────────────────────────────────────────

class NotificationsSettingsScreen extends ConsumerStatefulWidget {
  const NotificationsSettingsScreen({super.key});
  @override
  ConsumerState<NotificationsSettingsScreen> createState() => _State();
}

class _State extends ConsumerState<NotificationsSettingsScreen> {
  var _s = const _NotiSettings();

  @override
  Widget build(BuildContext context) {
    final team = context.team;

    return Scaffold(
      backgroundColor: DTokens.bgDark,
      appBar: AppBar(
        backgroundColor: DTokens.bgDark,
        elevation: 0,
        title: Text('알림 수신 설정',
            style: DType.heading(17, color: Colors.white)),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          DTokens.s16,
          DTokens.s8,
          DTokens.s16,
          MediaQuery.of(context).padding.bottom + DTokens.s24,
        ),
        children: [
          // ── 채널 섹션
          _SectionHeader(
            icon: Icons.cell_tower_rounded,
            label: '알림 채널',
            color: team.primary,
          ).animate().fadeIn(),

          const SizedBox(height: DTokens.s8),

          DGlassPanel(
            padding: EdgeInsets.zero,
            radius: DTokens.r20,
            child: Column(
              children: [
                _ToggleTile(
                  icon: Icons.notifications_active_rounded,
                  color: team.primary,
                  title: '푸시 알림',
                  subtitle: '기기 잠금화면 및 홈 알림',
                  value: _s.pushEnabled,
                  onChanged: (v) =>
                      setState(() => _s = _s.copyWith(pushEnabled: v)),
                  isFirst: true,
                ),
                const Divider(
                    color: DTokens.borderDark, height: 1, indent: 68),
                _ToggleTile(
                  icon: Icons.mark_chat_unread_rounded,
                  color: DTokens.info,
                  title: '인앱 알림',
                  subtitle: '앱 실행 중 배너 알림',
                  value: _s.inAppEnabled,
                  onChanged: (v) =>
                      setState(() => _s = _s.copyWith(inAppEnabled: v)),
                ),
                const Divider(
                    color: DTokens.borderDark, height: 1, indent: 68),
                _ToggleTile(
                  icon: Icons.email_rounded,
                  color: DTokens.warning,
                  title: '이메일 알림',
                  subtitle: '주요 소식을 이메일로 수신',
                  value: _s.emailEnabled,
                  onChanged: (v) =>
                      setState(() => _s = _s.copyWith(emailEnabled: v)),
                  isLast: true,
                ),
              ],
            ),
          ).animate().fadeIn(delay: 60.ms),

          const SizedBox(height: DTokens.s20),

          // ── 유형 섹션
          _SectionHeader(
            icon: Icons.tune_rounded,
            label: '알림 유형',
            color: team.primary,
          ).animate().fadeIn(delay: 80.ms),

          const SizedBox(height: DTokens.s8),

          DGlassPanel(
            padding: EdgeInsets.zero,
            radius: DTokens.r20,
            child: Column(
              children: [
                _ToggleTile(
                  icon: Icons.rocket_launch_rounded,
                  color: DTokens.info,
                  title: '출정 리마인더',
                  subtitle: '경기 시작 1시간 전 알림',
                  value: _s.sortieReminder,
                  onChanged: (v) =>
                      setState(() => _s = _s.copyWith(sortieReminder: v)),
                  isFirst: true,
                ),
                const Divider(
                    color: DTokens.borderDark, height: 1, indent: 68),
                _ToggleTile(
                  icon: Icons.psychology_rounded,
                  color: DTokens.warning,
                  title: '예측 마감 알림',
                  subtitle: '예측 마감 30분 전 알림',
                  value: _s.predictionDeadline,
                  onChanged: (v) => setState(
                      () => _s = _s.copyWith(predictionDeadline: v)),
                ),
                const Divider(
                    color: DTokens.borderDark, height: 1, indent: 68),
                _ToggleTile(
                  icon: Icons.account_balance_wallet_rounded,
                  color: DTokens.success,
                  title: '정산 알림',
                  subtitle: '포인트 적립·차감 내역 알림',
                  value: _s.settlement,
                  onChanged: (v) =>
                      setState(() => _s = _s.copyWith(settlement: v)),
                ),
                const Divider(
                    color: DTokens.borderDark, height: 1, indent: 68),
                _ToggleTile(
                  icon: Icons.card_giftcard_rounded,
                  color: const Color(0xFF9B6DFF),
                  title: '리워드 알림',
                  subtitle: '쿠폰 발급·만료 알림',
                  value: _s.reward,
                  onChanged: (v) =>
                      setState(() => _s = _s.copyWith(reward: v)),
                  isLast: true,
                ),
              ],
            ),
          ).animate().fadeIn(delay: 120.ms),

          const SizedBox(height: DTokens.s16),

          // ── 안내
          Container(
            padding: const EdgeInsets.all(DTokens.s14),
            decoration: BoxDecoration(
              color: DTokens.surfaceDark2,
              borderRadius: BorderRadius.circular(DTokens.r12),
              border: Border.all(color: DTokens.borderDark),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    size: 14, color: DTokens.textTertiaryDark),
                const SizedBox(width: DTokens.s8),
                Expanded(
                  child: Text(
                    '기기 설정 > 더그아웃에서 알림 허용 시 푸시 알림을 받을 수 있습니다.',
                    style: DType.caption(12,
                            color: DTokens.textTertiaryDark)
                        .copyWith(height: 1.5),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 160.ms),
        ],
      ),
    );
  }
}

// ── 공통 위젯 ─────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _SectionHeader(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: DTokens.s8),
        Text(
          label,
          style: DType.label(13,
              color: DTokens.textSecondaryDark, letterSpacing: 0.5),
        ),
      ],
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isFirst;
  final bool isLast;

  const _ToggleTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final team = context.team;
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: DTokens.s16, vertical: DTokens.s12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(DTokens.r8),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: DTokens.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: DType.body(14, FontWeight.w600)
                        .copyWith(color: DTokens.textPrimaryDark)),
                Text(subtitle,
                    style: DType.caption(12,
                        color: DTokens.textTertiaryDark)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: team.primary,
            activeThumbColor: Colors.white,
          ),
        ],
      ),
    );
  }
}
