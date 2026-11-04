import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radii.dart';
import 'app_sizes.dart';
import 'app_spacing.dart';

/// Короткий доступ к токенам темы из BuildContext.
extension ThemeContext on BuildContext {
  /// Цветовые токены текущей темы.
  AppColors get colors => Theme.of(this).extension<AppColors>()!;

  /// Токены отступов текущей темы.
  AppSpacing get spacing => Theme.of(this).extension<AppSpacing>()!;

  /// Токены скруглений текущей темы.
  AppRadii get radii => Theme.of(this).extension<AppRadii>()!;

  /// Токены размеров элементов текущей темы.
  AppSizes get sizes => Theme.of(this).extension<AppSizes>()!;
}
