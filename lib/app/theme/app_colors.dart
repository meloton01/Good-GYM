import 'package:flutter/material.dart';

import 'app_palette.dart';

/// Цветовые токены темы; виджеты берут цвета только отсюда.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  /// Создаёт набор цветовых токенов.
  const AppColors({
    required this.brightness,
    required this.background,
    required this.surface,
    required this.surfaceHigh,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.accent,
    required this.onAccent,
    required this.accentContent,
    required this.error,
    required this.success,
  });

  final Brightness brightness;
  final Color background;
  final Color surface;
  final Color surfaceHigh;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;

  /// Заливка акцентных элементов: кнопки, активная вкладка.
  final Color accent;

  /// Текст и иконки поверх заливки [accent].
  final Color onAccent;

  /// Акцент для текста и иконок на фоне; в светлой теме не жёлтый ради контраста.
  final Color accentContent;
  final Color error;
  final Color success;

  /// Тёмная тема по умолчанию.
  static const AppColors dark = AppColors(
    brightness: Brightness.dark,
    background: AppPalette.black,
    surface: AppPalette.graphite,
    surfaceHigh: AppPalette.graphiteHigh,
    border: AppPalette.graphiteBorder,
    textPrimary: AppPalette.white,
    textSecondary: AppPalette.greyText,
    accent: AppPalette.yellow,
    onAccent: AppPalette.black,
    accentContent: AppPalette.yellow,
    error: AppPalette.red,
    success: AppPalette.green,
  );

  /// Светлая тема.
  static const AppColors light = AppColors(
    brightness: Brightness.light,
    background: AppPalette.paper,
    surface: AppPalette.white,
    surfaceHigh: AppPalette.paperHigh,
    border: AppPalette.paperBorder,
    textPrimary: AppPalette.black,
    textSecondary: AppPalette.greyTextDark,
    accent: AppPalette.yellow,
    onAccent: AppPalette.black,
    accentContent: AppPalette.black,
    error: AppPalette.redDark,
    success: AppPalette.greenDark,
  );

  /// Возвращает копию с заменёнными токенами.
  @override
  AppColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceHigh,
    Color? border,
    Color? textPrimary,
    Color? textSecondary,
    Color? accent,
    Color? onAccent,
    Color? accentContent,
    Color? error,
    Color? success,
  }) {
    return AppColors(
      brightness: brightness,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceHigh: surfaceHigh ?? this.surfaceHigh,
      border: border ?? this.border,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      accentContent: accentContent ?? this.accentContent,
      error: error ?? this.error,
      success: success ?? this.success,
    );
  }

  /// Плавно смешивает токены при смене темы.
  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) {
      return this;
    }
    return AppColors(
      brightness: t < 0.5 ? brightness : other.brightness,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceHigh: Color.lerp(surfaceHigh, other.surfaceHigh, t)!,
      border: Color.lerp(border, other.border, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      accentContent: Color.lerp(accentContent, other.accentContent, t)!,
      error: Color.lerp(error, other.error, t)!,
      success: Color.lerp(success, other.success, t)!,
    );
  }
}
