import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/built_in_exercises.dart';
import '../domain/exercise.dart';
import '../domain/exercise_repository.dart';
import 'firestore_exercise_repository.dart';

/// Репозиторий своих упражнений; в тестах подменяется через overrides.
final exerciseRepositoryProvider = Provider<ExerciseRepository>(
  (ref) => FirestoreExerciseRepository(FirebaseFirestore.instance),
);

/// Библиотека упражнений пользователя: встроенные, затем свои.
final exerciseLibraryProvider = StreamProvider.family<List<Exercise>, String>(
  (ref, uid) => ref
      .watch(exerciseRepositoryProvider)
      .watchCustomExercises(uid)
      .map((custom) => [...BuiltInExercises.all, ...custom]),
);
