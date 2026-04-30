import 'package:flutter/material.dart';

/// 응원팀별 동적 테마 정보를 담는 [ThemeExtension].
/// 팀이 바뀔 때 [MaterialApp.theme] 의 extension을 갈아끼우면 앱 전체가 재구성된다.
class TeamTheme extends ThemeExtension<TeamTheme> {
  final String teamId;
  final String teamName;
  final String teamShortName;
  final String stadium;
  final String slogan;
  final Color primary;
  final Color secondary;
  final Color accent;
  final String crestAsset;
  final String backgroundAsset;
  final String mascotAsset;
  final String patternAsset;
  final String moodAsset;
  final String tagline; // 한 줄 정체성

  const TeamTheme({
    required this.teamId,
    required this.teamName,
    required this.teamShortName,
    required this.stadium,
    required this.slogan,
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.crestAsset,
    required this.backgroundAsset,
    this.mascotAsset = 'assets/images/logo.png',
    this.patternAsset = 'assets/images/logo.png',
    this.moodAsset = 'assets/images/backgrounds/stadium_default.png',
    this.tagline = '',
  });

  @override
  TeamTheme copyWith({
    String? teamId,
    String? teamName,
    String? teamShortName,
    String? stadium,
    String? slogan,
    Color? primary,
    Color? secondary,
    Color? accent,
    String? crestAsset,
    String? backgroundAsset,
    String? mascotAsset,
    String? patternAsset,
    String? moodAsset,
    String? tagline,
  }) {
    return TeamTheme(
      teamId: teamId ?? this.teamId,
      teamName: teamName ?? this.teamName,
      teamShortName: teamShortName ?? this.teamShortName,
      stadium: stadium ?? this.stadium,
      slogan: slogan ?? this.slogan,
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      accent: accent ?? this.accent,
      crestAsset: crestAsset ?? this.crestAsset,
      backgroundAsset: backgroundAsset ?? this.backgroundAsset,
      mascotAsset: mascotAsset ?? this.mascotAsset,
      patternAsset: patternAsset ?? this.patternAsset,
      moodAsset: moodAsset ?? this.moodAsset,
      tagline: tagline ?? this.tagline,
    );
  }

  @override
  TeamTheme lerp(ThemeExtension<TeamTheme>? other, double t) {
    if (other is! TeamTheme) return this;
    return TeamTheme(
      teamId: t < 0.5 ? teamId : other.teamId,
      teamName: t < 0.5 ? teamName : other.teamName,
      teamShortName: t < 0.5 ? teamShortName : other.teamShortName,
      stadium: t < 0.5 ? stadium : other.stadium,
      slogan: t < 0.5 ? slogan : other.slogan,
      primary: Color.lerp(primary, other.primary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      crestAsset: t < 0.5 ? crestAsset : other.crestAsset,
      backgroundAsset: t < 0.5 ? backgroundAsset : other.backgroundAsset,
    );
  }

  /// 그라디언트(헤더 등에 활용)
  LinearGradient get gradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [primary, secondary],
      );

  /// 응원팀 액센트 글로우(스플래시·CTA 강조용)
  RadialGradient get glow => RadialGradient(
        colors: [primary.withValues(alpha: 0.55), Colors.transparent],
        stops: const [0.0, 1.0],
      );

  /// 디폴트(미선택) 테마
  static const TeamTheme defaultTheme = TeamTheme(
    teamId: 'default',
    teamName: '더그아웃',
    teamShortName: 'DUGOUT',
    stadium: '',
    slogan: '응원 그 이상의 행동',
    primary: Color(0xFFFF7A1A),
    secondary: Color(0xFF1A1F2C),
    accent: Color(0xFFFFFFFF),
    crestAsset: 'assets/images/logo.png',
    backgroundAsset: 'assets/images/backgrounds/home_default.png',
  );
}

/// 팀 ID → TeamTheme 매핑 (teams.json 데이터를 기반으로 빌드).
class TeamThemes {
  TeamThemes._();

