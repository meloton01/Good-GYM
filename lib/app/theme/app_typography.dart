import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Токены типографики: размеры в sp, минимум 12; семейство шрифтов системное.
abstract final class AppTypography {
  static const double small = 12;
  static const double body = 14;
  static const double bodyLarge = 16;
  static const double title = 18;
  static const double titleLarge = 22;
  static const double headline = 28;

  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight bold = FontWeight.w700;

  /// Собирает TextTheme из токенов с цветами текущей темы.
  static TextTheme textTheme(AppColors colors) {
    TextStyle style(double size, FontWeight weight, Color color) =>
        TextStyle(fontSize: size, fontWeight: weight, color: color);

    return TextTheme(
      headlineSmall: style(headline, bold, colors.textPrimary),
      titleLarge: style(titleLarge, bold, colors.textPrimary),
      titleMedium: style(title, medium, colors.textPrimary),
      titleSmall: style(bodyLarge, medium, colors.textPrimary),
      bodyLarge: style(bodyLarge, regular, colors.textPrimary),
      bodyMedium: style(body, regular, colors.textPrimary),
      bodySmall: style(small, regular, colors.textSecondary),
      labelLarge: style(body, medium, colors.textPrimary),
      labelMedium: style(small, medium, colors.textPrimary),
      labelSmall: style(small, medium, colors.textSecondary),
    );
  }
}
