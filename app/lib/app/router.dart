import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/providers/app_providers.dart';
import '../features/auth/auth_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/signup_screen.dart';
import '../features/auth/splash_screen.dart';
import '../features/auth/team_select_screen.dart';
import '../features/checkin/checkin_screen.dart';
import '../features/common/banned_screen.dart';
import '../features/common/error_screen.dart';
import '../features/fancard/contribution_screen.dart';
import '../features/fancard/fancard_customize_screen.dart';
import '../features/fancard/fancard_screen.dart';
import '../features/home/home_screen.dart';
import '../features/home/series_screen.dart';
import '../features/notifications/notifications_screen.dart';
import '../features/point/point_ledger_screen.dart';
import '../features/prediction/prediction_detail_screen.dart';
import '../features/prediction/prediction_list_screen.dart';
import '../features/quest/quest_detail_screen.dart';
import '../features/quest/quest_list_screen.dart';
import '../features/quiz/quiz_detail_screen.dart';
import '../features/quiz/quiz_list_screen.dart';
import '../features/reward/reward_detail_screen.dart';
import '../features/reward/reward_list_screen.dart';
import '../features/settings/legal_screen.dart';
import '../features/settings/notifications_settings_screen.dart';
import '../features/settings/settings_home.dart';
import '../features/settings/support_screen.dart';
import '../features/settings/team_change_screen.dart';
import '../features/settings/withdraw_screen.dart';
import '../features/sortie/sortie_modal.dart';
import 'root_shell.dart';

final _rootKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/',
    routes: [
      // 풀스크린 (탭 외)
      GoRoute(path: '/', builder: (c, s) => const SplashScreen()),
      GoRoute(path: '/auth', builder: (c, s) => const AuthScreen()),
      GoRoute(path: '/auth/signup', builder: (c, s) => const SignupScreen()),
      GoRoute(path: '/auth/login', builder: (c, s) => const LoginScreen()),
      GoRoute(path: '/auth/team', builder: (c, s) => const TeamSelectScreen()),
      GoRoute(path: '/sortie', builder: (c, s) => const SortieModal()),
      GoRoute(path: '/error', builder: (c, s) => const ErrorScreen()),
      GoRoute(path: '/banned', builder: (c, s) => const BannedScreen()),

      // 5탭 Shell — 하단 네비게이션 유지. 모든 절대 path는 root level로 등록.
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            RootShell(navigationShell: navigationShell),
        branches: [
          // ── 1. 홈 브랜치 ────────────────────────────────────────────────
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/home', builder: (c, s) => const HomeScreen()),
              GoRoute(path: '/series', builder: (c, s) => const SeriesScreen()),
              GoRoute(path: '/checkin', builder: (c, s) => const CheckinScreen()),
              GoRoute(
                path: '/notifications',
                builder: (c, s) => const NotificationsScreen(),
              ),
            ],
          ),
          // ── 2. 퀘스트·예측·퀴즈 브랜치 ─────────────────────────────────
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/quests',
                builder: (c, s) => const QuestListScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (c, s) =>
                        QuestDetailScreen(questId: s.pathParameters['id'] ?? ''),
                  ),
                ],
              ),
              GoRoute(
                path: '/predictions',
                builder: (c, s) => const PredictionListScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (c, s) => PredictionDetailScreen(
                      predictionId: s.pathParameters['id'] ?? '',
                    ),
                  ),
                ],
              ),
              GoRoute(
                path: '/quizzes',
                builder: (c, s) => const QuizListScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (c, s) =>
                        QuizDetailScreen(quizId: s.pathParameters['id'] ?? ''),
                  ),
                ],
              ),
            ],
          ),
          // ── 3. 리워드·포인트 브랜치 ────────────────────────────────────
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/rewards',
                builder: (c, s) => const RewardListScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (c, s) => const RewardDetailScreen(),
                  ),
                ],
              ),
              GoRoute(path: '/points', builder: (c, s) => const PointLedgerScreen()),
            ],
          ),
          // ── 4. 팬카드·설정 브랜치 ──────────────────────────────────────
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/fancard',
                builder: (c, s) => const FancardScreen(),
                routes: [
                  GoRoute(
                    path: 'customize',
                    builder: (c, s) => const FancardCustomizeScreen(),
                  ),
                ],
              ),
              GoRoute(path: '/contribution', builder: (c, s) => const ContributionScreen()),
              GoRoute(path: '/settings', builder: (c, s) => const SettingsHomeScreen()),
              GoRoute(path: '/settings/team', builder: (c, s) => const TeamChangeScreen()),
              GoRoute(
                path: '/settings/notifications',
                builder: (c, s) => const NotificationsSettingsScreen(),
              ),
              GoRoute(path: '/settings/legal', builder: (c, s) => const LegalScreen()),
              GoRoute(path: '/settings/support', builder: (c, s) => const SupportScreen()),
              GoRoute(path: '/settings/withdraw', builder: (c, s) => const WithdrawScreen()),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => const ErrorScreen(),
    refreshListenable: _AuthListenable(ref),
  );
});

class _AuthListenable extends ChangeNotifier {
  _AuthListenable(this.ref) {
    ref.listen<AuthState>(authProvider, (e, s) => notifyListeners());
  }
  final Ref ref;
}
