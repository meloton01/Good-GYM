import '../../../core/constants/app_limits.dart';
import '../../../core/errors/result.dart';
import '../../../core/pagination/paged_result.dart';
import 'personal_record.dart';
import 'workout.dart';
import 'workout_limits.dart';

/// Хранение тренировок и личных рекордов; запись идёт локально и синхронизируется при появлении сети.
abstract interface class WorkoutRepository {
  /// Возвращает страницу завершённых тренировок, новые сверху.
  Future<Result<PagedResult<Workout>>> fetchHistory(
    String ownerId, {
    String? cursor,
    int limit = AppLimits.pageSize,
  });

  /// Возвращает одну тренировку; отсутствующая даёт AppFailure.notFound.
  Future<Result<Workout>> fetchWorkout(String ownerId, String workoutId);

  /// Последние тренировки с упражнением [exerciseId], новые сверху.
  Future<Result<List<Workout>>> fetchExerciseHistory(
    String ownerId,
    String exerciseId, {
    int limit = WorkoutLimits.progressPoints,
  });

  /// Поток личных рекордов по всем упражнениям.
  Stream<List<PersonalRecord>> watchPersonalRecords(String ownerId);

  /// Сохраняет завершённую тренировку вместе с улучшенными рекордами.
  Future<Result<void>> saveWorkout(
    Workout workout, {
    List<PersonalRecord> improvedRecords = const [],
  });

  /// Удаляет тренировку и пересчитывает рекорды её упражнений.
  Future<Result<void>> deleteWorkout(Workout workout);

  /// Собирает тренировки, шаблоны, упражнения и рекорды для выгрузки.
  Future<Result<Map<String, Object?>>> exportData(String ownerId);

  /// Удаляет все тренировочные данные пользователя.
  Future<Result<void>> deleteAllData(String ownerId);
}
