import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/errors/app_failure.dart';
import '../../../core/errors/result.dart';
import '../domain/workout.dart';
import 'workout_fields.dart';
import 'workout_mapper.dart';

/// Идущая тренировка и таймер отдыха на устройстве: переживают перезапуск и работают без сети.
class LocalActiveWorkoutStore {
  /// Создаёт хранилище поверх готового экземпляра SharedPreferences.
  LocalActiveWorkoutStore(this._preferences);

  static const String _workoutKey = 'workout.active';
  static const String _restEndKey = 'workout.restEndsAt';
  static const String _restTotalKey = 'workout.restTotalSeconds';

  final SharedPreferences _preferences;

  /// Читает идущую тренировку; повреждённая запись считается отсутствующей.
  Workout? loadWorkout() {
    final raw = _preferences.getString(_workoutKey);
    if (raw == null) {
      return null;
    }
    try {
      final data = jsonDecode(raw);
      if (data is! Map<String, dynamic>) {
        return null;
      }
      final id = data[WorkoutFields.id];
      final ownerId = data[WorkoutFields.ownerId];
      if (id is! String || ownerId is! String) {
        return null;
      }
      return WorkoutMapper.workoutFromMap(id, ownerId, data);
    } on FormatException {
      return null;
    }
  }

  /// Сохраняет идущую тренировку или удаляет её при null.
  Future<Result<void>> saveWorkout(Workout? workout) {
    if (workout == null) {
      return _run(() => _preferences.remove(_workoutKey));
    }
    final data = {
      ...WorkoutMapper.workoutToMap(workout),
      WorkoutFields.id: workout.id,
      WorkoutFields.ownerId: workout.ownerId,
    };
    final json = jsonEncode(
      data,
      toEncodable: (value) =>
          value is DateTime ? value.millisecondsSinceEpoch : value,
    );
    return _run(() => _preferences.setString(_workoutKey, json));
  }

  /// Читает конец отдыха и его полную длительность в секундах.
  (DateTime, int)? loadRest() {
    final end = _preferences.getInt(_restEndKey);
    final total = _preferences.getInt(_restTotalKey);
    if (end == null || total == null) {
      return null;
    }
    return (DateTime.fromMillisecondsSinceEpoch(end), total);
  }

  /// Сохраняет таймер отдыха или удаляет его при null.
  Future<Result<void>> saveRest(DateTime? endsAt, int totalSeconds) {
    if (endsAt == null) {
      return _run(() async {
        final removed = await _preferences.remove(_restEndKey);
        return removed && await _preferences.remove(_restTotalKey);
      });
    }
    return _run(() async {
      final saved = await _preferences.setInt(
        _restEndKey,
        endsAt.millisecondsSinceEpoch,
      );
      return saved && await _preferences.setInt(_restTotalKey, totalSeconds);
    });
  }

  /// Выполняет запись и возвращает [AppFailure.storage], если она не удалась.
  Future<Result<void>> _run(Future<bool> Function() write) async {
    final saved = await write();
    return saved ? const Success(null) : const Failure(AppFailure.storage);
  }
}
