import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'team_theme.dart';
import 'tokens.dart';

/// 팀 테마와 다크 모드 여부를 받아 [ThemeData]를 만든다.
class AppTheme {
  AppTheme._();

  static ThemeData build(TeamTheme team, {bool dark = true}) {
    final base = dark ? ThemeData.dark() : ThemeData.light();
    final scheme = ColorScheme.fromSeed(
      seedColor: team.primary,
      brightness: dark ? Brightness.dark : Brightness.light,
    ).copyWith(
      primary: team.primary,
      secondary: team.secondary,
      tertiary: team.accent,
      surface: dark ? DTokens.surfaceDark : DTokens.surfaceLight,
    );

    final base16 = GoogleFonts.notoSansKr(
      textStyle: const TextStyle(fontSize: 15, height: 1.45),
    );

    final textTheme = GoogleFonts.notoSansKrTextTheme(base.textTheme).apply(
      bodyColor: dark ? DTokens.textPrimaryDark : DTokens.textPrimaryLight,
      displayColor: dark ? DTokens.textPrimaryDark : DTokens.textPrimaryLight,
    );

    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: dark ? DTokens.bgDark : DTokens.bgLight,
      canvasColor: dark ? DTokens.bgDark : DTokens.bgLight,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: dark ? DTokens.bgDark : DTokens.bgLight,
        foregroundColor:
            dark ? DTokens.textPrimaryDark : DTokens.textPrimaryLight,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: base16.copyWith(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: dark ? DTokens.textPrimaryDark : DTokens.textPrimaryLight,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(0, 52),
          backgroundColor: team.primary,
          foregroundColor: team.accent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DTokens.r16),
          ),
          textStyle: base16.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 52),
          foregroundColor: team.primary,
          side: BorderSide(color: team.primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DTokens.r16),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? DTokens.surfaceDark : DTokens.surfaceLight,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: DTokens.s16,
          vertical: DTokens.s16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DTokens.r12),
          borderSide: BorderSide(
            color: dark ? DTokens.borderDark : DTokens.borderLight,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DTokens.r12),
          borderSide: BorderSide(
            color: dark ? DTokens.borderDark : DTokens.borderLight,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DTokens.r12),
          borderSide: BorderSide(color: team.primary, width: 1.5),
        ),
      ),
      cardTheme: CardThemeData(
        color: dark ? DTokens.surfaceDark : DTokens.surfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DTokens.r16),
          side: BorderSide(
            color: dark ? DTokens.borderDark : DTokens.borderLight,
          ),
        ),
      ),
      extensions: [team],
    );
  }
}

extension TeamThemeContextX on BuildContext {
  TeamTheme get team =>
      Theme.of(this).extension<TeamTheme>() ?? TeamTheme.defaultTheme;

  ColorScheme get scheme => Theme.of(this).colorScheme;

  TextTheme get text => Theme.of(this).textTheme;
}
