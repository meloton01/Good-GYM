import '../../../core/formatting/measurement_format.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/nickname_policy.dart';
import '../domain/profile_limits.dart';

/// Валидаторы полей профиля с локализованными сообщениями.
abstract final class ProfileValidators {
  /// Проверяет ник после нормализации.
  static String? nickname(AppLocalizations l10n, String? value) {
    return NicknamePolicy.isValid(NicknamePolicy.normalize(value ?? ''))
        ? null
        : l10n.validationNicknameInvalid;
  }

  /// Проверяет длину описания.
  static String? bio(AppLocalizations l10n, String? value) {
    return (value ?? '').trim().length <= ProfileLimits.bioMaxLength
        ? null
        : l10n.validationTextLength(0, ProfileLimits.bioMaxLength);
  }

  /// Проверяет необязательное число в диапазоне [min]..[max] единиц пользователя.
  static String? optionalNumber(
    AppLocalizations l10n,
    String locale,
    String? value, {
    required double min,
    required double max,
  }) {
    final text = (value ?? '').trim();
    if (text.isEmpty) {
      return null;
    }
    final number = MeasurementFormat.parse(text);
    return number != null && number >= min && number <= max
        ? null
        : l10n.validationNumberRange(
            MeasurementFormat.format(min, locale),
            MeasurementFormat.format(max, locale),
          );
  }
}
