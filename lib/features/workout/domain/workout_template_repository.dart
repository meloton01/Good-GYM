import '../../../core/errors/result.dart';
import 'workout_template.dart';

/// Шаблоны тренировок пользователя.
abstract interface class WorkoutTemplateRepository {
  /// Поток шаблонов по алфавиту, не больше WorkoutLimits.maxTemplates.
  Stream<List<WorkoutTemplate>> watchTemplates(String ownerId);

  /// Создаёт или обновляет шаблон.
  Future<Result<void>> saveTemplate(String ownerId, WorkoutTemplate template);

  /// Удаляет шаблон.
  Future<Result<void>> deleteTemplate(String ownerId, String templateId);
}
