import 'package:freezed_annotation/freezed_annotation.dart';

import 'one_rep_max.dart';
import 'workout_exercise.dart';

part 'exercise_best.freezed.dart';

/// Лучшие показатели упражнения в одной тренировке по выполненным подходам.
@freezed
abstract class ExerciseBest with _$ExerciseBest {
  /// Создаёт показатели; веса null, если подходы были без отягощения.
  const factory ExerciseBest({
    required int maxReps,
    double? maxWeightKg,
    double? bestE1rmKg,
  }) = _ExerciseBest;

  /// Считает показатели; null, если выполненных подходов нет.
  static ExerciseBest? of(WorkoutExercise exercise) {
    final done = exercise.sets.where((set) => set.completed && set.reps > 0);
    if (done.isEmpty) {
      return null;
    }
    var maxReps = 0;
    double? maxWeight;
    double? bestE1rm;
    for (final set in done) {
      if (set.reps > maxReps) {
        maxReps = set.reps;
      }
      final weight = set.weightKg;
      if (weight == null || weight <= 0) {
        continue;
      }
      final e1rm = estimateOneRepMax(weight, set.reps);
      if (maxWeight == null || weight > maxWeight) {
        maxWeight = weight;
      }
      if (bestE1rm == null || e1rm > bestE1rm) {
        bestE1rm = e1rm;
      }
    }
    return ExerciseBest(
      maxReps: maxReps,
      maxWeightKg: maxWeight,
      bestE1rmKg: bestE1rm,
    );
  }
}
