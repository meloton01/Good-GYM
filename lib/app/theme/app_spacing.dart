import 'package:flutter/material.dart';

/// Токены отступов; шкала кратна 4 dp.
@immutable
class AppSpacing extends ThemeExtension<AppSpacing> {
  /// Создаёт набор отступов.
  const AppSpacing({
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
  });

  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;

  /// Стандартная шкала отступов.
  static const AppSpacing standard = AppSpacing(
    xs: 4,
    sm: 8,
    md: 16,
    lg: 24,
    xl: 32,
  );

  /// Возвращает копию с заменёнными отступами.
  @override
  AppSpacing copyWith({
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? xl,
  }) {
    return AppSpacing(
      xs: xs ?? this.xs,
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
    );
  }

  /// Смешивает отступы двух тем.
  @override
  AppSpacing lerp(AppSpacing? other, double t) {
    if (other == null) {
      return this;
    }
    return AppSpacing(
      xs: lerpDouble(xs, other.xs, t),
      sm: lerpDouble(sm, other.sm, t),
      md: lerpDouble(md, other.md, t),
      lg: lerpDouble(lg, other.lg, t),
      xl: lerpDouble(xl, other.xl, t),
    );
  }

  /// Линейная интерполяция без nullable-результата.
  static double lerpDouble(double a, double b, double t) => a + (b - a) * t;
}
