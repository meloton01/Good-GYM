import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_failure.dart';
import '../../../core/errors/result.dart';
import '../../../core/firebase/firestore_failure_mapper.dart';
import '../../../core/ids/random_id.dart';
import '../../../core/time/clock_provider.dart';
import '../data/active_workout_store_provider.dart';
import '../data/workout_repository_provider.dart';
import '../domain/personal_record.dart';
import '../domain/personal_records.dart';
import '../domain/workout.dart';
import '../domain/workout_exercise.dart';
import '../domain/workout_set.dart';
import 'rest_timer_controller.dart';
import 'workout_history_controller.dart';

/// Идущая тренировка; хранится на устройстве, пока её не завершат или не отменят.
final activeWorkoutProvider =
    NotifierProvider<ActiveWorkoutController, Workout?>(
      ActiveWorkoutController.new,
    );

/// Начинает, ведёт и завершает тренировку.
class ActiveWorkoutController extends Notifier<Workout?> {
  /// Восстанавливает тренировку, начатую до перезапуска приложения.
  @override
  Workout? build() => ref.watch(activeWorkoutStoreProvider).loadWorkout();

  /// Начинает тренировку по плану; [planId] задан, если это план тренера.
  Future<Result<void>> start({
    required String ownerId,
    required String title,
    required List<WorkoutExercise> exercises,
    String? planId,
  }) async {
    await ref.read(restTimerProvider.notifier).stop();
    return _apply(
      Workout(
        id: randomId(),
        ownerId: ownerId,
        title: title,
        planId: planId,
        startedAt: ref.read(clockProvider)(),
        exercises: [
          for (final item in exercises)
            item.copyWith(
              sets: [
                for (final set in item.sets) set.copyWith(completed: false),
              ],
            ),
        ],
      ),
    );
  }

  /// Переключает отметку выполнения подхода.
  Future<Result<void>> toggleSet(int exerciseIndex, int setIndex) {
    return _updateSets(exerciseIndex, (sets) {
      final set = sets[setIndex];
      sets[setIndex] = set.copyWith(completed: !set.completed);
    });
  }

  /// Заменяет подход, например после правки повторов или веса.
  Future<Result<void>> updateSet(
    int exerciseIndex,
    int setIndex,
    WorkoutSet set,
  ) {
    return _updateSets(exerciseIndex, (sets) => sets[setIndex] = set);
  }

  /// Добавляет подход копией последнего без отметки.
  Future<Result<void>> addSet(int exerciseIndex) {
    return _updateSets(
      exerciseIndex,
      (sets) => sets.add(sets.last.copyWith(completed: false)),
    );
  }

  /// Сохраняет заметку к тренировке.
  Future<Result<void>> setNote(String note) {
    final workout = state;
    return workout == null
        ? Future.value(const Success(null))
        : _apply(workout.copyWith(note: note));
  }

  /// Отменяет тренировку без сохранения.
  Future<Result<void>> discard() async {
    await ref.read(restTimerProvider.notifier).stop();
    return _apply(null);
  }

  /// Сохраняет выполненные подходы в историю, обновляет рекорды и возвращает id тренировки.
  Future<Result<String>> finish() async {
    final workout = state;
    if (workout == null) {
      return const Failure(AppFailure.notFound);
    }
    final done = workout.copyWith(
      finishedAt: ref.read(clockProvider)(),
      exercises: [
        for (final item in workout.exercises)
          if (item.sets.any((set) => set.completed))
            item.copyWith(
              sets: [
                for (final set in item.sets)
                  if (set.completed) set,
              ],
            ),
      ],
    );
    if (done.exercises.isEmpty) {
      return const Failure(AppFailure.nothingCompleted);
    }
    final repository = ref.read(workoutRepositoryProvider);
    final List<PersonalRecord> current;
    try {
      current = await repository.watchPersonalRecords(workout.ownerId).first;
    } on Exception catch (error) {
      return Failure(failureFromError(error), cause: error);
    }
    final improved = PersonalRecords.improvedBy(done, {
      for (final record in current) record.exercise.id: record,
    });
    final saved = await repository.saveWorkout(done, improvedRecords: improved);
    if (saved case Failure(:final failure, :final cause)) {
      return Failure(failure, cause: cause);
    }
    await discard();
    ref.invalidate(workoutHistoryProvider(workout.ownerId));
    return Success(done.id);
  }

  /// Меняет подходы упражнения [exerciseIndex] через [change] и сохраняет тренировку.
  Future<Result<void>> _updateSets(
    int exerciseIndex,
    void Function(List<WorkoutSet> sets) change,
  ) {
    final workout = state;
    if (workout == null) {
      return Future.value(const Success(null));
    }
    final exercises = [...workout.exercises];
    final sets = [...exercises[exerciseIndex].sets];
    change(sets);
    exercises[exerciseIndex] = exercises[exerciseIndex].copyWith(sets: sets);
    return _apply(workout.copyWith(exercises: exercises));
  }

  /// Применяет состояние сразу и записывает его на устройство.
  Future<Result<void>> _apply(Workout? next) {
    state = next;
    return ref.read(activeWorkoutStoreProvider).saveWorkout(next);
  }
}
