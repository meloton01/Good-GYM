import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/result.dart';
import '../../../core/units/length_unit.dart';
import '../../../core/units/weight_unit.dart';
import '../data/settings_repository_provider.dart';
import '../domain/accent_id.dart';
import '../domain/app_settings.dart';
import '../domain/app_theme_mode.dart';
import '../domain/corner_style.dart';
import '../domain/notification_type.dart';
import '../domain/palette_id.dart';

/// Текущие настройки устройства; изменения применяются сразу и сохраняются.
final appSettingsProvider =
    NotifierProvider<AppSettingsController, AppSettings>(
      AppSettingsController.new,
    );

/// Управляет внешним видом, языком, единицами и уведомлениями.
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

  /// Меняет палитру и сбрасывает акцент на акцент палитры.
  Future<Result<void>> setPalette(PaletteId palette) =>
      _apply(state.copyWith(palette: palette, accent: null));

  /// Меняет акцентный цвет поверх палитры.
  Future<Result<void>> setAccent(AccentId accent) =>
      _apply(state.copyWith(accent: accent));

  /// Меняет стиль скруглений.
  Future<Result<void>> setCornerStyle(CornerStyle style) =>
      _apply(state.copyWith(cornerStyle: style));

  /// Меняет единицу веса.
  Future<Result<void>> setWeightUnit(WeightUnit unit) =>
      _apply(state.copyWith(weightUnit: unit));

  /// Меняет единицу длины.
  Future<Result<void>> setLengthUnit(LengthUnit unit) =>
      _apply(state.copyWith(lengthUnit: unit));

  /// Включает или выключает тип уведомлений.
  Future<Result<void>> setNotificationEnabled(
    NotificationType type, {
    required bool enabled,
  }) {
    final muted = {...state.mutedNotifications};
    enabled ? muted.remove(type) : muted.add(type);
    return _apply(state.copyWith(mutedNotifications: muted));
  }

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
