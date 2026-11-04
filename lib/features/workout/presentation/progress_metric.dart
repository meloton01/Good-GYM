import '../../../l10n/generated/app_localizations.dart';
import '../domain/exercise_best.dart';

/// Показатель, который строит график прогресса.
enum ProgressMetric {
  e1rm,
  maxWeight,
  reps;

  /// Значение показателя в точке или null, если его нет.
  double? valueOf(ExerciseBest best) => switch (this) {
    ProgressMetric.e1rm => best.bestE1rmKg,
    ProgressMetric.maxWeight => best.maxWeightKg,
    ProgressMetric.reps => best.maxReps.toDouble(),
  };

  /// Показатель в килограммах, а не в повторениях.
  bool get isWeight => this != ProgressMetric.reps;

  /// Название показателя на языке интерфейса.
  String label(AppLocalizations l10n) => switch (this) {
    ProgressMetric.e1rm => l10n.metricE1rm,
    ProgressMetric.maxWeight => l10n.metricMaxWeight,
    ProgressMetric.reps => l10n.metricReps,
  };
}
