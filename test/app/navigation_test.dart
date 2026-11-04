import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';
import '../helpers/scroll_to.dart';

void main() {
  testWidgets('starts on home and switches between all tabs', (tester) async {
    await pumpApp(tester);

    expect(find.widgetWithText(AppBar, 'Home'), findsOneWidget);

    for (final label in ['Rating', 'Workouts', 'Profile', 'Settings']) {
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text(label),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.widgetWithText(AppBar, label), findsOneWidget);
    }
  });

  testWidgets('changes language without restart', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Українська'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Налаштування'), findsOneWidget);

    await tester.tap(find.text('Русский'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Настройки'), findsOneWidget);
  });

  testWidgets('changes theme mode from appearance', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Appearance'));
    await tester.pumpAndSettle();

    await scrollToAndTap(tester, find.text('Dark'));
    expect(
      Theme.of(tester.element(find.text('Dark'))).brightness,
      Brightness.dark,
    );

    await scrollToAndTap(tester, find.text('Light'));
    expect(
      Theme.of(tester.element(find.text('Light'))).brightness,
      Brightness.light,
    );
  });
}
