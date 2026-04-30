import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dugout/app/app.dart';
import 'package:dugout/app/theme/team_theme.dart';
import 'package:dugout/app/theme/theme_provider.dart';

void main() {
  testWidgets('App renders splash with default theme', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: DugoutApp()));
    await tester.pump();
    expect(find.text('DUGOUT'), findsOneWidget);
  });

  testWidgets('Team change updates theme', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(currentTeamProvider.notifier).select('lg');
    final TeamTheme team = container.read(currentTeamProvider);
    expect(team.teamId, 'lg');
    expect(team.primary, const Color(0xFFC30452));
  });
}
