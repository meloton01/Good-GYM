import 'package:flutter/material.dart';

import 'app_spacing.dart';

/// Токены размеров элементов: иконки и минимальная зона нажатия.
@immutable
class AppSizes extends ThemeExtension<AppSizes> {
  /// Создаёт набор размеров.
  const AppSizes({required this.iconLarge, required this.minTouchTarget});

  final double iconLarge;
  final double minTouchTarget;

  /// Размеры по умолчанию.
  static const AppSizes standard = AppSizes(iconLarge: 48, minTouchTarget: 48);

  /// Возвращает копию с заменёнными размерами.
  @override
  AppSizes copyWith({double? iconLarge, double? minTouchTarget}) {
    return AppSizes(
      iconLarge: iconLarge ?? this.iconLarge,
      minTouchTarget: minTouchTarget ?? this.minTouchTarget,
    );
  }

  /// Смешивает размеры двух тем.
  @override
  AppSizes lerp(AppSizes? other, double t) {
    if (other == null) {
      return this;
    }
    return AppSizes(
      iconLarge: AppSpacing.lerpDouble(iconLarge, other.iconLarge, t),
      minTouchTarget: AppSpacing.lerpDouble(
        minTouchTarget,
        other.minTouchTarget,
        t,
      ),
    );
  }
}
