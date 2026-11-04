import '../../../core/firebase/firestore_date.dart';
import '../domain/personal_record.dart';
import '../domain/record_value.dart';
import 'exercise_mapper.dart';
import 'workout_fields.dart';

/// Перевод личных рекордов между моделью и документом users/{uid}/personalRecords/{exerciseId}.
abstract final class PersonalRecordMapper {
  /// Поля документа рекорда.
  static Map<String, Object?> toMap(PersonalRecord record) {
    return {
      ...ExerciseMapper.exerciseToMap(record.exercise),
      WorkoutFields.maxWeightKg: _valueToMap(record.maxWeightKg),
      WorkoutFields.bestE1rmKg: _valueToMap(record.bestE1rmKg),
      WorkoutFields.maxReps: _valueToMap(record.maxReps),
    };
  }

  /// Собирает рекорд; null, если документ повреждён.
  static PersonalRecord? fromMap(Map<String, dynamic> data) {
    final exercise = ExerciseMapper.exerciseFromMap(data);
    if (exercise == null) {
      return null;
    }
    return PersonalRecord(
      exercise: exercise,
      maxWeightKg: _valueFromMap(data[WorkoutFields.maxWeightKg]),
      bestE1rmKg: _valueFromMap(data[WorkoutFields.bestE1rmKg]),
      maxReps: _valueFromMap(data[WorkoutFields.maxReps]),
    );
  }

  /// Поля одного показателя или null, если показателя нет.
  static Map<String, Object?>? _valueToMap(RecordValue? value) {
    if (value == null) {
      return null;
    }
    return {
      WorkoutFields.value: value.value,
      WorkoutFields.workoutId: value.workoutId,
      WorkoutFields.achievedAt: value.achievedAt,
    };
  }

  /// Собирает показатель; null, если его нет или он повреждён.
  static RecordValue? _valueFromMap(Object? data) {
    if (data is! Map) {
      return null;
    }
    final value = data[WorkoutFields.value];
    final workoutId = data[WorkoutFields.workoutId];
    final achievedAt = readFirestoreDate(data[WorkoutFields.achievedAt]);
    if (value is! num || workoutId is! String || achievedAt == null) {
      return null;
    }
    return RecordValue(
      value: value.toDouble(),
      workoutId: workoutId,
      achievedAt: achievedAt,
    );
  }
}
