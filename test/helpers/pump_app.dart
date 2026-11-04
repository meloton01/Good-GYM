import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:good_gym/app/app.dart';
import 'package:good_gym/features/settings/data/settings_repository_provider.dart';
import 'package:good_gym/features/settings/data/shared_preferences_settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Запускает приложение с пустыми настройками и заданным размером экрана и шрифта.
Future<void> pumpApp(
  WidgetTester tester, {
  Size size = const Size(360, 640),
  double textScale = 1,
  Map<String, Object> preferences = const {},
}) async {
  SharedPreferences.setMockInitialValues(preferences);
  final instance = await SharedPreferences.getInstance();
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
      ],
      child: const GoodGymApp(),
    ),
  );
  await tester.pumpAndSettle();
}
