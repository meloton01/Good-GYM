import '../../../l10n/generated/app_localizations.dart';
import '../domain/leaderboard_metric.dart';
import '../domain/leaderboard_period.dart';
import '../domain/rating_exercise.dart';
import '../domain/record_badge.dart';
import '../domain/record_status.dart';
import '../domain/sex.dart';
import '../domain/weight_class.dart';

/// Название упражнения рейтинга.
extension RatingExerciseLabel on RatingExercise {
  /// Возвращает название на языке интерфейса.
  String label(AppLocalizations l10n) => switch (this) {
    RatingExercise.squat => l10n.ratingExerciseSquat,
    RatingExercise.benchPress => l10n.ratingExerciseBenchPress,
    RatingExercise.deadlift => l10n.ratingExerciseDeadlift,
    RatingExercise.pullUp => l10n.ratingExercisePullUp,
  };
}

/// Название периода таблицы.
extension LeaderboardPeriodLabel on LeaderboardPeriod {
  /// Возвращает название на языке интерфейса.
  String label(AppLocalizations l10n) => switch (this) {
    LeaderboardPeriod.week => l10n.ratingPeriodWeek,
    LeaderboardPeriod.month => l10n.ratingPeriodMonth,
    LeaderboardPeriod.allTime => l10n.ratingPeriodAllTime,
  };
}

/// Название показателя сравнения.
extension LeaderboardMetricLabel on LeaderboardMetric {
  /// Возвращает название на языке интерфейса.
  String label(AppLocalizations l10n) => switch (this) {
    LeaderboardMetric.maxWeight => l10n.ratingMetricMaxWeight,
    LeaderboardMetric.estimatedOneRepMax => l10n.ratingMetricE1rm,
  };
}

/// Название пола.
extension SexLabel on Sex {
  /// Возвращает название на языке интерфейса.
  String label(AppLocalizations l10n) => switch (this) {
    Sex.male => l10n.ratingSexMale,
    Sex.female => l10n.ratingSexFemale,
  };
}

/// Название весовой категории; границы IPF заданы в килограммах.
extension WeightClassLabel on WeightClass {
  /// «до 83 кг» или «120+ кг».
  String label(AppLocalizations l10n) {
    final bound = upperKg.toInt();
    return open
        ? l10n.ratingWeightClassOver(bound)
        : l10n.ratingWeightClassUpTo(bound);
  }
}

/// Название статуса проверки.
extension RecordStatusLabel on RecordStatus {
  /// Возвращает название на языке интерфейса.
  String label(AppLocalizations l10n) => switch (this) {
    RecordStatus.pending => l10n.recordStatusPending,
    RecordStatus.approved => l10n.recordStatusApproved,
    RecordStatus.rejected => l10n.recordStatusRejected,
  };
}

/// Название значка рекордсмена.
extension RecordBadgeLabel on RecordBadge {
  /// Возвращает название на языке интерфейса.
  String label(AppLocalizations l10n) => switch (this) {
    RecordBadge.firstRecord => l10n.badgeFirstRecord,
    RecordBadge.gymTop3 => l10n.badgeGymTop3,
  };
}
