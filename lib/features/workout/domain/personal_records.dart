import 'exercise.dart';
import 'exercise_best.dart';
import 'personal_record.dart';
import 'record_value.dart';
import 'workout.dart';

/// Расчёт личных рекордов по завершённым тренировкам.
abstract final class PersonalRecords {
  /// Рекорды, которые улучшила [workout], с учётом текущих [current] по id упражнения.
  static List<PersonalRecord> improvedBy(
    Workout workout,
    Map<String, PersonalRecord> current,
  ) {
    final improved = <String, PersonalRecord>{};
    for (final item in workout.exercises) {
      final best = ExerciseBest.of(item);
      if (best == null) {
        continue;
      }
      final id = item.exercise.id;
      final before =
          improved[id] ??
          current[id] ??
          PersonalRecord(exercise: item.exercise);
      final after = _merge(before, best, workout);
      if (after != before) {
        improved[id] = after.copyWith(exercise: item.exercise);
      }
    }
    return improved.values.toList();
  }

  /// Пересчитывает рекорды упражнения по [workouts]; null, если выполненных подходов нет.
  static PersonalRecord? rebuild(
    Exercise exercise,
    Iterable<Workout> workouts,
  ) {
    var record = PersonalRecord(exercise: exercise);
    var found = false;
    for (final workout in workouts) {
      for (final item in workout.exercises) {
        final best = item.exercise.id == exercise.id
            ? ExerciseBest.of(item)
            : null;
        if (best != null) {
          found = true;
          record = _merge(record, best, workout);
        }
      }
    }
    return found ? record : null;
  }

  /// Берёт лучшее из рекорда и показателей одной тренировки.
  static PersonalRecord _merge(
    PersonalRecord record,
    ExerciseBest best,
    Workout workout,
  ) {
    final achievedAt = workout.finishedAt ?? workout.startedAt;
    RecordValue? pick(RecordValue? current, double? value) {
      if (value == null || (current != null && current.value >= value)) {
        return current;
      }
      return RecordValue(
        value: value,
        workoutId: workout.id,
        achievedAt: achievedAt,
      );
    }

    return record.copyWith(
      maxWeightKg: pick(record.maxWeightKg, best.maxWeightKg),
      bestE1rmKg: pick(record.bestE1rmKg, best.bestE1rmKg),
      maxReps: pick(record.maxReps, best.maxReps.toDouble()),
    );
  }
}
