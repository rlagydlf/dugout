import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 더그아웃 타이포그래피 시스템 v2.
/// - 한글: Noto Sans KR (Pretendard 호환 모던 산세리프)
/// - 영문 임팩트: Anton (Bebas Neue 호환, 야구 스코어보드용)
/// - 스코어보드 디지털: VT323 (CRT LED), Black Ops One (배지)
/// - 모노스페이스 카운트: JetBrains Mono / Major Mono Display
///
/// 모든 영문 폰트 헬퍼에 한글 fallback (Noto Sans KR) 명시 →
/// 한글 텍스트가 영문 폰트로 호출되어도 깨지지 않음.
class DType {
  DType._();

  // 한글 fallback 체인
  static const _krFallback = ['NotoSansKR', 'Apple SD Gothic Neo', 'Noto Sans CJK KR'];

  /// 한글 본문 — 기본 산세리프
  static TextStyle body([double size = 16, FontWeight weight = FontWeight.w400]) =>
      GoogleFonts.notoSansKr(
        textStyle: TextStyle(
          fontSize: size,
          fontWeight: weight,
          height: 1.5,
          letterSpacing: -0.2,
        ),
      );

  /// 한글 헤딩 (heavy)
  static TextStyle heading(double size, {Color? color, FontWeight weight = FontWeight.w900}) =>
      GoogleFonts.notoSansKr(
        textStyle: TextStyle(
          fontSize: size,
          fontWeight: weight,
          height: 1.2,
          letterSpacing: -0.5,
          color: color,
        ),
      );

  /// 영문 임팩트 — 스타디움 LED, 큰 매치업 텍스트
  static TextStyle impact(double size, {Color? color, double letterSpacing = 1.5}) =>
      GoogleFonts.anton(
        textStyle: TextStyle(
          fontSize: size,
          fontWeight: FontWeight.w400,
          height: 1.0,
          letterSpacing: letterSpacing,
          color: color ?? Colors.white,
          fontFamilyFallback: _krFallback,
        ),
      );

  /// 영문 라벨 (작은 캡션, all caps)
  static TextStyle label(double size, {Color? color, FontWeight weight = FontWeight.w700}) =>
      GoogleFonts.notoSansKr(
        textStyle: TextStyle(
          fontSize: size,
          fontWeight: weight,
          letterSpacing: 1.2,
          color: color,
          height: 1.2,
        ),
      );

  /// 디지털 스코어보드 (점수 표시) — VT323 (LED 픽셀 느낌)
  static TextStyle scoreboardDigital(double size, {Color? color}) =>
      GoogleFonts.vt323(
        textStyle: TextStyle(
          fontSize: size,
          fontWeight: FontWeight.w400,
          letterSpacing: 1,
          color: color,
          fontFamilyFallback: _krFallback,
        ),
      );

  /// 모노 카운터 (포인트, 시간 등) — JetBrains Mono
  static TextStyle mono(double size, {Color? color, FontWeight weight = FontWeight.w700}) =>
      GoogleFonts.jetBrainsMono(
        textStyle: TextStyle(
          fontSize: size,
          fontWeight: weight,
          color: color,
          letterSpacing: 0,
          fontFamilyFallback: _krFallback,
        ),
      );

  /// 배지 / 강조 — Black Ops One
  static TextStyle badge(double size, {Color? color}) =>
      GoogleFonts.blackOpsOne(
        textStyle: TextStyle(
          fontSize: size,
          fontWeight: FontWeight.w400,
          letterSpacing: 1.2,
          color: color,
          fontFamilyFallback: _krFallback,
        ),
      );

  /// 픽셀 모노 (작은 라벨) — Major Mono Display
  static TextStyle micro(double size, {Color? color}) =>
      GoogleFonts.majorMonoDisplay(
        textStyle: TextStyle(
          fontSize: size,
          color: color,
          letterSpacing: 0.5,
          fontFamilyFallback: _krFallback,
        ),
      );
}

/// 헬퍼 — 화면별로 호출되는 사이즈 값을 키워주는 multiplier.
/// 기존 호출 (DType.body(13)) 그대로 두고 컴포넌트가 큰 사이즈 원할 때만.
extension DTypeScaleExt on TextStyle {
  TextStyle scale(double mul) => copyWith(fontSize: (fontSize ?? 14) * mul);
}
