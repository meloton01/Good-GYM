import '../../../core/constants/app_limits.dart';
import '../../../core/errors/result.dart';
import '../../../core/pagination/paged_result.dart';
import 'workout.dart';

/// Хранение тренировок; реализация пишет локально и синхронизирует при появлении сети.
abstract interface class WorkoutRepository {
  /// Возвращает страницу истории тренировок, новые сверху.
  Future<Result<PagedResult<Workout>>> fetchHistory(
    String ownerId, {
    String? cursor,
    int limit = AppLimits.pageSize,
  });

  /// Создаёт или обновляет тренировку.
  Future<Result<void>> saveWorkout(Workout workout);

  /// Удаляет тренировку.
  Future<Result<void>> deleteWorkout(String workoutId);
}
