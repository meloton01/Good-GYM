import 'package:freezed_annotation/freezed_annotation.dart';

import 'exercise_best.dart';

part 'progress_point.freezed.dart';

/// Точка графика прогресса: лучшие показатели упражнения в одной тренировке.
@freezed
abstract class ProgressPoint with _$ProgressPoint {
  /// Создаёт точку графика.
  const factory ProgressPoint({
    required String workoutId,
    required DateTime date,
    required ExerciseBest best,
  }) = _ProgressPoint;
}
