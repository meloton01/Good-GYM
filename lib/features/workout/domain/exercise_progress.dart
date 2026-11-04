import 'exercise_best.dart';
import 'progress_point.dart';
import 'workout.dart';

/// Точки графика упражнения [exerciseId] по тренировкам, от старых к новым.
List<ProgressPoint> exerciseProgress(
  String exerciseId,
  Iterable<Workout> workouts,
) {
  final points = <ProgressPoint>[];
  for (final workout in workouts) {
    for (final item in workout.exercises) {
      final best = item.exercise.id == exerciseId
          ? ExerciseBest.of(item)
          : null;
      if (best != null) {
        points.add(
          ProgressPoint(
            workoutId: workout.id,
            date: workout.finishedAt ?? workout.startedAt,
            best: best,
          ),
        );
        break;
      }
    }
  }
  points.sort((a, b) => a.date.compareTo(b.date));
  return points;
}
