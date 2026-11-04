import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/settings/presentation/app_settings_controller.dart';
import 'app_radii.dart';
import 'app_theme.dart';
import 'appearance_colors.dart';

/// Светлая и тёмная темы из текущих настроек внешнего вида.
typedef AppThemes = ({ThemeData light, ThemeData dark});

/// Пересобирает темы только при смене палитры, акцента или скруглений.
final appThemesProvider = Provider<AppThemes>((ref) {
  final (palette, accent, cornerStyle) = ref.watch(
    appSettingsProvider.select(
      (settings) => (settings.palette, settings.accent, settings.cornerStyle),
    ),
  );
  final radii = AppRadii.forStyle(cornerStyle);
  ThemeData build(Brightness brightness) => buildAppTheme(
    AppearanceColors.resolve(brightness, palette, accent),
    radii,
  );
  return (light: build(Brightness.light), dark: build(Brightness.dark));
});
