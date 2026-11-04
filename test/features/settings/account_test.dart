import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:good_gym/core/errors/app_failure.dart';
import 'package:good_gym/core/errors/result.dart';

import '../../helpers/pump_app.dart';
import '../../helpers/scroll_to.dart';

void main() {
  Future<void> openDeleteDialog(WidgetTester tester) async {
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    await scrollToAndTap(tester, find.text('Delete account'));
  }

  testWidgets('delete account confirms password, removes data and signs out', (
    tester,
  ) async {
    final backend = await pumpApp(tester);
    await openDeleteDialog(tester);
    expect(find.text('Delete account?'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await tester.pumpAndSettle();
    expect(find.text('Fill in this field'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Current password'),
      'secret-password',
    );
    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(backend.auth.calls, [
      'reauthenticate:secret-password',
      'deleteAccount',
    ]);
    expect(backend.profiles.deletedUids, [testUser.uid]);
    expect(find.widgetWithText(AppBar, 'Sign in'), findsOneWidget);
  });

  testWidgets('wrong password keeps the account and its data', (tester) async {
    final backend = await pumpApp(tester);
    backend.auth.reauthResult = const Failure(AppFailure.invalidCredentials);
    await openDeleteDialog(tester);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Current password'),
      'wrong',
    );
    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(backend.auth.calls, ['reauthenticate:wrong']);
    expect(backend.profiles.deletedUids, isEmpty);
    expect(
      find.text('Wrong email or password. Check them or reset the password.'),
      findsOneWidget,
    );
  });

  testWidgets('cancel closes the dialog without changes', (tester) async {
    final backend = await pumpApp(tester);
    await openDeleteDialog(tester);

    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();

    expect(backend.auth.calls, isEmpty);
    expect(find.text('Delete account?'), findsNothing);
  });
}
