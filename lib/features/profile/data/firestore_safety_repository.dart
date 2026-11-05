import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/app_limits.dart';
import '../../../core/errors/result.dart';
import '../../../core/firebase/delete_in_chunks.dart';
import '../../../core/firebase/firestore_date.dart';
import '../../../core/firebase/firestore_failure_mapper.dart';
import '../../../core/firebase/firestore_page.dart';
import '../../../core/firebase/json_safe.dart';
import '../../../core/pagination/paged_result.dart';
import '../domain/blocked_user.dart';
import '../domain/safety_repository.dart';
import '../domain/user_report.dart';
import 'safety_fields.dart';
import 'user_profile_fields.dart';

/// Жалобы и блокировки в Firestore.
class FirestoreSafetyRepository implements SafetyRepository {
  /// Создаёт репозиторий поверх [_firestore].
  FirestoreSafetyRepository(this._firestore);

  final FirebaseFirestore _firestore;

  /// Блокировки пользователя [uid].
  CollectionReference<Map<String, dynamic>> _blocks(String uid) => _firestore
      .collection(UserProfileFields.usersCollection)
      .doc(uid)
      .collection(SafetyFields.blocksCollection);

  /// Жалобы, отправленные пользователем [uid].
  Query<Map<String, dynamic>> _reportsBy(String uid) => _firestore
      .collection(SafetyFields.reportsCollection)
      .where(SafetyFields.reporterId, isEqualTo: uid);

  /// Поток наличия документа блокировки.
  @override
  Stream<bool> watchIsBlocked({required String uid, required String otherUid}) {
    return _blocks(uid).doc(otherUid).snapshots().map((doc) => doc.exists);
  }

  /// Страница блокировок по дате, новые сверху.
  @override
  Future<Result<PagedResult<BlockedUser>>> fetchBlocked(
    String uid, {
    String? cursor,
    int limit = AppLimits.pageSize,
  }) {
    final blocks = _blocks(uid);
    return fetchFirestorePage(
      blocks.orderBy(SafetyFields.createdAt, descending: true),
      blocks,
      cursor: cursor,
      limit: limit,
      map: (doc) => switch (doc.data()[SafetyFields.nickname]) {
        final String nickname => BlockedUser(
          uid: doc.id,
          nickname: nickname,
          blockedAt: readFirestoreDate(doc.data()[SafetyFields.createdAt]),
        ),
        _ => null,
      },
    );
  }

  /// Создаёт документ блокировки с ником пользователя.
  @override
  Future<Result<void>> block(String uid, BlockedUser user) {
    return _write(
      () => _blocks(uid).doc(user.uid).set({
        SafetyFields.nickname: user.nickname,
        SafetyFields.createdAt: FieldValue.serverTimestamp(),
      }),
    );
  }

  /// Удаляет документ блокировки.
  @override
  Future<Result<void>> unblock({
    required String uid,
    required String otherUid,
  }) {
    return _write(() => _blocks(uid).doc(otherUid).delete());
  }

  /// Создаёт жалобу, если от автора её ещё нет; повтор считается успехом.
  @override
  Future<Result<void>> report(UserReport report) {
    final doc = _firestore
        .collection(SafetyFields.reportsCollection)
        .doc(report.id);
    return _write(
      () => _firestore.runTransaction((transaction) async {
        if ((await transaction.get(doc)).exists) {
          return;
        }
        transaction.set(doc, {
          SafetyFields.reporterId: report.reporterId,
          SafetyFields.targetUid: report.targetUid,
          SafetyFields.recordId: ?report.recordId,
          SafetyFields.reason: report.reason.name,
          SafetyFields.comment: report.comment,
          SafetyFields.status: SafetyFields.openStatus,
          SafetyFields.createdAt: FieldValue.serverTimestamp(),
        });
      }),
    );
  }

  /// Читает блокировки и жалобы пользователя в виде, пригодном для JSON.
  @override
  Future<Result<Map<String, Object?>>> exportData(String uid) async {
    try {
      final blocks = await _blocks(uid).get();
      final reports = await _reportsBy(uid).get();
      return Success({
        'blocks': [
          for (final doc in blocks.docs)
            {'uid': doc.id, ...?jsonSafe(doc.data()) as Map<String, dynamic>?},
        ],
        'reports': [
          for (final doc in reports.docs)
            {'id': doc.id, ...?jsonSafe(doc.data()) as Map<String, dynamic>?},
        ],
      });
    } on FirebaseException catch (error) {
      return Failure(mapFirestoreFailure(error), cause: error);
    }
  }

  /// Удаляет блокировки и жалобы пользователя пачками.
  @override
  Future<Result<void>> deleteAllData(String uid) {
    return _write(() async {
      await deleteInChunks(_firestore, _blocks(uid));
      await deleteInChunks(_firestore, _reportsBy(uid));
    });
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