  static const Map<String, TeamTheme> _themes = {
    'lg': TeamTheme(
      teamId: 'lg',
      teamName: 'LG 트윈스',
      teamShortName: 'LG',
      stadium: '잠실야구장',
      slogan: 'We are LG TWINS',
      primary: Color(0xFFC30452),
      secondary: Color(0xFF000000),
      accent: Color(0xFFC0C0C0),
      crestAsset: 'assets/images/teams/lg.png',
      backgroundAsset: 'assets/images/backgrounds/home_lg.png',
      mascotAsset: 'assets/images/mascots/lg.png',
      patternAsset: 'assets/images/patterns/lg.png',
      moodAsset: 'assets/images/moods/lg.png',
      tagline: '잠실의 함성, 트윈스의 자존심',
    ),
    'doosan': TeamTheme(
      teamId: 'doosan',
      teamName: '두산 베어스',
      teamShortName: '두산',
      stadium: '잠실야구장',
      slogan: 'We are the BEARS',
      primary: Color(0xFF131230),
      secondary: Color(0xFFED1C24),
      accent: Color(0xFFFFFFFF),
      crestAsset: 'assets/images/teams/doosan.png',
      backgroundAsset: 'assets/images/backgrounds/home_doosan.png',
      mascotAsset: 'assets/images/mascots/doosan.png',
      patternAsset: 'assets/images/patterns/doosan.png',
      moodAsset: 'assets/images/moods/doosan.png',
      tagline: '잠실의 야성, 베어스의 끈기',
    ),
    'kiwoom': TeamTheme(
      teamId: 'kiwoom',
      teamName: '키움 히어로즈',
      teamShortName: '키움',
      stadium: '고척스카이돔',
      slogan: 'Be the HEROES',
      primary: Color(0xFF570514),
      secondary: Color(0xFFFFFFFF),
      accent: Color(0xFFB5985A),
      crestAsset: 'assets/images/teams/kiwoom.png',
      backgroundAsset: 'assets/images/backgrounds/home_kiwoom.png',
      mascotAsset: 'assets/images/mascots/kiwoom.png',
      patternAsset: 'assets/images/patterns/kiwoom.png',
      moodAsset: 'assets/images/moods/kiwoom.png',
      tagline: '고척의 영웅, 우리의 미래',
    ),
    'ssg': TeamTheme(
      teamId: 'ssg',
      teamName: 'SSG 랜더스',
      teamShortName: 'SSG',
      stadium: '인천SSG랜더스필드',
      slogan: 'WE ARE SSG',
      primary: Color(0xFFCE0E2D),
      secondary: Color(0xFFFFB81C),
      accent: Color(0xFF000000),
      crestAsset: 'assets/images/teams/ssg.png',
      backgroundAsset: 'assets/images/backgrounds/home_ssg.png',
      mascotAsset: 'assets/images/mascots/ssg.png',
      patternAsset: 'assets/images/patterns/ssg.png',
      moodAsset: 'assets/images/moods/ssg.png',
      tagline: '인천 바다의 번개, 랜더스의 기세',
    ),
    'kia': TeamTheme(
      teamId: 'kia',
      teamName: 'KIA 타이거즈',
      teamShortName: 'KIA',
      stadium: '광주-기아 챔피언스 필드',
      slogan: 'Tigers Forever',
      primary: Color(0xFFEA0029),
      secondary: Color(0xFF06141F),
      accent: Color(0xFFFFFFFF),
      crestAsset: 'assets/images/teams/kia.png',
      backgroundAsset: 'assets/images/backgrounds/home_kia.png',
      mascotAsset: 'assets/images/mascots/kia.png',
      patternAsset: 'assets/images/patterns/kia.png',
      moodAsset: 'assets/images/moods/kia.png',
      tagline: '광주를 흔드는 호랑이의 포효',
    ),
    'nc': TeamTheme(
      teamId: 'nc',
      teamName: 'NC 다이노스',
      teamShortName: 'NC',
      stadium: '창원NC파크',
      slogan: 'Roar of NC',
      primary: Color(0xFF315288),
      secondary: Color(0xFF9F8053),
      accent: Color(0xFFFFFFFF),
      crestAsset: 'assets/images/teams/nc.png',
      backgroundAsset: 'assets/images/backgrounds/home_nc.png',
      mascotAsset: 'assets/images/mascots/nc.png',
      patternAsset: 'assets/images/patterns/nc.png',
      moodAsset: 'assets/images/moods/nc.png',
      tagline: '창원의 미래, 다이노스의 진화',
    ),
    'kt': TeamTheme(
      teamId: 'kt',
      teamName: 'KT 위즈',
      teamShortName: 'KT',
      stadium: '수원KT위즈파크',
      slogan: 'Real Magic',
      primary: Color(0xFF000000),
      secondary: Color(0xFFEB1C24),
      accent: Color(0xFFFFFFFF),
      crestAsset: 'assets/images/teams/kt.png',
      backgroundAsset: 'assets/images/backgrounds/home_kt.png',
      mascotAsset: 'assets/images/mascots/kt.png',
      patternAsset: 'assets/images/patterns/kt.png',
      moodAsset: 'assets/images/moods/kt.png',
      tagline: '수원의 마법, 위즈의 역전',
    ),
    'samsung': TeamTheme(
      teamId: 'samsung',
      teamName: '삼성 라이온즈',
      teamShortName: '삼성',
      stadium: '대구삼성라이온즈파크',
      slogan: 'PRIDE OF DAEGU',
      primary: Color(0xFF0066B3),
      secondary: Color(0xFFC0C0C0),
      accent: Color(0xFFFFFFFF),
      crestAsset: 'assets/images/teams/samsung.png',
      backgroundAsset: 'assets/images/backgrounds/home_samsung.png',
      mascotAsset: 'assets/images/mascots/samsung.png',
      patternAsset: 'assets/images/patterns/samsung.png',
      moodAsset: 'assets/images/moods/samsung.png',
      tagline: '대구의 자존심, 푸른 사자의 위엄',
    ),
    'lotte': TeamTheme(
      teamId: 'lotte',
      teamName: '롯데 자이언츠',
      teamShortName: '롯데',
      stadium: '사직야구장',
      slogan: 'Forever Lotte',
      primary: Color(0xFF041E42),
      secondary: Color(0xFFD00F31),
      accent: Color(0xFFFFFFFF),
      crestAsset: 'assets/images/teams/lotte.png',
      backgroundAsset: 'assets/images/backgrounds/home_lotte.png',
      mascotAsset: 'assets/images/mascots/lotte.png',
      patternAsset: 'assets/images/patterns/lotte.png',
      moodAsset: 'assets/images/moods/lotte.png',
      tagline: '부산 갈매기의 영원한 사랑',
    ),
    'hanwha': TeamTheme(
      teamId: 'hanwha',
      teamName: '한화 이글스',
      teamShortName: '한화',
      stadium: '대전한화생명이글스파크',
      slogan: 'Soar like Eagles',
      primary: Color(0xFFFF6600),
      secondary: Color(0xFF000000),
      accent: Color(0xFFFFFFFF),
      crestAsset: 'assets/images/teams/hanwha.png',
      backgroundAsset: 'assets/images/backgrounds/home_hanwha.png',
      mascotAsset: 'assets/images/mascots/hanwha.png',
      patternAsset: 'assets/images/patterns/hanwha.png',
      moodAsset: 'assets/images/moods/hanwha.png',
      tagline: '대전의 부활, 비상하는 독수리',
    ),
  };

  static TeamTheme byId(String? id) {
    if (id == null) return TeamTheme.defaultTheme;
    return _themes[id] ?? TeamTheme.defaultTheme;
  }

  static List<TeamTheme> get all => _themes.values.toList();
}
