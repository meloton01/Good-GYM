/// Имена коллекций и полей профиля в Firestore; совпадают с firestore.rules.
abstract final class UserProfileFields {
  static const String usersCollection = 'users';
  static const String nicknamesCollection = 'nicknames';

  static const String nickname = 'nickname';
  static const String role = 'role';
  static const String createdAt = 'createdAt';
  static const String updatedAt = 'updatedAt';

  /// Поле документа nicknames/{nickname} с uid владельца.
  static const String ownerUid = 'uid';
}
