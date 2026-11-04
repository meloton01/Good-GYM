import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radii.dart';
import 'app_sizes.dart';
import 'app_spacing.dart';

/// Темы кнопок и полей ввода, собранные из токенов.
abstract final class AppComponentThemes {
  /// Форма с закруглением medium для кнопок и полей.
  static RoundedRectangleBorder _shape(AppRadii radii) =>
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(radii.medium));

  /// Минимальный размер кнопки не меньше зоны нажатия 48 dp.
  static Size _minimumSize(AppSizes sizes) =>
      Size(sizes.minTouchTarget, sizes.minTouchTarget);

  /// Основная кнопка: жёлтая заливка, тёмный текст.
  static FilledButtonThemeData filledButton(
    AppColors colors,
    TextTheme textTheme,
    AppRadii radii,
  ) {
    const sizes = AppSizes.standard;
    return FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: colors.accent,
        foregroundColor: colors.onAccent,
        minimumSize: _minimumSize(sizes),
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.standard.lg,
          vertical: AppSpacing.standard.sm,
        ),
        textStyle: textTheme.labelLarge,
        shape: _shape(radii),
      ),
    );
  }

  /// Второстепенная кнопка: контур без заливки.
  static OutlinedButtonThemeData outlinedButton(
    AppColors colors,
    TextTheme textTheme,
    AppRadii radii,
  ) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colors.textPrimary,
        side: BorderSide(color: colors.border),
        minimumSize: _minimumSize(AppSizes.standard),
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.standard.lg,
          vertical: AppSpacing.standard.sm,
        ),
        textStyle: textTheme.labelLarge,
        shape: _shape(radii),
      ),
    );
  }

  /// Текстовая кнопка-ссылка.
  static TextButtonThemeData textButton(
    AppColors colors,
    TextTheme textTheme,
    AppRadii radii,
  ) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colors.accentContent,
        minimumSize: _minimumSize(AppSizes.standard),
        textStyle: textTheme.labelLarge,
        shape: _shape(radii),
      ),
    );
  }

  /// Поля ввода: заливка поверхности, видимая граница, акцент при фокусе.
  static InputDecorationThemeData input(
    AppColors colors,
    TextTheme textTheme,
    AppRadii radii,
  ) {
    OutlineInputBorder border(Color color) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(radii.medium),
      borderSide: BorderSide(color: color),
    );
    return InputDecorationThemeData(
      filled: true,
      fillColor: colors.surface,
      labelStyle: textTheme.bodyLarge?.copyWith(color: colors.textSecondary),
      helperStyle: textTheme.bodySmall,
      errorStyle: textTheme.bodySmall?.copyWith(color: colors.error),
      helperMaxLines: 3,
      errorMaxLines: 3,
      border: border(colors.border),
      enabledBorder: border(colors.border),
      focusedBorder: border(colors.accentContent),
      errorBorder: border(colors.error),
      focusedErrorBorder: border(colors.error),
    );
  }
}
