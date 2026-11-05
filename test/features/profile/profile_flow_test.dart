import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';
import '../../helpers/scroll_to.dart';

void main() {
  testWidgets('new user picks nickname and role before the tabs', (
    tester,
  ) async {
    final backend = await pumpApp(tester, profiles: []);
    backend.profiles.takenNicknames.add('taken');
    expect(find.widgetWithText(AppBar, 'Your profile'), findsOneWidget);

    final nickname = find.widgetWithText(TextFormField, 'Nickname');
    await tester.enterText(nickname, 'ab');
    await scrollToAndTap(tester, find.widgetWithText(FilledButton, 'Continue'));
    expect(
      find.text('Use 3 to 20 characters: a-z, 0-9, _ and .'),
      findsOneWidget,
    );
    expect(find.text('Tick the box to create a profile'), findsOneWidget);

    await scrollToAndTap(tester, find.byType(Checkbox));
    await tester.enterText(nickname, 'Taken');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    await scrollToAndTap(tester, find.widgetWithText(FilledButton, 'Continue'));
    expect(find.text('This nickname is taken. Choose another one.'), findsOne);
    ScaffoldMessenger.of(tester.element(find.byType(Form)))
        .hideCurrentSnackBar();
    await tester.pumpAndSettle();

    await tester.enterText(nickname, 'Coach.Max');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.text('Coach'), findsNothing);
    await tester.ensureVisible(find.text('Student'));
    await tester.tap(find.text('Student'));
    await scrollToAndTap(tester, find.widgetWithText(FilledButton, 'Continue'));

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
