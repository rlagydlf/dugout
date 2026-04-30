import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user.dart';

/// 인증/세션 상태.
enum AuthState { unknown, signedOut, signedIn }

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState.unknown);

  void boot() {
    // 데모: 1.2초 후 미로그인 상태로 시작
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) state = AuthState.signedOut;
    });
  }

  void signIn() => state = AuthState.signedIn;
  void signOut() => state = AuthState.signedOut;
}

final authProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier());

/// 현재 사용자(데모 데이터).
class UserNotifier extends StateNotifier<AppUser> {
  UserNotifier() : super(AppUser.guest);

  void becomeDemo() => state = AppUser.demo;
  void selectTeam(String teamId) => state = state.copyWith(teamId: teamId);
  void addPoint(int amount) => state = state.copyWith(point: state.point + amount);
  void addSortie() => state = state.copyWith(
        sortieCount: state.sortieCount + 1,
        contribution: state.contribution + 30,
      );
}

final userProvider =
    StateNotifierProvider<UserNotifier, AppUser>((ref) => UserNotifier());

/// 오늘 출정 여부.
final sortiedTodayProvider = StateProvider<bool>((ref) => false);
