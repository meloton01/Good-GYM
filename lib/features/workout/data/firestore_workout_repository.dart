import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/app_limits.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/errors/result.dart';
import '../../../core/firebase/firestore_failure_mapper.dart';
import '../../../core/firebase/offline_write.dart';
import '../../../core/pagination/paged_result.dart';
import '../domain/personal_record.dart';
import '../domain/personal_records.dart';
import '../domain/workout.dart';
import '../domain/workout_limits.dart';
import '../domain/workout_policy.dart';
import '../domain/workout_repository.dart';
import 'personal_record_mapper.dart';
import 'workout_collections.dart';
import 'workout_fields.dart';
import 'workout_mapper.dart';
import 'workout_user_data.dart';

/// Тренировки в Firestore: users/{uid}/workouts и users/{uid}/personalRecords.
///
/// Офлайн-режим даёт кэш Firestore: чтение без сети идёт из кэша, запись ставится в очередь.
class FirestoreWorkoutRepository implements WorkoutRepository {
  /// Создаёт репозиторий поверх экземпляра Firestore.
  FirestoreWorkoutRepository(this._firestore);

  final FirebaseFirestore _firestore;

  /// Страница истории по дате завершения, новые сверху.
  @override
  Future<Result<PagedResult<Workout>>> fetchHistory(
    String ownerId, {
    String? cursor,
    int limit = AppLimits.pageSize,
  }) {
    return _guard(() async {
      final workouts = _firestore.workouts(ownerId);
      var query = workouts.orderBy(WorkoutFields.finishedAt, descending: true);
      if (cursor != null) {
        query = query.startAfterDocument(await workouts.doc(cursor).get());
      }
      final snapshot = await query.limit(limit).get();
      return PagedResult(
        items: _parse(ownerId, snapshot.docs),
        nextCursor: snapshot.docs.length == limit
            ? snapshot.docs.last.id
            : null,
      );
    });
  }

  /// Одна тренировка по id.
  @override
  Future<Result<Workout>> fetchWorkout(String ownerId, String workoutId) async {
    try {
      final doc = await _firestore.workouts(ownerId).doc(workoutId).get();
      final data = doc.data();
      final workout = data == null
          ? null
          : WorkoutMapper.workoutFromMap(doc.id, ownerId, data);
      return workout == null
          ? const Failure(AppFailure.notFound)
          : Success(workout);
    } on FirebaseException catch (error) {
      return Failure(mapFirestoreFailure(error), cause: error);
    }
  }

  /// Последние тренировки с упражнением.
  @override
  Future<Result<List<Workout>>> fetchExerciseHistory(
    String ownerId,
    String exerciseId, {
    int limit = WorkoutLimits.progressPoints,
  }) {
    return _guard(() async {
      final snapshot = await _withExercise(
        ownerId,
        exerciseId,
      ).limit(limit).get();
      return _parse(ownerId, snapshot.docs);
    });
  }

  /// Поток рекордов; повреждённые документы пропускаются.
  @override
  Stream<List<PersonalRecord>> watchPersonalRecords(String ownerId) {
    return _firestore
        .personalRecords(ownerId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => PersonalRecordMapper.fromMap(doc.data()))
              .nonNulls
              .toList(),
        );
  }

  /// Пишет тренировку и рекорды одним батчем.
  @override
  Future<Result<void>> saveWorkout(
    Workout workout, {
    List<PersonalRecord> improvedRecords = const [],
  }) async {
    if (workout.finishedAt == null ||
        !WorkoutPolicy.isValidTitle(workout.title) ||
        !WorkoutPolicy.isValidPlan(workout.exercises)) {
      return const Failure(AppFailure.invalidInput);
    }
    final owner = workout.ownerId;
    final batch = _firestore.batch()
      ..set(
        _firestore.workouts(owner).doc(workout.id),
        WorkoutMapper.workoutToMap(workout),
      );
    for (final record in improvedRecords) {
      batch.set(
        _firestore.personalRecords(owner).doc(record.exercise.id),
        PersonalRecordMapper.toMap(record),
      );
    }
    return writeWithOfflineQueue(
      batch.commit(),
      wait: WorkoutLimits.offlineWriteTimeout,
    );
  }

  /// Удаляет тренировку и заново считает рекорды её упражнений по остальным тренировкам.
  @override
  Future<Result<void>> deleteWorkout(Workout workout) async {
    final owner = workout.ownerId;
    try {
      final batch = _firestore.batch()
        ..delete(_firestore.workouts(owner).doc(workout.id));
      final exercises = {
        for (final item in workout.exercises) item.exercise.id: item.exercise,
      };
      for (final exercise in exercises.values) {
        final snapshot = await _withExercise(owner, exercise.id).get();
        final others = _parse(
          owner,
          snapshot.docs,
        ).where((other) => other.id != workout.id);
        final record = PersonalRecords.rebuild(exercise, others);
        final doc = _firestore.personalRecords(owner).doc(exercise.id);
        record == null
            ? batch.delete(doc)
            : batch.set(doc, PersonalRecordMapper.toMap(record));
      }
      return await writeWithOfflineQueue(
        batch.commit(),
        wait: WorkoutLimits.offlineWriteTimeout,
      );
    } on FirebaseException catch (error) {
      return Failure(mapFirestoreFailure(error), cause: error);
    }
  }

  /// Выгрузка всех тренировочных коллекций.
  @override
  Future<Result<Map<String, Object?>>> exportData(String ownerId) {
    return _guard(() => exportWorkoutData(_firestore, ownerId));
  }

  /// Удаление всех тренировочных коллекций.
  @override
  Future<Result<void>> deleteAllData(String ownerId) {
    return _guard(() => deleteWorkoutData(_firestore, ownerId));
  }

  /// Тренировки с упражнением, новые сверху.
  Query<Map<String, dynamic>> _withExercise(String ownerId, String exerciseId) {
    return _firestore
        .workouts(ownerId)
        .where(WorkoutFields.exerciseIds, arrayContains: exerciseId)
        .orderBy(WorkoutFields.finishedAt, descending: true);
  }

  /// Собирает тренировки из документов, пропуская повреждённые.
  List<Workout> _parse(
    String ownerId,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    return docs
        .map((doc) => WorkoutMapper.workoutFromMap(doc.id, ownerId, doc.data()))
        .nonNulls
        .toList();
  }

  /// Выполняет чтение и переводит ошибку Firestore в [AppFailure].
  Future<Result<T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Success(await action());
    } on FirebaseException catch (error) {
      return Failure(mapFirestoreFailure(error), cause: error);
    }
  }
}
