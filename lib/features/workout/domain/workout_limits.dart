/// Ограничения тренировок; те же значения проверяют правила Firestore.
abstract final class WorkoutLimits {
  static const int titleMaxLength = 60;
  static const int noteMaxLength = 1000;
  static const int exerciseNameMinLength = 2;
  static const int exerciseNameMaxLength = 40;
  static const int maxExercises = 30;
  static const int maxSets = 20;
  static const int minReps = 1;
  static const int maxReps = 1000;
  static const double maxWeightKg = 1000;
  static const int maxRestSeconds = 3600;

  /// Значения нового подхода по умолчанию.
  static const int defaultReps = 10;
  static const int defaultRestSeconds = 90;

  /// Шаг, на который продлевается отдых кнопкой.
  static const int restStepSeconds = 15;
  static const int maxTemplates = 50;
  static const int maxCustomExercises = 100;

  /// Сколько последних тренировок попадает в график упражнения.
  static const int progressPoints = 50;

  /// Сколько ждать подтверждения сервера, прежде чем считать запись отложенной до появления сети.
  static const Duration offlineWriteTimeout = Duration(seconds: 3);
}
