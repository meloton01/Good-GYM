import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/result.dart';
import '../data/workout_repository_provider.dart';
import '../domain/workout.dart';

/// Завершённая тренировка по паре (uid, id тренировки).
final workoutDetailProvider = FutureProvider.autoDispose
    .family<Result<Workout>, (String, String)>(
      (ref, key) =>
          ref.watch(workoutRepositoryProvider).fetchWorkout(key.$1, key.$2),
    );

/// Последние тренировки с упражнением по паре (uid, id упражнения).
final exerciseHistoryProvider = FutureProvider.autoDispose
    .family<Result<List<Workout>>, (String, String)>(
      (ref, key) => ref
          .watch(workoutRepositoryProvider)
          .fetchExerciseHistory(key.$1, key.$2),
    );
