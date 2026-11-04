import 'package:freezed_annotation/freezed_annotation.dart';

import 'workout_exercise.dart';

part 'workout.freezed.dart';

/// Тренировка пользователя.
@freezed
abstract class Workout with _$Workout {
  /// Создаёт тренировку; [finishedAt] null, пока тренировка идёт.
  const factory Workout({
    required String id,
    required String ownerId,
    required String title,
    required List<WorkoutExercise> exercises,
    required DateTime startedAt,
    DateTime? finishedAt,
    @Default('') String note,
  }) = _Workout;
}
