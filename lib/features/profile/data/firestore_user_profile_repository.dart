import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/errors/app_failure.dart';
import '../../../core/errors/result.dart';
import '../../../core/firebase/firestore_failure_mapper.dart';
import '../../../core/firebase/json_safe.dart';
import '../domain/body_metrics.dart';
import '../domain/profile_visibility.dart';
import '../domain/user_profile.dart';
import '../domain/user_profile_repository.dart';
import '../domain/user_role.dart';
import 'user_profile_fields.dart';
import 'user_profile_mapper.dart';

/// Профили в Firestore: users/{uid}, ник в nicknames/{nickname}, тело в users/{uid}/private/body.
class FirestoreUserProfileRepository implements UserProfileRepository {
  /// Создаёт репозиторий поверх экземпляра Firestore.
  FirestoreUserProfileRepository(this._firestore);

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _user(String uid) =>
      _firestore.collection(UserProfileFields.usersCollection).doc(uid);

  DocumentReference<Map<String, dynamic>> _nickname(String nickname) =>
      _firestore
          .collection(UserProfileFields.nicknamesCollection)
          .doc(nickname);

  DocumentReference<Map<String, dynamic>> _body(String uid) =>
      _user(uid)
          .collection(UserProfileFields.privateCollection)
          .doc(UserProfileFields.bodyDocument);

  /// Поток профиля; повреждённый документ даёт ошибку потока.
  @override
  Stream<UserProfile?> watchProfile(String uid) {
    return _user(uid).snapshots().map((snapshot) {
      final data = snapshot.data();
      return data == null ? null : UserProfileMapper.fromMap(uid, data);
    });
  }

  /// Создаёт профиль и ник в одной транзакции, чтобы ник не заняли дважды.
  @override
  Future<Result<void>> createProfile({
    required String uid,
    required String nickname,
    required UserRole role,
  }) {
    if (!UserRole.selectable.contains(role)) {
      return Future.value(const Failure(AppFailure.invalidInput));
    }
    return _transaction((transaction) async {
      if (await _isTakenByOther(transaction, nickname, uid)) {
        return true;
      }
      transaction
        ..set(_nickname(nickname), {UserProfileFields.ownerUid: uid})
        ..set(_user(uid), {
          UserProfileFields.nickname: nickname,
          UserProfileFields.role: role.name,
          UserProfileFields.bio: '',
          UserProfileFields.profileVisibility: ProfileVisibility.everyone.name,
          UserProfileFields.recordsVisibility: ProfileVisibility.everyone.name,
          UserProfileFields.createdAt: FieldValue.serverTimestamp(),
          UserProfileFields.updatedAt: FieldValue.serverTimestamp(),
        });
      return false;
    });
  }

  /// Сохраняет профиль; новый ник закрепляется, старый освобождается в той же транзакции.
  @override
  Future<Result<void>> updateProfile(UserProfile profile) {
    return _transaction((transaction) async {
      final current = await transaction.get(_user(profile.uid));
      final oldNickname = current.data()?[UserProfileFields.nickname];
      final nicknameChanged = oldNickname != profile.nickname;
      if (nicknameChanged &&
          await _isTakenByOther(transaction, profile.nickname, profile.uid)) {
        return true;
      }
      if (nicknameChanged && oldNickname is String) {
        transaction
          ..delete(_nickname(oldNickname))
          ..set(_nickname(profile.nickname), {
            UserProfileFields.ownerUid: profile.uid,
          });
      }
      transaction.update(_user(profile.uid), {
        ...UserProfileMapper.editableFields(profile),
        UserProfileFields.updatedAt: FieldValue.serverTimestamp(),
      });
      return false;
    });
  }

  /// Меняет роль; модераторскую роль выставить нельзя.
  @override
  Future<Result<void>> updateRole({
    required String uid,
    required UserRole role,
  }) {
    if (!UserRole.selectable.contains(role)) {
      return Future.value(const Failure(AppFailure.invalidInput));
    }
    return _write(
      () => _user(uid).update({
        UserProfileFields.role: role.name,
        UserProfileFields.updatedAt: FieldValue.serverTimestamp(),
      }),
    );
  }

  /// Поток данных о теле; пока документа нет, данные пустые.
  @override
  Stream<BodyMetrics> watchBodyMetrics(String uid) {
    return _body(uid)
        .snapshots()
        .map((doc) => UserProfileMapper.bodyFromMap(doc.data()));
  }

  /// Сохраняет данные о теле целиком.
  @override
  Future<Result<void>> saveBodyMetrics(String uid, BodyMetrics metrics) {
    return _write(() => _body(uid).set(UserProfileMapper.bodyToMap(metrics)));
  }

  /// Читает профиль и данные о теле в виде, пригодном для JSON.
  @override
  Future<Result<Map<String, Object?>>> exportData(String uid) async {
    try {
      final user = await _user(uid).get();
      final body = await _body(uid).get();
      return Success({
        'uid': uid,
        'profile': jsonSafe(user.data()),
        'body': jsonSafe(body.data()),
      });
    } on FirebaseException catch (error) {
      return Failure(mapFirestoreFailure(error), cause: error);
    }
  }

  /// Удаляет тело, ник и профиль одним батчем.
  @override
  Future<Result<void>> deleteAllData(String uid) async {
    try {
      final user = await _user(uid).get();
      final nickname = user.data()?[UserProfileFields.nickname];
      final batch = _firestore.batch()..delete(_body(uid));
      if (nickname is String) {
        batch.delete(_nickname(nickname));
      }
      batch.delete(_user(uid));
      await batch.commit();
      return const Success(null);
    } on FirebaseException catch (error) {
      return Failure(mapFirestoreFailure(error), cause: error);
    }
  }

  /// Проверяет, закреплён ли ник за другим пользователем.
  Future<bool> _isTakenByOther(
    Transaction transaction,
    String nickname,
    String uid,
  ) async {
    final doc = await transaction.get(_nickname(nickname));
    return doc.exists && doc.data()?[UserProfileFields.ownerUid] != uid;
  }

  /// Выполняет транзакцию, которая возвращает true, если ник занят.
  Future<Result<void>> _transaction(
    Future<bool> Function(Transaction transaction) body,
  ) async {
    try {
      final taken = await _firestore.runTransaction<bool>(body);
      return taken
          ? const Failure(AppFailure.nicknameTaken)
          : const Success(null);
    } on FirebaseException catch (error) {
      return Failure(mapFirestoreFailure(error), cause: error);
    }
  }

  /// Выполняет запись и переводит ошибку Firestore в [AppFailure].
  Future<Result<void>> _write(Future<void> Function() action) async {
    try {
      await action();
      return const Success(null);
    } on FirebaseException catch (error) {
      return Failure(mapFirestoreFailure(error), cause: error);
    }
  }
}
