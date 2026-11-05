import '../../../core/constants/app_limits.dart';
import '../../../core/errors/result.dart';
import 'coach_plan.dart';
import 'plan_comment.dart';

/// Планы тренера и комментарии к ним; планы лежат у ученика [athleteId].
abstract interface class CoachPlanRepository {
  /// Поток последних [limit] планов ученика от всех тренеров, новые сверху.
  Stream<List<CoachPlan>> watchAthletePlans(
    String athleteId, {
    int limit = AppLimits.pageSize,
  });

  /// Поток последних [limit] планов, которые тренер [coachId] назначил ученику.
  Stream<List<CoachPlan>> watchCoachPlans(
    String coachId,
    String athleteId, {
    int limit = AppLimits.pageSize,
  });

  /// Поток одного плана; null, если план удалён.
  Stream<CoachPlan?> watchPlan(String athleteId, String planId);

  /// Создаёт план; назначить можно только ученику с активной связью.
  Future<Result<void>> createPlan(CoachPlan plan);

  /// Меняет название, заметку и упражнения невыполненного плана.
  Future<Result<void>> updatePlan(CoachPlan plan);

  /// Удаляет план вместе с комментариями.
  Future<Result<void>> deletePlan(String athleteId, String planId);

  /// Отмечает план выполненным тренировкой [workoutId].
  Future<Result<void>> completePlan(
    String athleteId,
    String planId,
    String workoutId,
  );

  /// Поток последних [limit] комментариев к плану, новые сверху.
  Stream<List<PlanComment>> watchComments(
    String athleteId,
    String planId, {
    int limit = AppLimits.pageSize,
  });

  /// Добавляет комментарий от имени автора.
  Future<Result<void>> addComment(
    String athleteId,
    String planId, {
    required String authorId,
    required String authorNickname,
    required String text,
  });

  /// Собирает планы ученика с комментариями для выгрузки.
  Future<Result<List<Map<String, Object?>>>> exportData(String athleteId);

  /// Удаляет планы ученика вместе с комментариями.
  Future<Result<void>> deleteAllData(String athleteId);
}
