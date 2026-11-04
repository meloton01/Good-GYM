import '../domain/exercise.dart';
import '../domain/muscle_group.dart';
import '../domain/workout_exercise.dart';
import '../domain/workout_set.dart';
import 'workout_fields.dart';

/// Перевод упражнений и подходов между моделями и полями документов.
abstract final class ExerciseMapper {
  /// Поля упражнения внутри тренировки, шаблона или рекорда.
  static Map<String, Object?> exerciseToMap(Exercise exercise) {
    return {
      WorkoutFields.exerciseId: exercise.id,
      WorkoutFields.muscleGroup: exercise.muscleGroup.name,
      if (exercise.customName != null)
        WorkoutFields.customName: exercise.customName,
    };
  }

  /// Собирает упражнение; null, если поля повреждены.
  static Exercise? exerciseFromMap(Map<String, dynamic> data) {
    final id = data[WorkoutFields.exerciseId];
    final group = _muscleGroup(data[WorkoutFields.muscleGroup]);
    final customName = data[WorkoutFields.customName];
    if (id is! String || group == null) {
      return null;
    }
    return Exercise(
      id: id,
      muscleGroup: group,
      customName: customName is String ? customName : null,
    );
  }

  /// Собирает своё упражнение из документа users/{uid}/exercises/{id}.
  static Exercise? customFromDoc(String id, Map<String, dynamic> data) {
    final name = data[WorkoutFields.name];
    final group = _muscleGroup(data[WorkoutFields.muscleGroup]);
    if (name is! String || group == null) {
      return null;
    }
    return Exercise(id: id, muscleGroup: group, customName: name);
  }

  /// Список упражнений с подходами для записи в документ.
  static List<Map<String, Object?>> itemsToList(List<WorkoutExercise> items) {
    return [
      for (final item in items)
        {
          ...exerciseToMap(item.exercise),
          WorkoutFields.sets: [
            for (final set in item.sets)
              {
                WorkoutFields.reps: set.reps,
                WorkoutFields.restSeconds: set.restSeconds,
                WorkoutFields.weightKg: set.weightKg,
                WorkoutFields.completed: set.completed,
              },
          ],
        },
    ];
  }

  /// Собирает упражнения с подходами; null, если хоть одно повреждено.
  static List<WorkoutExercise>? itemsFromList(Object? value) {
    if (value is! List) {
      return null;
    }
    final items = <WorkoutExercise>[];
    for (final raw in value) {
      final exercise = raw is Map<String, dynamic>
          ? exerciseFromMap(raw)
          : null;
      final sets = raw is Map<String, dynamic>
          ? _setsFromList(raw[WorkoutFields.sets])
          : null;
      if (exercise == null || sets == null) {
        return null;
      }
      items.add(WorkoutExercise(exercise: exercise, sets: sets));
    }
    return items;
  }

  /// Собирает подходы; null, если хоть один повреждён.
  static List<WorkoutSet>? _setsFromList(Object? value) {
    if (value is! List) {
      return null;
    }
    final sets = <WorkoutSet>[];
    for (final raw in value) {
      final reps = raw is Map ? raw[WorkoutFields.reps] : null;
      final rest = raw is Map ? raw[WorkoutFields.restSeconds] : null;
      if (raw is! Map || reps is! int || rest is! int) {
        return null;
      }
      final weight = raw[WorkoutFields.weightKg];
      sets.add(
        WorkoutSet(
          reps: reps,
          restSeconds: rest,
          weightKg: weight is num ? weight.toDouble() : null,
          completed: raw[WorkoutFields.completed] == true,
        ),
      );
    }
    return sets;
  }

  /// Читает группу мышц по имени или null, если значение неизвестно.
  static MuscleGroup? _muscleGroup(Object? name) {
    return name is String ? MuscleGroup.values.asNameMap()[name] : null;
  }
}
