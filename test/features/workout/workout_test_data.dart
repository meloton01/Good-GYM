import 'package:good_gym/features/workout/domain/built_in_exercises.dart';
import 'package:good_gym/features/workout/domain/exercise.dart';
import 'package:good_gym/features/workout/domain/workout.dart';
import 'package:good_gym/features/workout/domain/workout_exercise.dart';
import 'package:good_gym/features/workout/domain/workout_set.dart';

/// Выполненный подход для тестов.
WorkoutSet doneSet(int reps, [double? weightKg]) => WorkoutSet(
  reps: reps,
  restSeconds: 90,
  weightKg: weightKg,
  completed: true,
);

/// Завершённая тренировка из упражнений [items] в день [day] ноября 2026.
Workout finishedWorkout(
  String id,
  int day,
  Map<Exercise, List<WorkoutSet>> items, {
  String ownerId = 'uid-1',
}) {
  final startedAt = DateTime(2026, 11, day, 18);
  return Workout(
    id: id,
    ownerId: ownerId,
    title: 'Workout $id',
    startedAt: startedAt,
    finishedAt: startedAt.add(const Duration(hours: 1)),
    exercises: [
      for (final MapEntry(:key, :value) in items.entries)
        WorkoutExercise(exercise: key, sets: value),
    ],
  );
}

/// Тренировка с одним подходом приседа.
Workout squatWorkout(String id, int day, double weightKg, {int reps = 5}) =>
    finishedWorkout(id, day, {
      BuiltInExercises.squat: [doneSet(reps, weightKg)],
    });
