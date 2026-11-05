import '../../../core/firebase/firestore_date.dart';
import '../domain/workout.dart';
import '../domain/workout_template.dart';
import 'exercise_mapper.dart';
import 'workout_fields.dart';

/// Перевод тренировок и шаблонов между моделями и документами.
abstract final class WorkoutMapper {
  /// Поля документа тренировки; даты остаются DateTime, Firestore сохранит их как Timestamp.
  static Map<String, Object?> workoutToMap(Workout workout) {
    return {
      WorkoutFields.title: workout.title,
      WorkoutFields.note: workout.note,
      WorkoutFields.startedAt: workout.startedAt,
      WorkoutFields.finishedAt: workout.finishedAt,
      WorkoutFields.exerciseIds: {
        for (final item in workout.exercises) item.exercise.id,
      }.toList(),
      WorkoutFields.exercises: ExerciseMapper.itemsToList(workout.exercises),
      if (workout.planId != null) WorkoutFields.planId: workout.planId,
    };
  }

  /// Собирает тренировку; null, если документ повреждён.
  static Workout? workoutFromMap(
    String id,
    String ownerId,
    Map<String, dynamic> data,
  ) {
    final title = data[WorkoutFields.title];
    final note = data[WorkoutFields.note];
    final planId = data[WorkoutFields.planId];
    final startedAt = readFirestoreDate(data[WorkoutFields.startedAt]);
    final exercises = ExerciseMapper.itemsFromList(
      data[WorkoutFields.exercises],
    );
    if (title is! String || startedAt == null || exercises == null) {
      return null;
    }
    return Workout(
      id: id,
      ownerId: ownerId,
      title: title,
      exercises: exercises,
      startedAt: startedAt,
      finishedAt: readFirestoreDate(data[WorkoutFields.finishedAt]),
      note: note is String ? note : '',
      planId: planId is String ? planId : null,
    );
  }

  /// Поля документа шаблона без даты изменения.
  static Map<String, Object?> templateToMap(WorkoutTemplate template) {
    return {
      WorkoutFields.title: template.title,
      WorkoutFields.titleLower: template.title.toLowerCase(),
      WorkoutFields.exercises: ExerciseMapper.itemsToList(template.exercises),
    };
  }

  /// Собирает шаблон; null, если документ повреждён.
  static WorkoutTemplate? templateFromMap(
    String id,
    Map<String, dynamic> data,
  ) {
    final title = data[WorkoutFields.title];
    final exercises = ExerciseMapper.itemsFromList(
      data[WorkoutFields.exercises],
    );
    if (title is! String || exercises == null) {
      return null;
    }
    return WorkoutTemplate(id: id, title: title, exercises: exercises);
  }
}
