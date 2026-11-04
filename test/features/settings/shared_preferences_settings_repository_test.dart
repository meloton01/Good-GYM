import 'package:flutter_test/flutter_test.dart';
import 'package:good_gym/core/errors/result.dart';
import 'package:good_gym/features/settings/data/shared_preferences_settings_repository.dart';
import 'package:good_gym/features/settings/domain/app_settings.dart';
import 'package:good_gym/features/settings/domain/app_theme_mode.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<SharedPreferencesSettingsRepository> createRepository(
    Map<String, Object> values,
  ) async {
    SharedPreferences.setMockInitialValues(values);
    return SharedPreferencesSettingsRepository(
      await SharedPreferences.getInstance(),
    );
  }

  test('returns defaults when nothing is stored', () async {
    final repository = await createRepository({});
    expect(repository.load(), const AppSettings());
  });

  test('falls back to defaults for unknown stored values', () async {
    final repository = await createRepository({
      'settings.themeMode': 'neon',
      'settings.languageCode': 42,
    });
    expect(repository.load(), const AppSettings());
  });

  test('saves and loads theme and language', () async {
    final repository = await createRepository({});
    const settings = AppSettings(
      themeMode: AppThemeMode.dark,
      languageCode: 'uk',
    );
    expect(await repository.save(settings), isA<Success<void>>());
    expect(repository.load(), settings);
  });

  test('removes language when switching back to system', () async {
    final repository = await createRepository({'settings.languageCode': 'ru'});
    await repository.save(const AppSettings());
    expect(repository.load().languageCode, isNull);
  });
}
