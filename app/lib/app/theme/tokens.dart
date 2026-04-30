import 'package:flutter/material.dart';

/// 디자인 토큰 — 앱 전체 spacing, radius, typography, base palette.
class DTokens {
  DTokens._();

  // ── Spacing (8pt grid)
  static const double s2 = 2;
  static const double s4 = 4;
  static const double s8 = 8;
  static const double s12 = 12;
  static const double s14 = 14;
  static const double s16 = 16;
  static const double s20 = 20;
  static const double s24 = 24;
  static const double s28 = 28;
  static const double s32 = 32;
  static const double s40 = 40;
  static const double s48 = 48;
  static const double s64 = 64;
  static const double s96 = 96;

  // ── Radius
  static const double r4 = 4;
  static const double r8 = 8;
  static const double r12 = 12;
  static const double r16 = 16;
  static const double r20 = 20;
  static const double r24 = 24;
  static const double r32 = 32;
  static const double rPill = 999;

  // ── Base Palette (다크/라이트 공통 base, 팀 컬러 위에 깔린다)
  static const Color bgDark = Color(0xFF0B0D12);
  static const Color surfaceDark = Color(0xFF14171F);
  static const Color surfaceDark2 = Color(0xFF1C2029);
  static const Color borderDark = Color(0xFF2A2F3A);

  static const Color bgLight = Color(0xFFFAFAFA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFE5E5EA);

  static const Color textPrimaryDark = Color(0xFFF5F6F8);
  static const Color textSecondaryDark = Color(0xFFA8ADBA);
  static const Color textTertiaryDark = Color(0xFF6B7280);

  static const Color textPrimaryLight = Color(0xFF0B0D12);
  static const Color textSecondaryLight = Color(0xFF505666);
  static const Color textTertiaryLight = Color(0xFF8A8F9C);

  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // ── Elevation 그림자 시스템 (다크 UI용)
  static const List<BoxShadow> elev1 = [
    BoxShadow(
      color: Color(0x33000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];
  static const List<BoxShadow> elev2 = [
    BoxShadow(
      color: Color(0x4D000000),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];
  static const List<BoxShadow> elev3 = [
    BoxShadow(
      color: Color(0x66000000),
      blurRadius: 32,
      offset: Offset(0, 8),
    ),
  ];

  // ── 블러 강도
  static const double blurSm = 8;
  static const double blurMd = 20;
  static const double blurLg = 40;
}

/// 타이포그래피 (LEGACY - typography.dart의 DType 사용 권장)
class DTypeOld {
  DTypeOld._();

  static TextStyle display = const TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w800,
    height: 1.05,
    letterSpacing: -1,
  );
  static TextStyle h1 = const TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    height: 1.15,
    letterSpacing: -0.5,
  );
  static TextStyle h2 = const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );
  static TextStyle h3 = const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );
  static TextStyle title = const TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    height: 1.35,
  );
  static TextStyle body = const TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.45,
  );
  static TextStyle caption = const TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );
  static TextStyle micro = const TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: 0.4,
  );
  static TextStyle stencil = const TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w900,
    height: 1.0,
    letterSpacing: 1.5,
  );

  /// 영문 임팩트 (Bebas Neue 호환 산세리프, 야구 스코어보드 느낌)
  static TextStyle impact = const TextStyle(
    fontSize: 56,
    fontWeight: FontWeight.w900,
    height: 0.95,
    letterSpacing: 4,
    fontFamilyFallback: ['Impact', 'Anton', 'BebasNeue'],
  );
  static TextStyle scoreboard = const TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w900,
    height: 1.0,
    letterSpacing: 2,
    fontFamilyFallback: ['Courier', 'monospace'],
  );
}
