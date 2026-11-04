import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/errors/app_failure.dart';
import '../../../core/errors/result.dart';
import '../../../core/units/length_unit.dart';
import '../../../core/units/weight_unit.dart';
import '../domain/accent_id.dart';
import '../domain/app_settings.dart';
import '../domain/app_theme_mode.dart';
import '../domain/corner_style.dart';
import '../domain/notification_type.dart';
import '../domain/palette_id.dart';
import '../domain/settings_repository.dart';

/// Хранит настройки устройства в SharedPreferences.
class SharedPreferencesSettingsRepository implements SettingsRepository {
  /// Создаёт репозиторий поверх готового экземпляра SharedPreferences.
  SharedPreferencesSettingsRepository(this._preferences);

  static const String _themeModeKey = 'settings.themeMode';
  static const String _languageCodeKey = 'settings.languageCode';
  static const String _paletteKey = 'settings.palette';
  static const String _accentKey = 'settings.accent';
  static const String _cornerStyleKey = 'settings.cornerStyle';
  static const String _weightUnitKey = 'settings.weightUnit';
  static const String _lengthUnitKey = 'settings.lengthUnit';
  static const String _mutedNotificationsKey = 'settings.mutedNotifications';

  final SharedPreferences _preferences;

  /// Читает настройки; неизвестные значения заменяются значениями по умолчанию.
  @override
  AppSettings load() {
    const defaults = AppSettings();
    final muted = _preferences.get(_mutedNotificationsKey);
    return AppSettings(
      themeMode:
          _enum(_themeModeKey, AppThemeMode.values) ?? defaults.themeMode,
      languageCode: _string(_languageCodeKey),
      palette: _enum(_paletteKey, PaletteId.values) ?? defaults.palette,
      accent: _enum(_accentKey, AccentId.values),
      cornerStyle:
          _enum(_cornerStyleKey, CornerStyle.values) ?? defaults.cornerStyle,
      weightUnit:
          _enum(_weightUnitKey, WeightUnit.values) ?? defaults.weightUnit,
      lengthUnit:
          _enum(_lengthUnitKey, LengthUnit.values) ?? defaults.lengthUnit,
      mutedNotifications: muted is List
          ? {
              for (final name in muted.whereType<String>())
                ?NotificationType.values.asNameMap()[name],
            }
          : defaults.mutedNotifications,
    );
  }

  /// Записывает все настройки; при ошибке записи возвращает [AppFailure.storage].
  @override
  Future<Result<void>> save(AppSettings settings) async {
    try {
      final results = await Future.wait([
        _preferences.setString(_themeModeKey, settings.themeMode.name),
        _writeOptional(_languageCodeKey, settings.languageCode),
        _preferences.setString(_paletteKey, settings.palette.name),
        _writeOptional(_accentKey, settings.accent?.name),
        _preferences.setString(_cornerStyleKey, settings.cornerStyle.name),
        _preferences.setString(_weightUnitKey, settings.weightUnit.name),
        _preferences.setString(_lengthUnitKey, settings.lengthUnit.name),
        _preferences.setStringList(_mutedNotificationsKey, [
          for (final type in settings.mutedNotifications) type.name,
        ]),
      ]);
      return results.every((saved) => saved)
          ? const Success(null)
          : const Failure(AppFailure.storage);
    } on Exception catch (error) {
      return Failure(AppFailure.storage, cause: error);
    }
  }

  /// Читает строку или null, если значения нет или у него другой тип.
  String? _string(String key) {
    final value = _preferences.get(key);
    return value is String ? value : null;
  }

  /// Читает значение enum по имени или null, если имя неизвестно.
  T? _enum<T extends Enum>(String key, List<T> values) {
    final name = _string(key);
    return name == null ? null : values.asNameMap()[name];
  }

  /// Записывает строку или удаляет ключ, если значения нет.
  Future<bool> _writeOptional(String key, String? value) {
    return value == null
        ? _preferences.remove(key)
        : _preferences.setString(key, value);
  }
}
