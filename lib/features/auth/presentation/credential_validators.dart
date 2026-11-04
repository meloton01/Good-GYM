import '../../../l10n/generated/app_localizations.dart';
import '../domain/credential_policy.dart';

/// Валидаторы полей форм входа и регистрации с локализованными сообщениями.
abstract final class CredentialValidators {
  /// Проверяет email: не пустой и похож на адрес.
  static String? email(AppLocalizations l10n, String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return l10n.validationRequired;
    }
    return CredentialPolicy.isValidEmail(email)
        ? null
        : l10n.validationEmailInvalid;
  }

  /// Проверяет, что пароль введён; длину при входе не проверяем.
  static String? requiredPassword(AppLocalizations l10n, String? value) {
    return (value ?? '').isEmpty ? l10n.validationRequired : null;
  }

  /// Проверяет пароль при регистрации: минимальная длина.
  static String? newPassword(AppLocalizations l10n, String? value) {
    final password = value ?? '';
    if (password.isEmpty) {
      return l10n.validationRequired;
    }
    return CredentialPolicy.isValidPassword(password)
        ? null
        : l10n.validationPasswordTooShort(CredentialPolicy.minPasswordLength);
  }
}
