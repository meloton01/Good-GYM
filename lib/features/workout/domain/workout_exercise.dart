import 'package:freezed_annotation/freezed_annotation.dart';

import 'workout_set.dart';

part 'workout_exercise.freezed.dart';

/// Упражнение внутри тренировки со списком подходов.
@freezed
abstract class WorkoutExercise with _$WorkoutExercise {
  /// Создаёт упражнение тренировки.
  const factory WorkoutExercise({
    required String exerciseId,
    required List<WorkoutSet> sets,
    String? note,
  }) = _WorkoutExercise;
}
