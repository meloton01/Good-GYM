import 'package:flutter_test/flutter_test.dart';
import 'package:good_gym/features/workout/data/local_active_workout_store.dart';
import 'package:good_gym/features/workout/domain/built_in_exercises.dart';
import 'package:good_gym/features/workout/domain/workout.dart';
import 'package:good_gym/features/workout/domain/workout_exercise.dart';
import 'package:good_gym/features/workout/domain/workout_set.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late LocalActiveWorkoutStore store;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    store = LocalActiveWorkoutStore(await SharedPreferences.getInstance());
  });

  test('workout in progress survives a restart', () async {
    final workout = Workout(
      id: 'w1',
      ownerId: 'uid-1',
      title: 'Push',
      startedAt: DateTime.fromMillisecondsSinceEpoch(1793800000000),
      note: 'Felt strong',
      exercises: const [
        WorkoutExercise(
          exercise: BuiltInExercises.benchPress,
          sets: [
            WorkoutSet(
              reps: 5,
              restSeconds: 120,
              weightKg: 80,
              completed: true,
            ),
            WorkoutSet(reps: 5, restSeconds: 120, weightKg: 80),
          ],
        ),
      ],
    );
    await store.saveWorkout(workout);
    expect(store.loadWorkout(), workout);

    await store.saveWorkout(null);
    expect(store.loadWorkout(), isNull);
  });

  test('rest end and length are stored together', () async {
    final endsAt = DateTime.fromMillisecondsSinceEpoch(1793800090000);
    await store.saveRest(endsAt, 90);
    expect(store.loadRest(), (endsAt, 90));

    await store.saveRest(null, 0);
    expect(store.loadRest(), isNull);
  });

  test('corrupted record is treated as no workout', () async {
    SharedPreferences.setMockInitialValues({'workout.active': '{oops'});
    store = LocalActiveWorkoutStore(await SharedPreferences.getInstance());
    expect(store.loadWorkout(), isNull);
  });
}
