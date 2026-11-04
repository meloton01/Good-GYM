import 'workout_exercise.dart';
import 'workout_limits.dart';
import 'workout_set.dart';

/// Проверка данных тренировки до записи.
abstract final class WorkoutPolicy {
  /// Подходит ли название тренировки или шаблона.
  static bool isValidTitle(String title) {
    final length = title.trim().length;
    return length > 0 && length <= WorkoutLimits.titleMaxLength;
  }

  /// Подходит ли название своего упражнения.
  static bool isValidExerciseName(String name) {
    final length = name.trim().length;
    return length >= WorkoutLimits.exerciseNameMinLength &&
        length <= WorkoutLimits.exerciseNameMaxLength;
  }

  /// Укладывается ли подход в допустимые диапазоны.
  static bool isValidSet(WorkoutSet set) {
    final weight = set.weightKg;
    return set.reps >= WorkoutLimits.minReps &&
        set.reps <= WorkoutLimits.maxReps &&
        set.restSeconds >= 0 &&
        set.restSeconds <= WorkoutLimits.maxRestSeconds &&
        (weight == null ||
            (weight >= 0 && weight <= WorkoutLimits.maxWeightKg));
  }

  /// Подходит ли список упражнений: есть хотя бы одно, все подходы допустимы.
  static bool isValidPlan(List<WorkoutExercise> exercises) {
    return exercises.isNotEmpty &&
        exercises.length <= WorkoutLimits.maxExercises &&
        exercises.every(
          (item) =>
              item.sets.isNotEmpty &&
              item.sets.length <= WorkoutLimits.maxSets &&
              item.sets.every(isValidSet),
        );
  }
}
