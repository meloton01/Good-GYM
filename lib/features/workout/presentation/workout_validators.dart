import '../../../l10n/generated/app_localizations.dart';
import '../domain/workout_limits.dart';
import '../domain/workout_policy.dart';

/// Валидаторы полей тренировки с локализованными сообщениями.
abstract final class WorkoutValidators {
  /// Проверяет название своего упражнения.
  static String? exerciseName(AppLocalizations l10n, String? value) {
    return WorkoutPolicy.isValidExerciseName(value ?? '')
        ? null
        : l10n.validationTextLength(
            WorkoutLimits.exerciseNameMinLength,
            WorkoutLimits.exerciseNameMaxLength,
          );
  }
}
