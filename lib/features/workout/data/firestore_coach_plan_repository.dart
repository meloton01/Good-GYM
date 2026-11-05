import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/app_limits.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/errors/result.dart';
import '../../../core/firebase/firestore_failure_mapper.dart';
import '../../../core/firebase/offline_write.dart';
import '../domain/coach_limits.dart';
import '../domain/coach_plan.dart';
import '../domain/coach_plan_repository.dart';
import '../domain/plan_comment.dart';
import '../domain/plan_status.dart';
import '../domain/workout_limits.dart';
import '../domain/workout_policy.dart';
import 'coach_plan_data.dart';
import 'coach_plan_mapper.dart';
import 'workout_collections.dart';
import 'workout_fields.dart';

/// Планы в Firestore: users/{athleteId}/plans/{planId} и комментарии в подколлекции comments.
class FirestoreCoachPlanRepository implements CoachPlanRepository {
  /// Создаёт репозиторий поверх экземпляра Firestore.
  FirestoreCoachPlanRepository(this._firestore);

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _plan(String athleteId, String id) =>
      _firestore.plans(athleteId).doc(id);

  CollectionReference<Map<String, dynamic>> _comments(
    String athleteId,
    String planId,
  ) => _plan(athleteId, planId).collection(WorkoutFields.commentsCollection);

  /// Планы ученика от всех тренеров, новые сверху.
  @override
  Stream<List<CoachPlan>> watchAthletePlans(
    String athleteId, {
    int limit = AppLimits.pageSize,
  }) {
    return _watchPlans(
      athleteId,
      _firestore
          .plans(athleteId)
          .orderBy(WorkoutFields.createdAt, descending: true),
      limit,
    );
  }

  /// Планы тренера для ученика, новые сверху.
  @override
  Stream<List<CoachPlan>> watchCoachPlans(
    String coachId,
    String athleteId, {
    int limit = AppLimits.pageSize,
  }) {
    return _watchPlans(
      athleteId,
      _firestore
          .plans(athleteId)
          .where(WorkoutFields.coachId, isEqualTo: coachId)
          .orderBy(WorkoutFields.createdAt, descending: true),
      limit,
    );
  }

  /// Поток плана; удалённый или повреждённый план даёт null.
  @override
  Stream<CoachPlan?> watchPlan(String athleteId, String planId) {
    return _plan(athleteId, planId).snapshots().map((doc) {
      final data = doc.data();
      return data == null
          ? null
          : CoachPlanMapper.planFromMap(doc.id, athleteId, data);
    });
  }

  /// Создаёт план от имени тренера; без сети запись ставится в очередь.
  @override
  Future<Result<void>> createPlan(CoachPlan plan) async {
    if (!_isValid(plan)) {
      return const Failure(AppFailure.invalidInput);
    }
    return writeWithOfflineQueue(
      _plan(plan.athleteId, plan.id).set({
        ...CoachPlanMapper.contentToMap(plan),
        WorkoutFields.coachId: plan.coachId,
        WorkoutFields.coachNickname: plan.coachNickname,
        WorkoutFields.status: PlanStatus.assigned.name,
        WorkoutFields.createdAt: FieldValue.serverTimestamp(),
        WorkoutFields.updatedAt: FieldValue.serverTimestamp(),
      }),
      wait: WorkoutLimits.offlineWriteTimeout,
    );
  }

  /// Меняет содержимое плана.
  @override
  Future<Result<void>> updatePlan(CoachPlan plan) async {
    if (!_isValid(plan)) {
      return const Failure(AppFailure.invalidInput);
    }
    return writeWithOfflineQueue(
      _plan(plan.athleteId, plan.id).update({
        ...CoachPlanMapper.contentToMap(plan),
        WorkoutFields.updatedAt: FieldValue.serverTimestamp(),
      }),
      wait: WorkoutLimits.offlineWriteTimeout,
    );
  }

  /// Удаляет комментарии и сам план.
  @override
  Future<Result<void>> deletePlan(String athleteId, String planId) async {
    try {
      await deletePlanWithComments(_firestore, _plan(athleteId, planId));
      return const Success(null);
    } on FirebaseException catch (error) {
      return Failure(mapFirestoreFailure(error), cause: error);
    }
  }

  /// Отмечает выполнение; без сети запись ставится в очередь.
  @override
  Future<Result<void>> completePlan(
    String athleteId,
    String planId,
    String workoutId,
  ) {
    return writeWithOfflineQueue(
      _plan(athleteId, planId).update({
        WorkoutFields.status: PlanStatus.completed.name,
        WorkoutFields.workoutId: workoutId,
        WorkoutFields.completedAt: FieldValue.serverTimestamp(),
        WorkoutFields.updatedAt: FieldValue.serverTimestamp(),
      }),
      wait: WorkoutLimits.offlineWriteTimeout,
    );
  }

  /// Комментарии, новые сверху; повреждённые пропускаются.
  @override
  Stream<List<PlanComment>> watchComments(
    String athleteId,
    String planId, {
    int limit = AppLimits.pageSize,
  }) {
    return _comments(athleteId, planId)
        .orderBy(WorkoutFields.createdAt, descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CoachPlanMapper.commentFromMap(doc.id, doc.data()))
              .nonNulls
              .toList(),
        );
  }

  /// Добавляет комментарий; без сети запись ставится в очередь.
  @override
  Future<Result<void>> addComment(
    String athleteId,
    String planId, {
    required String authorId,
    required String authorNickname,
    required String text,
  }) async {
    final clean = text.trim();
    if (clean.isEmpty || clean.length > CoachLimits.commentMaxLength) {
      return const Failure(AppFailure.invalidInput);
    }
    return writeWithOfflineQueue(
      _comments(athleteId, planId).doc().set({
        WorkoutFields.authorId: authorId,
        WorkoutFields.authorNickname: authorNickname,
        WorkoutFields.text: clean,
        WorkoutFields.createdAt: FieldValue.serverTimestamp(),
      }),
      wait: WorkoutLimits.offlineWriteTimeout,
    );
  }

  /// Планы ученика с комментариями в виде, пригодном для JSON.
  @override
  Future<Result<List<Map<String, Object?>>>> exportData(
    String athleteId,
  ) async {
    try {
      return Success(await exportPlanData(_firestore, athleteId));
    } on FirebaseException catch (error) {
      return Failure(mapFirestoreFailure(error), cause: error);
    }
  }

  /// Удаляет все планы ученика с комментариями.
  @override
  Future<Result<void>> deleteAllData(String athleteId) async {
    try {
      await deletePlanData(_firestore, athleteId);
      return const Success(null);
    } on FirebaseException catch (error) {
      return Failure(mapFirestoreFailure(error), cause: error);
    }
  }

  /// Поток планов по запросу с ограничением [limit].
  Stream<List<CoachPlan>> _watchPlans(
    String athleteId,
    Query<Map<String, dynamic>> query,
    int limit,
  ) {
    return query
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) =>
                    CoachPlanMapper.planFromMap(doc.id, athleteId, doc.data()),
              )
              .nonNulls
              .toList(),
        );
  }

  /// Подходит ли содержимое плана под ограничения.
  bool _isValid(CoachPlan plan) {
    return WorkoutPolicy.isValidTitle(plan.title) &&
        plan.note.length <= CoachLimits.planNoteMaxLength &&
        WorkoutPolicy.isValidPlan(plan.exercises);
  }
}
