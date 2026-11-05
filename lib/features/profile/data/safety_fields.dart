/// Имена коллекций и полей жалоб и блокировок в Firestore; совпадают с firestore.rules.
abstract final class SafetyFields {
  /// Подколлекция users/{uid}/blocks, id документа равен uid заблокированного.
  static const String blocksCollection = 'blocks';
  static const String reportsCollection = 'reports';

  static const String nickname = 'nickname';
  static const String createdAt = 'createdAt';

  static const String reporterId = 'reporterId';
  static const String targetUid = 'targetUid';
  static const String recordId = 'recordId';
  static const String reason = 'reason';
  static const String comment = 'comment';
  static const String status = 'status';

  /// Статус новой жалобы до разбора модератором.
  static const String openStatus = 'open';
}
