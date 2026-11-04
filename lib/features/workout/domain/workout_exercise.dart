import 'package:freezed_annotation/freezed_annotation.dart';

import 'exercise.dart';
import 'workout_set.dart';

part 'workout_exercise.freezed.dart';

/// Упражнение внутри тренировки или шаблона со списком подходов.
@freezed
abstract class WorkoutExercise with _$WorkoutExercise {
  /// Создаёт упражнение тренировки; [exercise] хранится копией, чтобы история не зависела от библиотеки.
  const factory WorkoutExercise({
    required Exercise exercise,
    required List<WorkoutSet> sets,
  }) = _WorkoutExercise;
}
