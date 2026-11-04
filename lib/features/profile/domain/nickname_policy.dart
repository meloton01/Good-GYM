/// Правила ника: 3-20 символов a-z, 0-9, _ и точка; совпадают с firestore.rules.
abstract final class NicknamePolicy {
  static final RegExp _pattern = RegExp(r'^[a-z0-9_.]{3,20}$');

  /// Приводит ввод к виду, в котором ник хранится: без пробелов, в нижнем регистре.
  static String normalize(String value) => value.trim().toLowerCase();

  /// Проверяет уже нормализованный ник.
  static bool isValid(String nickname) => _pattern.hasMatch(nickname);
}
