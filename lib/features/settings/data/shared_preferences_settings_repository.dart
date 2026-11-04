import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/errors/app_failure.dart';
import '../../../core/errors/result.dart';
import '../domain/app_settings.dart';
import '../domain/app_theme_mode.dart';
import '../domain/settings_repository.dart';

/// Хранит настройки интерфейса в SharedPreferences.
class SharedPreferencesSettingsRepository implements SettingsRepository {
  /// Создаёт репозиторий поверх готового экземпляра SharedPreferences.
  SharedPreferencesSettingsRepository(this._preferences);

  static const String _themeModeKey = 'settings.themeMode';
  static const String _languageCodeKey = 'settings.languageCode';

  final SharedPreferences _preferences;

  /// Читает настройки; неизвестные значения заменяются значениями по умолчанию.
  @override
  AppSettings load() {
    final themeName = _preferences.get(_themeModeKey);
    final languageCode = _preferences.get(_languageCodeKey);
    return AppSettings(
      themeMode: themeName is String
          ? AppThemeMode.values.asNameMap()[themeName] ?? AppThemeMode.system
          : AppThemeMode.system,
      languageCode: languageCode is String ? languageCode : null,
    );
  }

  /// Записывает тему и язык; при ошибке записи возвращает [AppFailure.storage].
  @override
  Future<Result<void>> save(AppSettings settings) async {
    try {
      final languageCode = settings.languageCode;
      final results = await Future.wait([
        _preferences.setString(_themeModeKey, settings.themeMode.name),
        if (languageCode == null)
          _preferences.remove(_languageCodeKey)
        else
          _preferences.setString(_languageCodeKey, languageCode),
      ]);
      return results.every((saved) => saved)
          ? const Success(null)
          : const Failure(AppFailure.storage);
    } on Exception catch (error) {
      return Failure(AppFailure.storage, cause: error);
    }
  }
}
