import 'package:flutter/services.dart';

/// 햅틱 피드백 헬퍼 — 일관된 트리거 강도.
class DHaptics {
  DHaptics._();

  /// 가벼운 탭 (탭 / 칩 선택)
  static void light() => HapticFeedback.lightImpact();

  /// 중간 탭 (CTA / 토글 / 카드 선택)
  static void medium() => HapticFeedback.mediumImpact();

  /// 강한 탭 (출정 / 예측 제출 / 리워드 교환 / 회원탈퇴)
  static void heavy() => HapticFeedback.heavyImpact();

  /// 선택 (스크롤 도달 / 페이지 전환)
  static void selection() => HapticFeedback.selectionClick();

  /// 진동 (오류 / 차단)
  static void vibrate() => HapticFeedback.vibrate();
}
