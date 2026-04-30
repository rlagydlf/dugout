import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router.dart';
import 'theme/app_theme.dart';
import 'theme/theme_provider.dart';

class DugoutApp extends ConsumerWidget {
  const DugoutApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final team = ref.watch(currentTeamProvider);
    final dark = ref.watch(darkModeProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: '더그아웃',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(team, dark: dark),
      routerConfig: router,
    );
  }
}
