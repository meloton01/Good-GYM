import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_component_themes.dart';
import 'app_radii.dart';
import 'app_sizes.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Собирает ThemeData из токенов, чтобы стандартные виджеты Material не брали чужие цвета.
ThemeData buildAppTheme(AppColors colors, AppRadii radii) {
  final textTheme = AppTypography.textTheme(colors);
  final scheme = ColorScheme(
    brightness: colors.brightness,
    primary: colors.accentContent,
    onPrimary: colors.background,
    primaryContainer: colors.accent,
    onPrimaryContainer: colors.onAccent,
    secondary: colors.accentContent,
    onSecondary: colors.background,
    secondaryContainer: colors.accent,
    onSecondaryContainer: colors.onAccent,
    tertiary: colors.accentContent,
    onTertiary: colors.background,
    error: colors.error,
    onError: colors.background,
    surface: colors.surface,
    onSurface: colors.textPrimary,
    onSurfaceVariant: colors.textSecondary,
    surfaceContainerLowest: colors.background,
    surfaceContainerLow: colors.surface,
    surfaceContainer: colors.surface,
    surfaceContainerHigh: colors.surfaceHigh,
    surfaceContainerHighest: colors.surfaceHigh,
    outline: colors.border,
    outlineVariant: colors.border,
    inverseSurface: colors.textPrimary,
    onInverseSurface: colors.background,
    inversePrimary: colors.background,
    shadow: colors.background,
    scrim: colors.background,
    surfaceTint: Colors.transparent,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: colors.brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: colors.background,
    textTheme: textTheme,
    dividerColor: colors.border,
    appBarTheme: AppBarTheme(
      backgroundColor: colors.background,
      foregroundColor: colors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: textTheme.titleLarge,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: colors.surface,
      indicatorColor: colors.accent,
      elevation: 0,
      labelTextStyle: WidgetStatePropertyAll(textTheme.labelMedium),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected)
              ? colors.onAccent
              : colors.textSecondary,
        ),
      ),
    ),
    listTileTheme: ListTileThemeData(
      iconColor: colors.textSecondary,
      textColor: colors.textPrimary,
      selectedColor: colors.textPrimary,
      titleTextStyle: textTheme.bodyLarge,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radii.medium),
      ),
    ),
    filledButtonTheme: AppComponentThemes.filledButton(
      colors,
      textTheme,
      radii,
    ),
    outlinedButtonTheme: AppComponentThemes.outlinedButton(
      colors,
      textTheme,
      radii,
    ),
    textButtonTheme: AppComponentThemes.textButton(colors, textTheme, radii),
    inputDecorationTheme: AppComponentThemes.input(colors, textTheme, radii),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: colors.accentContent,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: colors.surfaceHigh,
      contentTextStyle: textTheme.bodyMedium,
      actionTextColor: colors.textPrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radii.medium),
      ),
    ),
    extensions: <ThemeExtension<dynamic>>[
      colors,
      AppSpacing.standard,
      radii,
      AppSizes.standard,
    ],
  );
}
