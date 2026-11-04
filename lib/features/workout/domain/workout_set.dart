import 'package:freezed_annotation/freezed_annotation.dart';

part 'workout_set.freezed.dart';

/// Один подход упражнения.
@freezed
abstract class WorkoutSet with _$WorkoutSet {
  /// Создаёт подход; [weightKg] null для упражнений с собственным весом.
  const factory WorkoutSet({
    required int reps,
    required int restSeconds,
    double? weightKg,
    @Default(false) bool completed,
  }) = _WorkoutSet;
}
