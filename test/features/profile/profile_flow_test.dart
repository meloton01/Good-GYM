import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('new user picks nickname and role before the tabs', (
    tester,
  ) async {
    final backend = await pumpApp(tester, profiles: []);
    backend.profiles.takenNicknames.add('taken');
    expect(find.widgetWithText(AppBar, 'Your profile'), findsOneWidget);

    final nickname = find.widgetWithText(TextFormField, 'Nickname');
    await tester.enterText(nickname, 'ab');
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await tester.pumpAndSettle();
    expect(
      find.text('Use 3 to 20 characters: a-z, 0-9, _ and .'),
      findsOneWidget,
    );

    await tester.enterText(nickname, 'Taken');
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await tester.pumpAndSettle();
    expect(find.text('This nickname is taken. Choose another one.'), findsOne);

    await tester.enterText(nickname, 'Coach.Max');
    expect(find.text('Coach'), findsNothing);
    await tester.tap(find.text('Student'));
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('coach.max'), findsOneWidget);
    expect(find.text('Student'), findsNWidgets(2));
  });

  testWidgets('role can be changed from the profile tab', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Athlete'), findsNWidgets(2));

    await tester.tap(find.text('Role'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Student'));
    await tester.pumpAndSettle();

    expect(find.text('Student'), findsNWidgets(2));
    expect(find.text('Athlete'), findsNothing);
  });
}
