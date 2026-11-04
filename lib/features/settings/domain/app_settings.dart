import 'package:freezed_annotation/freezed_annotation.dart';

import 'app_theme_mode.dart';

part 'app_settings.freezed.dart';

/// Локальные настройки интерфейса: тема и язык.
@freezed
abstract class AppSettings with _$AppSettings {
  /// Создаёт настройки; [languageCode] null означает язык системы.
  const factory AppSettings({
    @Default(AppThemeMode.system) AppThemeMode themeMode,
    String? languageCode,
  }) = _AppSettings;
}
