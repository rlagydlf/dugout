import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme/app_theme.dart';
import '../../app/theme/tokens.dart';
import '../../app/theme/typography.dart';

/// 더그아웃 하단 플로팅 네비게이션 바 — 5탭 + 가운데 큰 출정 FAB.
class DBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onSortie;

  const DBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onSortie,
  });

  @override
  Widget build(BuildContext context) {
    final team = context.team;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            DTokens.s12, DTokens.s4, DTokens.s12, DTokens.s8),
        child: Container(
          height: 68,
          decoration: BoxDecoration(
            color: const Color(0xFF14171F),
            borderRadius: BorderRadius.circular(DTokens.r24),
            border: Border.all(color: DTokens.borderDark),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: team.primary.withValues(alpha: 0.18),
                blurRadius: 32,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: _NavTab(
                  icon: Icons.home_rounded,
                  label: '홈',
                  active: currentIndex == 0,
                  accent: team.primary,
                  onTap: () => onTap(0),
                ),
              ),
              Expanded(
                child: _NavTab(
                  icon: Icons.flag_rounded,
                  label: '퀘스트',
                  active: currentIndex == 1,
                  accent: team.primary,
                  onTap: () => onTap(1),
                ),
              ),
              SizedBox(
                width: 76,
                child: _SortieFab(
                  accent: team.primary,
                  secondary: team.secondary,
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    onSortie();
                  },
                ),
              ),
              Expanded(
                child: _NavTab(
                  icon: Icons.card_giftcard_rounded,
                  label: '리워드',
                  active: currentIndex == 2,
                  accent: team.primary,
                  onTap: () => onTap(2),
                ),
              ),
              Expanded(
                child: _NavTab(
                  icon: Icons.badge_rounded,
                  label: '팬카드',
                  active: currentIndex == 3,
                  accent: team.primary,
                  onTap: () => onTap(3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final Color accent;
  final VoidCallback onTap;

  const _NavTab({
    required this.icon,
    required this.label,
    required this.active,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: active ? accent.withValues(alpha: 0.16) : Colors.transparent,
          borderRadius: BorderRadius.circular(DTokens.r16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 22,
              color: active ? accent : DTokens.textSecondaryDark,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: DType.label(
                10,
                color: active ? accent : DTokens.textTertiaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SortieFab extends StatelessWidget {
  final Color accent;
  final Color secondary;
  final VoidCallback onTap;

  const _SortieFab({
    required this.accent,
    required this.secondary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Center(
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [accent, secondary],
            ),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.55),
                blurRadius: 20,
                spreadRadius: 1,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.bolt_rounded, size: 24, color: Colors.white),
              Text(
                '출정',
                style: DType.label(9, color: Colors.white, weight: FontWeight.w900),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
