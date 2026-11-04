import 'package:freezed_annotation/freezed_annotation.dart';

import 'workout_exercise.dart';

part 'workout_template.freezed.dart';

/// Шаблон тренировки: план упражнений и подходов без отметок выполнения.
@freezed
abstract class WorkoutTemplate with _$WorkoutTemplate {
  /// Создаёт шаблон.
  const factory WorkoutTemplate({
    required String id,
    required String title,
    required List<WorkoutExercise> exercises,
  }) = _WorkoutTemplate;
}
