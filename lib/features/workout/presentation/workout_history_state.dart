import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/errors/app_failure.dart';
import '../domain/workout.dart';

part 'workout_history_state.freezed.dart';

/// Загруженные страницы истории тренировок.
@freezed
abstract class WorkoutHistoryState with _$WorkoutHistoryState {
  /// Создаёт состояние; [failure] задан, если последняя загрузка не удалась.
  const factory WorkoutHistoryState({
    @Default([]) List<Workout> items,
    String? cursor,
    @Default(true) bool hasMore,
    @Default(false) bool loading,
    AppFailure? failure,
  }) = _WorkoutHistoryState;
}
