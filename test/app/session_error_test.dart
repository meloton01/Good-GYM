import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:good_gym/app/app.dart';
import 'package:good_gym/features/auth/data/auth_repository_provider.dart';
import 'package:good_gym/features/profile/data/user_profile_repository_provider.dart';
import 'package:good_gym/features/settings/data/settings_repository_provider.dart';
import 'package:good_gym/features/settings/data/shared_preferences_settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fake_auth_repository.dart';
import '../helpers/fake_user_profile_repository.dart';
import '../helpers/pump_app.dart';

void main() {
  testWidgets('profile load error offers sign out back to sign in', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final auth = FakeAuthRepository(user: testUser);
    final profiles = FakeUserProfileRepository()
      ..watchError = StateError('permission denied');
    tester.platformDispatcher.localesTestValue = const [Locale('en')];
    addTearDown(tester.platformDispatcher.clearAllTestValues);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(
            SharedPreferencesSettingsRepository(preferences),
          ),
          authRepositoryProvider.overrideWithValue(auth),
          userProfileRepositoryProvider.overrideWithValue(profiles),
        ],
        child: const GoodGymApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text("Couldn't load the profile"), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Sign out'));
    await tester.pumpAndSettle();

    expect(auth.calls, ['signOut']);
    expect(find.widgetWithText(AppBar, 'Sign in'), findsOneWidget);
  });
}
