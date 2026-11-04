import 'package:flutter/material.dart';

import 'app_spacing.dart';

/// Токены размеров элементов: иконки, зона нажатия, ширина форм.
@immutable
class AppSizes extends ThemeExtension<AppSizes> {
  /// Создаёт набор размеров.
  const AppSizes({
    required this.iconLarge,
    required this.minTouchTarget,
    required this.formMaxWidth,
    required this.progressStrokeWidth,
  });

  final double iconLarge;
  final double minTouchTarget;

  /// Максимальная ширина форм на широких экранах.
  final double formMaxWidth;
  final double progressStrokeWidth;

  /// Размеры по умолчанию.
  static const AppSizes standard = AppSizes(
    iconLarge: 48,
    minTouchTarget: 48,
    formMaxWidth: 480,
    progressStrokeWidth: 2,
  );

  /// Возвращает копию с заменёнными размерами.
  @override
  AppSizes copyWith({
    double? iconLarge,
    double? minTouchTarget,
    double? formMaxWidth,
    double? progressStrokeWidth,
  }) {
    return AppSizes(
      iconLarge: iconLarge ?? this.iconLarge,
      minTouchTarget: minTouchTarget ?? this.minTouchTarget,
      formMaxWidth: formMaxWidth ?? this.formMaxWidth,
      progressStrokeWidth: progressStrokeWidth ?? this.progressStrokeWidth,
    );
  }

  /// Смешивает размеры двух тем.
  @override
  AppSizes lerp(AppSizes? other, double t) {
    if (other == null) {
      return this;
    }
    double mix(double a, double b) => AppSpacing.lerpDouble(a, b, t);
    return AppSizes(
      iconLarge: mix(iconLarge, other.iconLarge),
      minTouchTarget: mix(minTouchTarget, other.minTouchTarget),
      formMaxWidth: mix(formMaxWidth, other.formMaxWidth),
      progressStrokeWidth: mix(progressStrokeWidth, other.progressStrokeWidth),
    );
  }
}
