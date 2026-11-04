import 'package:flutter/material.dart';

import '../../features/settings/domain/accent_id.dart';
import '../../features/settings/domain/palette_id.dart';
import 'app_colors.dart';
import 'app_palette.dart';

/// Цвета палитр и акцентов из настроек внешнего вида.
abstract final class AppearanceColors {
  /// Акцент палитры, если пользователь не выбрал свой.
  static AccentId defaultAccent(PaletteId palette) {
    return switch (palette) {
      PaletteId.blackYellow => AccentId.yellow,
      PaletteId.graphiteOrange => AccentId.orange,
      PaletteId.carbonLime => AccentId.lime,
      PaletteId.steelTeal => AccentId.teal,
      PaletteId.inkPink => AccentId.pink,
      PaletteId.mono => AccentId.silver,
    };
  }

  /// Цвет заливки акцента для образца в настройках.
  static Color accentSwatch(AccentId accent) {
    return switch (accent) {
      AccentId.yellow => AppPalette.yellow,
      AccentId.orange => AppPalette.orange,
      AccentId.lime => AppPalette.lime,
      AccentId.teal => AppPalette.teal,
      AccentId.pink => AppPalette.pink,
      AccentId.silver => AppPalette.silver,
    };
  }

  /// Собирает токены цвета для яркости, палитры и акцента.
  static AppColors resolve(
    Brightness brightness,
    PaletteId palette,
    AccentId? accent,
  ) {
    final accentId = accent ?? defaultAccent(palette);
    final base = brightness == Brightness.dark
        ? _darkBase(palette)
        : AppColors.light;
    final lightMono =
        brightness == Brightness.light && accentId == AccentId.silver;
    return base.copyWith(
      accent: lightMono ? AppPalette.black : accentSwatch(accentId),
      onAccent: lightMono ? AppPalette.white : AppPalette.black,
      accentContent: brightness == Brightness.dark
          ? accentSwatch(accentId)
          : AppPalette.black,
    );
  }

  /// Фон и поверхности тёмной темы для палитры.
  static AppColors _darkBase(PaletteId palette) {
    const dark = AppColors.dark;
    return switch (palette) {
      PaletteId.blackYellow || PaletteId.mono => dark,
      PaletteId.graphiteOrange => dark.copyWith(
        background: AppPalette.graphiteWarm,
        surface: AppPalette.graphiteWarmSurface,
        surfaceHigh: AppPalette.graphiteWarmHigh,
      ),
      PaletteId.carbonLime => dark.copyWith(
        background: AppPalette.carbon,
        surface: AppPalette.carbonSurface,
        surfaceHigh: AppPalette.carbonHigh,
      ),
      PaletteId.steelTeal => dark.copyWith(
        background: AppPalette.steel,
        surface: AppPalette.steelSurface,
        surfaceHigh: AppPalette.steelHigh,
      ),
      PaletteId.inkPink => dark.copyWith(
        background: AppPalette.ink,
        surface: AppPalette.inkSurface,
        surfaceHigh: AppPalette.inkHigh,
      ),
    };
  }
}
