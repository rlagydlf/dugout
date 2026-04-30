import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'team_theme.dart';

/// 현재 응원팀 ID. null이면 미선택(디폴트 테마).
class CurrentTeamNotifier extends StateNotifier<TeamTheme> {
  CurrentTeamNotifier() : super(TeamTheme.defaultTheme) {
    _load();
  }

  static const _prefsKey = 'team_id';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_prefsKey);
    if (id != null) {
      state = TeamThemes.byId(id);
    }
  }

  Future<void> select(String teamId) async {
    state = TeamThemes.byId(teamId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, teamId);
  }

  Future<void> reset() async {
    state = TeamTheme.defaultTheme;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }
}

final currentTeamProvider =
    StateNotifierProvider<CurrentTeamNotifier, TeamTheme>(
  (ref) => CurrentTeamNotifier(),
);

/// 다크모드 여부 (기본 다크).
final darkModeProvider = StateProvider<bool>((ref) => true);
