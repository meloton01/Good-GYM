import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:good_gym/app/app.dart';
import 'package:good_gym/features/auth/data/auth_repository_provider.dart';
import 'package:good_gym/features/auth/domain/auth_user.dart';
import 'package:good_gym/features/profile/data/user_profile_repository_provider.dart';
import 'package:good_gym/features/profile/domain/user_profile.dart';
import 'package:good_gym/features/profile/domain/user_role.dart';
import 'package:good_gym/features/settings/data/settings_repository_provider.dart';
import 'package:good_gym/features/settings/data/shared_preferences_settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fake_auth_repository.dart';
import 'fake_user_profile_repository.dart';

const testUser = AuthUser(
  uid: 'uid-1',
  email: 'athlete@example.com',
  emailVerified: true,
  usesPassword: true,
);

const testProfile = UserProfile(
  uid: 'uid-1',
  nickname: 'iron.athlete',
  role: UserRole.athlete,
);

/// Тестовые репозитории, подставленные в приложение.
class TestBackend {
  /// Создаёт пару фейковых репозиториев.
  TestBackend({required this.auth, required this.profiles});

  final FakeAuthRepository auth;
  final FakeUserProfileRepository profiles;
}

/// Запускает приложение с фейковым бэкендом; по умолчанию пользователь вошёл и профиль создан.
Future<TestBackend> pumpApp(
  WidgetTester tester, {
  Size size = const Size(360, 640),
  double textScale = 1,
  Map<String, Object> preferences = const {},
  AuthUser? user = testUser,
  List<UserProfile> profiles = const [testProfile],
}) async {
  SharedPreferences.setMockInitialValues(preferences);
  final instance = await SharedPreferences.getInstance();
  final backend = TestBackend(
    auth: FakeAuthRepository(user: user),
    profiles: FakeUserProfileRepository(profiles: profiles),
  );
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  tester.platformDispatcher.localesTestValue = const [Locale('en')];
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearAllTestValues);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(
          SharedPreferencesSettingsRepository(instance),
        ),
        authRepositoryProvider.overrideWithValue(backend.auth),
        userProfileRepositoryProvider.overrideWithValue(backend.profiles),
      ],
      child: const GoodGymApp(),
    ),
  );
  await tester.pumpAndSettle();
  return backend;
}
