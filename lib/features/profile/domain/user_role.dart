/// Роль пользователя; coach и moderator выдаёт только администрация.
enum UserRole {
  athlete,
  student,
  coach,
  moderator;

  /// Роли, которые пользователь может выбрать и сменить сам.
  static const List<UserRole> selectable = [athlete, student];
}
