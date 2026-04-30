import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../shared/widgets/d_bottom_nav.dart';

/// 하단 네비게이션 바를 가진 메인 5탭 컨테이너.
/// StatefulShellRoute의 navigationShell과 함께 사용.
class RootShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const RootShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: navigationShell,
      bottomNavigationBar: DBottomNav(
        currentIndex: navigationShell.currentIndex,
        onTap: (i) => navigationShell.goBranch(
          i,
          initialLocation: i == navigationShell.currentIndex,
        ),
        onSortie: () => context.push('/sortie'),
      ),
    );
  }
}
