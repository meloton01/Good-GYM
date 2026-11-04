import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/units/length_unit.dart';
import '../../../core/units/weight_unit.dart';
import 'accent_id.dart';
import 'app_theme_mode.dart';
import 'corner_style.dart';
import 'notification_type.dart';
import 'palette_id.dart';

part 'app_settings.freezed.dart';

/// Локальные настройки устройства: внешний вид, язык, единицы, уведомления.
@freezed
abstract class AppSettings with _$AppSettings {
  const AppSettings._();

  /// Создаёт настройки; [languageCode] null — язык системы, [accent] null — акцент палитры.
  const factory AppSettings({
    @Default(AppThemeMode.system) AppThemeMode themeMode,
    String? languageCode,
    @Default(PaletteId.blackYellow) PaletteId palette,
    AccentId? accent,
    @Default(CornerStyle.standard) CornerStyle cornerStyle,
    @Default(WeightUnit.kilograms) WeightUnit weightUnit,
    @Default(LengthUnit.centimeters) LengthUnit lengthUnit,
    @Default({}) Set<NotificationType> mutedNotifications,
  }) = _AppSettings;

  /// Включён ли тип уведомлений; по умолчанию включены все.
  bool isNotificationEnabled(NotificationType type) =>
      !mutedNotifications.contains(type);
}
