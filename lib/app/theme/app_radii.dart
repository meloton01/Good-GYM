import 'package:flutter/material.dart';

import '../../features/settings/domain/corner_style.dart';
import 'app_spacing.dart';

/// Токены скруглений углов.
@immutable
class AppRadii extends ThemeExtension<AppRadii> {
  /// Создаёт набор скруглений.
  const AppRadii({
    required this.small,
    required this.medium,
    required this.large,
  });

  final double small;
  final double medium;
  final double large;

  /// Скругления по умолчанию.
  static const AppRadii standard = AppRadii(small: 8, medium: 12, large: 16);

  static const AppRadii _sharp = AppRadii(small: 4, medium: 6, large: 8);
  static const AppRadii _round = AppRadii(small: 12, medium: 20, large: 28);

  /// Скругления для стиля из настроек.
  static AppRadii forStyle(CornerStyle style) {
    return switch (style) {
      CornerStyle.sharp => _sharp,
      CornerStyle.standard => standard,
      CornerStyle.round => _round,
    };
  }

  /// Возвращает копию с заменёнными скруглениями.
  @override
  AppRadii copyWith({double? small, double? medium, double? large}) {
    return AppRadii(
      small: small ?? this.small,
      medium: medium ?? this.medium,
      large: large ?? this.large,
    );
  }

  /// Смешивает скругления двух тем.
  @override
  AppRadii lerp(AppRadii? other, double t) {
    if (other == null) {
      return this;
    }
    return AppRadii(
      small: AppSpacing.lerpDouble(small, other.small, t),
      medium: AppSpacing.lerpDouble(medium, other.medium, t),
      large: AppSpacing.lerpDouble(large, other.large, t),
    );
  }
}
