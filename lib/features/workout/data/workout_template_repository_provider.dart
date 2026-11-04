import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/workout_template.dart';
import '../domain/workout_template_repository.dart';
import 'firestore_workout_template_repository.dart';

/// Репозиторий шаблонов; в тестах подменяется через overrides.
final workoutTemplateRepositoryProvider = Provider<WorkoutTemplateRepository>(
  (ref) => FirestoreWorkoutTemplateRepository(FirebaseFirestore.instance),
);

/// Поток шаблонов пользователя по uid.
final workoutTemplatesProvider =
    StreamProvider.family<List<WorkoutTemplate>, String>(
      (ref, uid) =>
          ref.watch(workoutTemplateRepositoryProvider).watchTemplates(uid),
    );
