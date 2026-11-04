/// Правила проверки email и пароля, общие для клиента и сервера.
abstract final class CredentialPolicy {
  /// Минимальная длина пароля.
  static const int minPasswordLength = 8;

  static final RegExp _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  /// Проверяет, похоже ли значение на email.
  static bool isValidEmail(String value) => _emailPattern.hasMatch(value);

  /// Проверяет минимальную длину пароля.
  static bool isValidPassword(String value) =>
      value.length >= minPasswordLength;
}
