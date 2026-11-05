import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/errors/app_failure.dart';
import '../../../core/errors/result.dart';
import '../../../core/firebase/firestore_failure_mapper.dart';
import '../../../core/firebase/json_safe.dart';
import '../../profile/domain/nickname_policy.dart';
import '../../profile/domain/user_profile.dart';
import '../../profile/domain/user_role.dart';
import '../domain/coach_limits.dart';
import '../domain/coach_link.dart';
import '../domain/coach_link_repository.dart';
import '../domain/coach_link_status.dart';
import 'coach_link_mapper.dart';
import 'workout_collections.dart';
import 'workout_fields.dart';

/// Связи в Firestore: coachLinks, замок studentCoach и счётчик coachStudents меняются одной транзакцией.
class FirestoreCoachLinkRepository implements CoachLinkRepository {
  /// Создаёт репозиторий поверх экземпляра Firestore.
  FirestoreCoachLinkRepository(this._firestore);

  final FirebaseFirestore _firestore;

  /// Поток связей одной стороны; повреждённые пропускаются.
  @override
  Stream<List<CoachLink>> watchLinks(String uid, {required bool asCoach}) {
    return _firestore.coachLinks
        .where(
          asCoach ? WorkoutFields.coachId : WorkoutFields.athleteId,
          isEqualTo: uid,
        )
        .limit(CoachLimits.linksQueryLimit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CoachLinkMapper.fromMap(doc.id, doc.data()))
              .nonNulls
              .toList(),
        );
  }

  /// Находит пользователя по нику и создаёт или возобновляет приглашение.
  @override
  Future<Result<void>> invite({
    required UserProfile me,
    required String nickname,
  }) async {
    final target = NicknamePolicy.normalize(nickname);
    if (!NicknamePolicy.isValid(target) || target == me.nickname) {
      return const Failure(AppFailure.invalidInput);
    }
    final asCoach = me.role == UserRole.coach;
    if (!asCoach && me.role != UserRole.student) {
      return const Failure(AppFailure.inviteUnavailable);
    }
    return _run(AppFailure.inviteUnavailable, () async {
      final owner = await _firestore
          .collection(WorkoutFields.nicknamesCollection)
          .doc(target)
          .get();
      final targetId = owner.data()?[WorkoutFields.uid];
      if (targetId is! String) {
        return const Failure(AppFailure.userNotFound);
      }
      final coachId = asCoach ? me.uid : targetId;
      final athleteId = asCoach ? targetId : me.uid;
      final ref = _firestore.coachLinks.doc(
        CoachLink.idFor(coachId, athleteId),
      );
      return _firestore.runTransaction((transaction) async {
        final current = await transaction.get(ref);
        final status = current.data()?[WorkoutFields.status];
        if (status == CoachLinkStatus.active.name) {
          return const Failure<void>(AppFailure.alreadyLinked);
        }
        if (status == CoachLinkStatus.pending.name) {
          return const Failure<void>(AppFailure.alreadyInvited);
        }
        final fields = {
          WorkoutFields.status: CoachLinkStatus.pending.name,
          WorkoutFields.invitedBy: me.uid,
          WorkoutFields.coachNickname: asCoach ? me.nickname : target,
          WorkoutFields.athleteNickname: asCoach ? target : me.nickname,
          WorkoutFields.updatedAt: FieldValue.serverTimestamp(),
        };
        current.exists
            ? transaction.update(ref, fields)
            : transaction.set(ref, {
                ...fields,
                WorkoutFields.coachId: coachId,
                WorkoutFields.athleteId: athleteId,
                WorkoutFields.createdAt: FieldValue.serverTimestamp(),
              });
        return const Success<void>(null);
      });
    });
  }

  /// Делает связь активной, ставит замок ученика и увеличивает счётчик тренера.
  @override
  Future<Result<void>> accept(CoachLink link) {
    return _run(AppFailure.linkUnavailable, () {
      return _firestore.runTransaction((transaction) async {
        final counter = _firestore.coachStudents(link.coachId);
        final count = await _count(transaction, counter);
        if (count >= CoachLimits.maxStudents) {
          return const Failure<void>(AppFailure.coachLimitReached);
        }
        transaction
          ..update(_firestore.coachLinks.doc(link.id), {
            WorkoutFields.status: CoachLinkStatus.active.name,
            WorkoutFields.updatedAt: FieldValue.serverTimestamp(),
          })
          ..set(_firestore.studentCoach(link.athleteId), {
            WorkoutFields.coachId: link.coachId,
            WorkoutFields.linkId: link.id,
          })
          ..set(counter, {
            WorkoutFields.count: count + 1,
            WorkoutFields.linkId: link.id,
          });
        return const Success<void>(null);
      });
    });
  }

  /// Удаляет неактивную связь: отклонённое, отозванное или завершённое приглашение.
  @override
  Future<Result<void>> remove(CoachLink link) {
    return _run(AppFailure.permissionDenied, () async {
      await _firestore.coachLinks.doc(link.id).delete();
      return const Success(null);
    });
  }

  /// Завершает связь, снимает замок ученика и уменьшает счётчик тренера.
  @override
  Future<Result<void>> end(CoachLink link) {
    return _run(AppFailure.permissionDenied, () {
      return _firestore.runTransaction((transaction) async {
        final counter = _firestore.coachStudents(link.coachId);
        final count = await _count(transaction, counter);
        transaction
          ..update(_firestore.coachLinks.doc(link.id), {
            WorkoutFields.status: CoachLinkStatus.ended.name,
            WorkoutFields.updatedAt: FieldValue.serverTimestamp(),
          })
          ..delete(_firestore.studentCoach(link.athleteId))
          ..set(counter, {
            WorkoutFields.count: count > 0 ? count - 1 : 0,
            WorkoutFields.linkId: link.id,
          });
        return const Success<void>(null);
      });
    });
  }

  /// Связи пользователя с обеих сторон в виде, пригодном для JSON.
  @override
  Future<Result<List<Map<String, Object?>>>> exportData(String uid) {
    return _run(AppFailure.permissionDenied, () async {
      final docs = await _allLinks(uid);
      return Success([
        for (final doc in docs)
          {'id': doc.id, ...?jsonSafe(doc.data()) as Map<String, dynamic>?},
      ]);
    });
  }

  /// Разрывает активные связи и удаляет все документы связей пользователя.
  @override
  Future<Result<void>> deleteAllData(String uid) {
    return _run(AppFailure.permissionDenied, () async {
      for (final doc in await _allLinks(uid)) {
        final link = CoachLinkMapper.fromMap(doc.id, doc.data());
        if (link != null && link.status == CoachLinkStatus.active) {
          final ended = await end(link);
          if (ended is Failure<void>) {
            return ended;
          }
        }
        await doc.reference.delete();
      }
      return const Success(null);
    });
  }

  /// Документы связей, где пользователь тренер или ученик.
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> _allLinks(
    String uid,
  ) async {
    final asCoach = await _firestore.coachLinks
        .where(WorkoutFields.coachId, isEqualTo: uid)
        .get();
    final asAthlete = await _firestore.coachLinks
        .where(WorkoutFields.athleteId, isEqualTo: uid)
        .get();
    return [...asCoach.docs, ...asAthlete.docs];
  }

  /// Читает число активных учеников тренера внутри транзакции.
  Future<int> _count(
    Transaction transaction,
    DocumentReference<Map<String, dynamic>> counter,
  ) async {
    final value = (await transaction.get(counter)).data()?[WorkoutFields.count];
    return value is int ? value : 0;
  }

  /// Выполняет операцию; отказ правил превращает в [denied] с понятным пользователю смыслом.
  Future<Result<T>> _run<T>(
    AppFailure denied,
    Future<Result<T>> Function() action,
  ) async {
    try {
      return await action();
    } on FirebaseException catch (error) {
      final failure = mapFirestoreFailure(error);
      return Failure(
        failure == AppFailure.permissionDenied ? denied : failure,
        cause: error,
      );
    }
  }
}
