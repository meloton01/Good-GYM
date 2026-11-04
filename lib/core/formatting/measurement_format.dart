import 'package:intl/intl.dart';

/// Форматирование и разбор чисел измерений по локали.
abstract final class MeasurementFormat {
  /// Число с не более чем одним знаком после запятой в формате локали.
  static String format(double value, String locale) {
    return (NumberFormat.decimalPattern(
      locale,
    )..maximumFractionDigits = 1).format(value);
  }

  /// Разбирает ввод с точкой или запятой; null, если это не число.
  static double? parse(String input) {
    return double.tryParse(input.trim().replaceAll(',', '.'));
  }
}
