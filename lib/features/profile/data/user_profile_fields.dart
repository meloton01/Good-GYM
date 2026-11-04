/// Имена коллекций и полей профиля в Firestore; совпадают с firestore.rules.
abstract final class UserProfileFields {
  static const String usersCollection = 'users';
  static const String nicknamesCollection = 'nicknames';

  /// Подколлекция users/{uid}/private, документ body.
  static const String privateCollection = 'private';
  static const String bodyDocument = 'body';

  static const String nickname = 'nickname';
  static const String role = 'role';
  static const String bio = 'bio';
  static const String gymId = 'gymId';
  static const String gymName = 'gymName';
  static const String profileVisibility = 'profileVisibility';
  static const String recordsVisibility = 'recordsVisibility';
  static const String createdAt = 'createdAt';
  static const String updatedAt = 'updatedAt';

  static const String weightKg = 'weightKg';
  static const String heightCm = 'heightCm';

  /// Поле документа nicknames/{nickname} с uid владельца.
  static const String ownerUid = 'uid';
}
