import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:good_gym/core/errors/app_failure.dart';
import 'package:good_gym/core/errors/result.dart';
import 'package:good_gym/features/auth/domain/auth_user.dart';

import '../../helpers/pump_app.dart';

void main() {
  Finder field(String label) => find.widgetWithText(TextFormField, label);

  testWidgets('signed out user lands on sign in and validates the form', (
    tester,
  ) async {
    final backend = await pumpApp(tester, user: null);
    expect(find.widgetWithText(AppBar, 'Sign in'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();
    expect(find.text('Fill in this field'), findsNWidgets(2));

    await tester.enterText(field('Email'), 'not-an-email');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();
    expect(find.text('Enter an email like name@example.com'), findsOneWidget);
    expect(backend.auth.calls, isEmpty);
  });

  testWidgets('sign in opens tabs when the profile exists', (tester) async {
    final backend = await pumpApp(tester, user: null);

    await tester.enterText(field('Email'), 'athlete@example.com');
    await tester.enterText(field('Password'), 'secret-password');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();

    expect(backend.auth.calls, ['signInWithEmail:athlete@example.com']);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('wrong credentials show a message with the next step', (
    tester,
  ) async {
    final backend = await pumpApp(tester, user: null);
    backend.auth.nextResult = const Failure(AppFailure.invalidCredentials);

    await tester.enterText(field('Email'), 'athlete@example.com');
    await tester.enterText(field('Password'), 'wrong');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();

    expect(
      find.text('Wrong email or password. Check them or reset the password.'),
      findsOneWidget,
    );
    expect(find.widgetWithText(AppBar, 'Sign in'), findsOneWidget);
  });

  testWidgets('sign up checks the password and opens email confirmation', (
    tester,
  ) async {
    final backend = await pumpApp(tester, user: null, profiles: []);
    backend.auth.signedInUser = const AuthUser(
      uid: 'uid-2',
      email: 'new@example.com',
      usesPassword: true,
    );
    await tester.tap(find.widgetWithText(TextButton, 'Create account'));
    await tester.pumpAndSettle();

    await tester.enterText(field('Email'), 'new@example.com');
    await tester.enterText(field('Password'), 'short');
    await tester.enterText(field('Repeat password'), 'other');
    await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
    await tester.pumpAndSettle();
    expect(find.text('Use at least 8 characters'), findsOneWidget);
    expect(find.text("Passwords don't match"), findsOneWidget);

    await tester.enterText(field('Password'), 'long-password');
    await tester.enterText(field('Repeat password'), 'long-password');
    await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
    await tester.pumpAndSettle();

    expect(backend.auth.calls, ['signUpWithEmail:new@example.com:en']);
    expect(find.widgetWithText(AppBar, 'Confirm email'), findsOneWidget);
    expect(find.textContaining('new@example.com'), findsOneWidget);
  });

  testWidgets('unconfirmed email stays on confirmation until verified', (
    tester,
  ) async {
    const unverified = AuthUser(
      uid: 'uid-1',
      email: 'athlete@example.com',
      usesPassword: true,
    );
    final backend = await pumpApp(tester, user: unverified);
    expect(find.widgetWithText(AppBar, 'Confirm email'), findsOneWidget);

    await tester.tap(find.text('Check confirmation'));
    await tester.pumpAndSettle();
    expect(
      find.text('Email is not confirmed yet. Open the link from the email.'),
      findsOneWidget,
    );

    backend.auth.emit(testUser);
    await tester.pumpAndSettle();
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('password reset shows the same answer for any email', (
    tester,
  ) async {
    final backend = await pumpApp(tester, user: null);
    await tester.tap(find.text('Forgot password?'));
    await tester.pumpAndSettle();

    await tester.enterText(field('Email'), 'someone@example.com');
    await tester.tap(find.widgetWithText(FilledButton, 'Send link'));
    await tester.pumpAndSettle();

    expect(backend.auth.calls, ['sendPasswordReset:someone@example.com:en']);
    expect(
      find.textContaining('If an account exists for someone@example.com'),
      findsOneWidget,
    );
  });

  testWidgets('sign out from settings returns to sign in', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Sign out'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'Sign in'), findsOneWidget);
  });
}
