import 'package:flutter_test/flutter_test.dart';
import 'package:good_gym/features/workout/domain/built_in_exercises.dart';
import 'package:good_gym/features/workout/domain/exercise_best.dart';
import 'package:good_gym/features/workout/domain/exercise_progress.dart';
import 'package:good_gym/features/workout/domain/personal_records.dart';
import 'package:good_gym/features/workout/domain/workout_exercise.dart';
import 'package:good_gym/features/workout/domain/workout_set.dart';

import 'workout_test_data.dart';

void main() {
  test('best ignores sets that are not completed', () {
    const item = WorkoutExercise(
      exercise: BuiltInExercises.benchPress,
      sets: [
        WorkoutSet(reps: 5, restSeconds: 90, weightKg: 80, completed: true),
        WorkoutSet(reps: 3, restSeconds: 90, weightKg: 90),
      ],
    );
    final best = ExerciseBest.of(item)!;
    expect(best.maxWeightKg, 80);
    expect(best.maxReps, 5);
    expect(best.bestE1rmKg, closeTo(93.33, 0.01));
  });

  test('bodyweight sets give reps without weight metrics', () {
    final best = ExerciseBest.of(
      WorkoutExercise(exercise: BuiltInExercises.pullUp, sets: [doneSet(12)]),
    )!;
    expect(best.maxReps, 12);
    expect(best.maxWeightKg, isNull);
    expect(best.bestE1rmKg, isNull);
  });

  test('a workout improves only metrics it beats', () {
    final first = PersonalRecords.improvedBy(squatWorkout('w1', 1, 100), {});
    expect(first.single.maxWeightKg!.value, 100);

    final current = {first.single.exercise.id: first.single};
    final lighter = PersonalRecords.improvedBy(
      squatWorkout('w2', 2, 90, reps: 12),
      current,
    );
    final record = lighter.single;
    expect(record.maxWeightKg!.workoutId, 'w1');
    expect(record.bestE1rmKg!.workoutId, 'w2');
    expect(record.maxReps!.value, 12);

    expect(
      PersonalRecords.improvedBy(squatWorkout('w3', 3, 50), current),
      isEmpty,
    );
  });

  test('rebuild recalculates from remaining workouts', () {
    final record = PersonalRecords.rebuild(BuiltInExercises.squat, [
      squatWorkout('w1', 1, 100),
      squatWorkout('w2', 2, 110),
    ])!;
    expect(record.maxWeightKg!.workoutId, 'w2');
    expect(PersonalRecords.rebuild(BuiltInExercises.deadlift, []), isNull);
  });

  test('progress points are sorted from old to new', () {
    final points = exerciseProgress('squat', [
      squatWorkout('w2', 5, 110),
      squatWorkout('w1', 1, 100),
      finishedWorkout('w3', 3, {
        BuiltInExercises.deadlift: [doneSet(5, 140)],
      }),
    ]);
    expect(points.map((point) => point.workoutId), ['w1', 'w2']);
  });
}
