import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 더그아웃 v2 타이포그래피 시스템.
///
/// 한글 = **Pretendard** (assets/fonts/Pretendard-{Regular..Black}.otf)
/// 영문 액센트만:
///   - Anton (impact display, 영문/숫자만)
///   - Black Ops One (badge, 영문/숫자만)
///
/// 다른 영문 폰트(VT323/JetBrains/Major Mono)는 한글 깨짐 방지를 위해 제거됨.
/// 한글이 들어갈 수 있는 모든 텍스트는 무조건 Pretendard 헬퍼 사용.
class DType {
  DType._();

  static const String family = 'Pretendard';

  /// 본문 — Pretendard
  static TextStyle body([double size = 16, FontWeight weight = FontWeight.w400]) =>
      TextStyle(
        fontFamily: family,
        fontSize: size,
        fontWeight: weight,
        height: 1.5,
        letterSpacing: -0.2,
      );

  /// 헤딩 — Pretendard heavy
  static TextStyle heading(
    double size, {
    Color? color,
    FontWeight weight = FontWeight.w900,
    double height = 1.2,
  }) =>
      TextStyle(
        fontFamily: family,
        fontSize: size,
        fontWeight: weight,
        height: height,
        letterSpacing: -0.5,
        color: color,
      );

  /// 라벨 (작은 캡션, all-caps) — Pretendard
  static TextStyle label(
    double size, {
    Color? color,
    FontWeight weight = FontWeight.w700,
    double letterSpacing = 1.0,
  }) =>
      TextStyle(
        fontFamily: family,
        fontSize: size,
        fontWeight: weight,
        letterSpacing: letterSpacing,
        color: color,
        height: 1.2,
      );

  /// 캡션 (보조 텍스트) — Pretendard
  static TextStyle caption(double size, {Color? color, FontWeight weight = FontWeight.w400}) =>
      TextStyle(
        fontFamily: family,
        fontSize: size,
        fontWeight: weight,
        height: 1.4,
        color: color,
      );

  /// 모노 카운터 (포인트, 카드번호 등) — Pretendard tabular numerals
  static TextStyle mono(double size, {Color? color, FontWeight weight = FontWeight.w700}) =>
      TextStyle(
        fontFamily: family,
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: 0.5,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  /// 영문 임팩트 — Anton (영문/숫자 ONLY, 한글 들어가면 안 됨)
  static TextStyle impact(double size, {Color? color, double letterSpacing = 1.5}) =>
      GoogleFonts.anton(
        textStyle: TextStyle(
          fontSize: size,
          fontWeight: FontWeight.w400,
          height: 1.0,
          letterSpacing: letterSpacing,
          color: color ?? Colors.white,
          fontFamilyFallback: const [family],
        ),
      );

  /// 영문 배지 — Black Ops One (영문/숫자 ONLY)
  static TextStyle badge(double size, {Color? color}) =>
      GoogleFonts.blackOpsOne(
        textStyle: TextStyle(
          fontSize: size,
          fontWeight: FontWeight.w400,
          letterSpacing: 1.2,
          color: color,
          fontFamilyFallback: const [family],
        ),
      );

  /// 스코어보드 디지털 (LED 점수 표시) — Pretendard Black + tabular nums
  static TextStyle scoreboardDigital(double size, {Color? color}) =>
      TextStyle(
        fontFamily: family,
        fontSize: size,
        fontWeight: FontWeight.w900,
        color: color,
        letterSpacing: 1,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  /// 마이크로 (주의사항/저작권) — Pretendard light
  static TextStyle micro(double size, {Color? color}) =>
      TextStyle(
        fontFamily: family,
        fontSize: size,
        color: color,
        height: 1.4,
        letterSpacing: 0.3,
      );
}
