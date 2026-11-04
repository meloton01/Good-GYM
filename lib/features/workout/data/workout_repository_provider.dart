import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/personal_record.dart';
import '../domain/workout_repository.dart';
import 'firestore_workout_repository.dart';

/// Репозиторий тренировок; в тестах подменяется через overrides.
final workoutRepositoryProvider = Provider<WorkoutRepository>(
  (ref) => FirestoreWorkoutRepository(FirebaseFirestore.instance),
);

/// Поток личных рекордов пользователя по uid.
final personalRecordsProvider =
    StreamProvider.family<List<PersonalRecord>, String>(
      (ref, uid) =>
          ref.watch(workoutRepositoryProvider).watchPersonalRecords(uid),
    );
