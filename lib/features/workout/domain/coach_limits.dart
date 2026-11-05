/// Ограничения связи тренер-ученик и планов; те же значения проверяют правила Firestore.
abstract final class CoachLimits {
  /// Сколько активных учеников может быть у тренера.
  static const int maxStudents = 50;

  /// Сколько связей в любом статусе загружается за раз.
  static const int linksQueryLimit = 100;
  static const int commentMaxLength = 500;
  static const int planNoteMaxLength = 1000;

  /// Префикс QR-кода приглашения перед ником.
  static const String qrPrefix = 'goodgym:invite:';
}
