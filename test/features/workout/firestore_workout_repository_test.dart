import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:good_gym/core/errors/app_failure.dart';
import 'package:good_gym/core/errors/result.dart';
import 'package:good_gym/core/pagination/paged_result.dart';
import 'package:good_gym/features/workout/data/firestore_exercise_repository.dart';
import 'package:good_gym/features/workout/data/firestore_workout_repository.dart';
import 'package:good_gym/features/workout/domain/built_in_exercises.dart';
import 'package:good_gym/features/workout/domain/muscle_group.dart';
import 'package:good_gym/features/workout/domain/personal_records.dart';
import 'package:good_gym/features/workout/domain/workout.dart';

import 'workout_test_data.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late FirestoreWorkoutRepository repository;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repository = FirestoreWorkoutRepository(firestore);
  });

  /// Сохраняет тренировку вместе с рекордами, которые она улучшила.
  Future<void> save(Workout workout) async {
    final current = await repository.watchPersonalRecords('uid-1').first;
    final improved = PersonalRecords.improvedBy(workout, {
      for (final record in current) record.exercise.id: record,
    });
    final result = await repository.saveWorkout(
      workout,
      improvedRecords: improved,
    );
    expect(result, isA<Success<void>>());
  }

  test('saved workout reads back unchanged', () async {
    final workout = squatWorkout('w1', 1, 100);
    await save(workout);

    final loaded = await repository.fetchWorkout('uid-1', 'w1');
    expect((loaded as Success<Workout>).value, workout);
    expect(
      await repository.fetchWorkout('uid-1', 'missing'),
      isA<Failure<Workout>>().having(
        (failure) => failure.failure,
        'failure',
        AppFailure.notFound,
      ),
    );
  });

  test('history is paged from newest to oldest', () async {
    for (var day = 1; day <= 3; day++) {
      await save(squatWorkout('w$day', day, 100));
    }
    final first = await repository.fetchHistory('uid-1', limit: 2);
    final page = (first as Success<PagedResult<Workout>>).value;
    expect(page.items.map((Workout w) => w.id), ['w3', 'w2']);

    final second = await repository.fetchHistory(
      'uid-1',
      cursor: page.nextCursor,
      limit: 2,
    );
    final rest = (second as Success<PagedResult<Workout>>).value;
    expect(rest.items.map((Workout w) => w.id), ['w1']);
    expect(rest.hasMore, isFalse);
  });

  test('unfinished or empty workouts are rejected', () async {
    final unfinished = squatWorkout('w1', 1, 100).copyWith(finishedAt: null);
    expect(await repository.saveWorkout(unfinished), isA<Failure<void>>());
  });

  test('deleting a workout recalculates personal records', () async {
    await save(squatWorkout('w1', 1, 100));
    await save(squatWorkout('w2', 2, 120));
    var records = await repository.watchPersonalRecords('uid-1').first;
    expect(records.single.maxWeightKg!.value, 120);

    await repository.deleteWorkout(squatWorkout('w2', 2, 120));
    records = await repository.watchPersonalRecords('uid-1').first;
    expect(records.single.maxWeightKg!.value, 100);

    await repository.deleteWorkout(squatWorkout('w1', 1, 100));
    expect(await repository.watchPersonalRecords('uid-1').first, isEmpty);
  });

  test('exercise history contains only workouts with the exercise', () async {
    await save(squatWorkout('w1', 1, 100));
    await save(
      finishedWorkout('w2', 2, {
        BuiltInExercises.deadlift: [doneSet(5, 140)],
      }),
    );
    final result = await repository.fetchExerciseHistory('uid-1', 'squat');
    expect((result as Success<List<Workout>>).value.map((Workout w) => w.id), [
      'w1',
    ]);
  });

  test('export and delete cover all workout collections', () async {
    await save(squatWorkout('w1', 1, 100));
    await FirestoreExerciseRepository(firestore).createExercise(
      'uid-1',
      name: 'Hip thrust',
      muscleGroup: MuscleGroup.legs,
    );

    final exported = await repository.exportData('uid-1');
    final data = (exported as Success<Map<String, Object?>>).value;
    expect(data['workouts'], hasLength(1));
    expect(data['exercises'], hasLength(1));
    expect(data['personalRecords'], hasLength(1));

    await repository.deleteAllData('uid-1');
    for (final name in ['workouts', 'exercises', 'personalRecords']) {
      final left = await firestore.collection('users/uid-1/$name').get();
      expect(left.docs, isEmpty, reason: name);
    }
  });
}
