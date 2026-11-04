import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/errors/app_failure.dart';
import '../../../core/errors/result.dart';
import '../../../core/firebase/offline_write.dart';
import '../domain/exercise.dart';
import '../domain/exercise_repository.dart';
import '../domain/muscle_group.dart';
import '../domain/workout_limits.dart';
import '../domain/workout_policy.dart';
import 'exercise_mapper.dart';
import 'workout_collections.dart';
import 'workout_fields.dart';

/// Свои упражнения в Firestore: users/{uid}/exercises/{exerciseId}.
class FirestoreExerciseRepository implements ExerciseRepository {
  /// Создаёт репозиторий поверх экземпляра Firestore.
  FirestoreExerciseRepository(this._firestore);

  final FirebaseFirestore _firestore;

  /// Поток своих упражнений по алфавиту; повреждённые пропускаются.
  @override
  Stream<List<Exercise>> watchCustomExercises(String ownerId) {
    return _firestore
        .customExercises(ownerId)
        .orderBy(WorkoutFields.nameLower)
        .limit(WorkoutLimits.maxCustomExercises)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ExerciseMapper.customFromDoc(doc.id, doc.data()))
              .nonNulls
              .toList(),
        );
  }

  /// Создаёт упражнение; без сети запись ставится в очередь, упражнение доступно сразу.
  @override
  Future<Result<Exercise>> createExercise(
    String ownerId, {
    required String name,
    required MuscleGroup muscleGroup,
  }) async {
    final cleanName = name.trim();
    if (!WorkoutPolicy.isValidExerciseName(cleanName)) {
      return const Failure(AppFailure.invalidInput);
    }
    final doc = _firestore.customExercises(ownerId).doc();
    final result = await writeWithOfflineQueue(
      doc.set({
        WorkoutFields.name: cleanName,
        WorkoutFields.nameLower: cleanName.toLowerCase(),
        WorkoutFields.muscleGroup: muscleGroup.name,
        WorkoutFields.createdAt: FieldValue.serverTimestamp(),
      }),
      wait: WorkoutLimits.offlineWriteTimeout,
    );
    return switch (result) {
      Success() => Success(
        Exercise(id: doc.id, muscleGroup: muscleGroup, customName: cleanName),
      ),
      Failure(:final failure, :final cause) => Failure(failure, cause: cause),
    };
  }
}
