/// Единица веса; данные всегда хранятся в килограммах.
enum WeightUnit {
  kilograms,
  pounds;

  static const double _poundsPerKilogram = 2.2046226218;

  /// Переводит килограммы в эту единицу.
  double fromKilograms(double kilograms) =>
      this == pounds ? kilograms * _poundsPerKilogram : kilograms;

  /// Переводит значение в этой единице в килограммы.
  double toKilograms(double value) =>
      this == pounds ? value / _poundsPerKilogram : value;
}
