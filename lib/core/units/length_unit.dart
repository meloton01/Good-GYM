/// Единица длины для роста; данные всегда хранятся в сантиметрах.
enum LengthUnit {
  centimeters,
  inches;

  static const double _centimetersPerInch = 2.54;

  /// Переводит сантиметры в эту единицу.
  double fromCentimeters(double centimeters) =>
      this == inches ? centimeters / _centimetersPerInch : centimeters;

  /// Переводит значение в этой единице в сантиметры.
  double toCentimeters(double value) =>
      this == inches ? value * _centimetersPerInch : value;
}
