/// 가상 사용자 모델 (mock).
class AppUser {
  final String id;
  final String email;
  final String nickname;
  final String? teamId;
  final int point;
  final int contribution; // 팀 기여도 점수 (인앱 메트릭)
  final int sortieCount; // 출정 횟수
  final int stadiumVisits; // 직관 횟수
  final List<String> badgeIds;

  const AppUser({
    required this.id,
    required this.email,
    required this.nickname,
    required this.teamId,
    required this.point,
    required this.contribution,
    required this.sortieCount,
    required this.stadiumVisits,
    required this.badgeIds,
  });

  AppUser copyWith({
    String? teamId,
    int? point,
    int? contribution,
    int? sortieCount,
    int? stadiumVisits,
    List<String>? badgeIds,
  }) =>
      AppUser(
        id: id,
        email: email,
        nickname: nickname,
        teamId: teamId ?? this.teamId,
        point: point ?? this.point,
        contribution: contribution ?? this.contribution,
        sortieCount: sortieCount ?? this.sortieCount,
        stadiumVisits: stadiumVisits ?? this.stadiumVisits,
        badgeIds: badgeIds ?? this.badgeIds,
      );

  static const guest = AppUser(
    id: 'guest',
    email: '',
    nickname: '게스트',
    teamId: null,
    point: 0,
    contribution: 0,
    sortieCount: 0,
    stadiumVisits: 0,
    badgeIds: [],
  );

  /// 데모 사용자 (기본 LG 응원팀, 12,500p)
  static const demo = AppUser(
    id: 'demo-001',
    email: 'fan@dugout.app',
    nickname: '잠실의외침',
    teamId: 'lg',
    point: 12500,
    contribution: 4280,
    sortieCount: 38,
    stadiumVisits: 7,
    badgeIds: ['first_sortie', 'rookie_predictor', 'night_owl'],
  );
}
