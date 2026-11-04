import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/result.dart';
import '../data/settings_repository_provider.dart';
import '../domain/app_settings.dart';
import '../domain/app_theme_mode.dart';

/// Текущие настройки интерфейса; изменения применяются сразу и сохраняются.
final appSettingsProvider =
    NotifierProvider<AppSettingsController, AppSettings>(
      AppSettingsController.new,
    );

/// Управляет темой и языком приложения.
class AppSettingsController extends Notifier<AppSettings> {
  /// Загружает сохранённые настройки при первом обращении.
  @override
  AppSettings build() => ref.watch(settingsRepositoryProvider).load();

  /// Меняет режим темы.
  Future<Result<void>> setThemeMode(AppThemeMode mode) =>
      _apply(state.copyWith(themeMode: mode));

  /// Меняет язык; null возвращает язык системы.
  Future<Result<void>> setLanguageCode(String? languageCode) =>
      _apply(state.copyWith(languageCode: languageCode));

  /// Применяет настройки сразу и откатывает их, если сохранить не удалось.
  Future<Result<void>> _apply(AppSettings next) async {
    final previous = state;
    state = next;
    final result = await ref.read(settingsRepositoryProvider).save(next);
    if (result is Failure<void>) {
      state = previous;
    }
    return result;
  }
}
