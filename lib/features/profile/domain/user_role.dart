/// Роль пользователя; moderator выдаётся только вручную через админ-инструмент.
enum UserRole {
  athlete,
  student,
  coach,
  moderator;

  /// Роли, которые пользователь может выбрать сам.
  static const List<UserRole> selectable = [athlete, student, coach];
}
