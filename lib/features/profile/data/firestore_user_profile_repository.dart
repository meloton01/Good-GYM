import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/errors/app_failure.dart';
import '../../../core/errors/result.dart';
import '../../../core/firebase/firestore_failure_mapper.dart';
import '../domain/user_profile.dart';
import '../domain/user_profile_repository.dart';
import '../domain/user_role.dart';
import 'user_profile_fields.dart';

/// Профили в Firestore: users/{uid} и закрепление ника в nicknames/{nickname}.
class FirestoreUserProfileRepository implements UserProfileRepository {
  /// Создаёт репозиторий поверх экземпляра Firestore.
  FirestoreUserProfileRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection(UserProfileFields.usersCollection);

  CollectionReference<Map<String, dynamic>> get _nicknames =>
      _firestore.collection(UserProfileFields.nicknamesCollection);

  /// Поток профиля; документ с неизвестной ролью даёт ошибку потока.
  @override
  Stream<UserProfile?> watchProfile(String uid) {
    return _users.doc(uid).snapshots().map((snapshot) {
      final data = snapshot.data();
      return data == null ? null : _fromMap(uid, data);
    });
  }

  /// Создаёт профиль и ник в одной транзакции, чтобы ник не заняли дважды.
  @override
  Future<Result<void>> createProfile({
    required String uid,
    required String nickname,
    required UserRole role,
  }) async {
    if (!UserRole.selectable.contains(role)) {
      return const Failure(AppFailure.invalidInput);
    }
    try {
      final taken = await _firestore.runTransaction<bool>((transaction) async {
        final nicknameRef = _nicknames.doc(nickname);
        final nicknameDoc = await transaction.get(nicknameRef);
        final owner = nicknameDoc.data()?[UserProfileFields.ownerUid];
        if (nicknameDoc.exists && owner != uid) {
          return true;
        }
        transaction
          ..set(nicknameRef, {UserProfileFields.ownerUid: uid})
          ..set(_users.doc(uid), {
            UserProfileFields.nickname: nickname,
            UserProfileFields.role: role.name,
            UserProfileFields.createdAt: FieldValue.serverTimestamp(),
            UserProfileFields.updatedAt: FieldValue.serverTimestamp(),
          });
        return false;
      });
      return taken
          ? const Failure(AppFailure.nicknameTaken)
          : const Success(null);
    } on FirebaseException catch (error) {
      return Failure(mapFirestoreFailure(error), cause: error);
    }
  }

  /// Меняет роль; модераторскую роль выставить нельзя.
  @override
  Future<Result<void>> updateRole({
    required String uid,
    required UserRole role,
  }) async {
    if (!UserRole.selectable.contains(role)) {
      return const Failure(AppFailure.invalidInput);
    }
    try {
      await _users.doc(uid).update({
        UserProfileFields.role: role.name,
        UserProfileFields.updatedAt: FieldValue.serverTimestamp(),
      });
      return const Success(null);
    } on FirebaseException catch (error) {
      return Failure(mapFirestoreFailure(error), cause: error);
    }
  }

  /// Собирает профиль из документа Firestore.
  UserProfile _fromMap(String uid, Map<String, dynamic> data) {
    final roleName = data[UserProfileFields.role];
    final role = roleName is String
        ? UserRole.values.asNameMap()[roleName]
        : null;
    final nickname = data[UserProfileFields.nickname];
    if (role == null || nickname is! String) {
      throw const FormatException(
        'users document has invalid nickname or role',
      );
    }
    return UserProfile(uid: uid, nickname: nickname, role: role);
  }
}
