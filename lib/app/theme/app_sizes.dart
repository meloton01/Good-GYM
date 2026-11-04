import 'package:flutter/material.dart';

import 'app_spacing.dart';

/// Токены размеров элементов: иконки, аватар, зона нажатия, ширина форм.
@immutable
class AppSizes extends ThemeExtension<AppSizes> {
  /// Создаёт набор размеров.
  const AppSizes({
    required this.iconLarge,
    required this.avatarLarge,
    required this.minTouchTarget,
    required this.formMaxWidth,
    required this.progressStrokeWidth,
    required this.selectionBorderWidth,
    required this.fabClearance,
    required this.chartAspectRatio,
    required this.chartAxisReserved,
    required this.chartLineWidth,
    required this.chartDotRadius,
  });

  final double iconLarge;
  final double avatarLarge;

  /// Минимальная зона нажатия; также размер образца цвета.
  final double minTouchTarget;

  /// Максимальная ширина форм на широких экранах.
  final double formMaxWidth;
  final double progressStrokeWidth;

  /// Толщина рамки выбранного образца.
  final double selectionBorderWidth;

  /// Отступ под списком, чтобы плавающая кнопка не закрывала последний пункт.
  final double fabClearance;

  /// Соотношение сторон графика прогресса.
  final double chartAspectRatio;

  /// Место под подписи осей графика до масштабирования шрифта.
  final double chartAxisReserved;
  final double chartLineWidth;
  final double chartDotRadius;

  /// Размеры по умолчанию.
  static const AppSizes standard = AppSizes(
    iconLarge: 48,
    avatarLarge: 72,
    minTouchTarget: 48,
    formMaxWidth: 480,
    progressStrokeWidth: 2,
    selectionBorderWidth: 3,
    fabClearance: 88,
    chartAspectRatio: 1.6,
    chartAxisReserved: 40,
    chartLineWidth: 3,
    chartDotRadius: 4,
  );

  /// Возвращает копию с заменёнными размерами.
  @override
  AppSizes copyWith({
    double? iconLarge,
    double? avatarLarge,
    double? minTouchTarget,
    double? formMaxWidth,
    double? progressStrokeWidth,
    double? selectionBorderWidth,
    double? fabClearance,
    double? chartAspectRatio,
    double? chartAxisReserved,
    double? chartLineWidth,
    double? chartDotRadius,
  }) {
    return AppSizes(
      iconLarge: iconLarge ?? this.iconLarge,
      avatarLarge: avatarLarge ?? this.avatarLarge,
      minTouchTarget: minTouchTarget ?? this.minTouchTarget,
      formMaxWidth: formMaxWidth ?? this.formMaxWidth,
      progressStrokeWidth: progressStrokeWidth ?? this.progressStrokeWidth,
      selectionBorderWidth: selectionBorderWidth ?? this.selectionBorderWidth,
      fabClearance: fabClearance ?? this.fabClearance,
      chartAspectRatio: chartAspectRatio ?? this.chartAspectRatio,
      chartAxisReserved: chartAxisReserved ?? this.chartAxisReserved,
      chartLineWidth: chartLineWidth ?? this.chartLineWidth,
      chartDotRadius: chartDotRadius ?? this.chartDotRadius,
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
      avatarLarge: mix(avatarLarge, other.avatarLarge),
      minTouchTarget: mix(minTouchTarget, other.minTouchTarget),
      formMaxWidth: mix(formMaxWidth, other.formMaxWidth),
      progressStrokeWidth: mix(progressStrokeWidth, other.progressStrokeWidth),
      selectionBorderWidth: mix(
        selectionBorderWidth,
        other.selectionBorderWidth,
      ),
      fabClearance: mix(fabClearance, other.fabClearance),
      chartAspectRatio: mix(chartAspectRatio, other.chartAspectRatio),
      chartAxisReserved: mix(chartAxisReserved, other.chartAxisReserved),
      chartLineWidth: mix(chartLineWidth, other.chartLineWidth),
      chartDotRadius: mix(chartDotRadius, other.chartDotRadius),
    );
  }
}
