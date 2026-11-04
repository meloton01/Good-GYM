/// Ограничения названия и города зала; совпадают с firestore.rules.
abstract final class GymPolicy {
  static const int minLength = 2;
  static const int maxLength = 60;

  /// Проверяет длину названия или города после обрезки пробелов.
  static bool isValidText(String value) {
    final length = value.trim().length;
    return length >= minLength && length <= maxLength;
  }
}
