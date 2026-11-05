import '../../l10n/generated/app_localizations.dart';
import '../formatting/measurement_format.dart';

/// Валидаторы числовых полей с локализованными сообщениями.
abstract final class NumberValidators {
  /// Проверяет число в диапазоне [min]..[max]; пустое поле допустимо при [optional].
  static String? number(
    AppLocalizations l10n,
    String locale,
    String? value, {
    required double min,
    required double max,
    bool optional = false,
    bool integer = false,
  }) {
    final text = (value ?? '').trim();
    if (text.isEmpty && optional) {
      return null;
    }
    final number = MeasurementFormat.parse(text);
    final valid =
        number != null &&
        number >= min &&
        number <= max &&
        (!integer || number == number.roundToDouble());
    return valid
        ? null
        : l10n.validationNumberRange(
            MeasurementFormat.format(min, locale),
            MeasurementFormat.format(max, locale),
          );
  }
}
