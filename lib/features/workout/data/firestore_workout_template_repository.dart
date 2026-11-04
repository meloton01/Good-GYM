import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/errors/app_failure.dart';
import '../../../core/errors/result.dart';
import '../../../core/firebase/offline_write.dart';
import '../domain/workout_limits.dart';
import '../domain/workout_policy.dart';
import '../domain/workout_template.dart';
import '../domain/workout_template_repository.dart';
import 'workout_collections.dart';
import 'workout_fields.dart';
import 'workout_mapper.dart';

/// Шаблоны в Firestore: users/{uid}/workoutTemplates/{templateId}.
class FirestoreWorkoutTemplateRepository implements WorkoutTemplateRepository {
  /// Создаёт репозиторий поверх экземпляра Firestore.
  FirestoreWorkoutTemplateRepository(this._firestore);

  final FirebaseFirestore _firestore;

  /// Поток шаблонов по алфавиту; повреждённые пропускаются.
  @override
  Stream<List<WorkoutTemplate>> watchTemplates(String ownerId) {
    return _firestore
        .workoutTemplates(ownerId)
        .orderBy(WorkoutFields.titleLower)
        .limit(WorkoutLimits.maxTemplates)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => WorkoutMapper.templateFromMap(doc.id, doc.data()))
              .nonNulls
              .toList(),
        );
  }

  /// Записывает шаблон целиком; без сети запись ставится в очередь.
  @override
  Future<Result<void>> saveTemplate(
    String ownerId,
    WorkoutTemplate template,
  ) async {
    if (!WorkoutPolicy.isValidTitle(template.title) ||
        !WorkoutPolicy.isValidPlan(template.exercises)) {
      return const Failure(AppFailure.invalidInput);
    }
    return writeWithOfflineQueue(
      _firestore.workoutTemplates(ownerId).doc(template.id).set({
        ...WorkoutMapper.templateToMap(template),
        WorkoutFields.updatedAt: FieldValue.serverTimestamp(),
      }),
      wait: WorkoutLimits.offlineWriteTimeout,
    );
  }

  /// Удаляет шаблон; без сети удаление ставится в очередь.
  @override
  Future<Result<void>> deleteTemplate(String ownerId, String templateId) {
    return writeWithOfflineQueue(
      _firestore.workoutTemplates(ownerId).doc(templateId).delete(),
      wait: WorkoutLimits.offlineWriteTimeout,
    );
  }
}
