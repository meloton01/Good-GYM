import 'package:freezed_annotation/freezed_annotation.dart';

import 'leaderboard_metric.dart';
import 'leaderboard_period.dart';
import 'rating_exercise.dart';
import 'sex.dart';
import 'weight_class.dart';

part 'leaderboard_query.freezed.dart';

/// Фильтры таблицы рекордов.
@freezed
abstract class LeaderboardQuery with _$LeaderboardQuery {
  /// Создаёт фильтр; [gymId] null означает общий рейтинг, [weightClass] задаёт и пол.
  const factory LeaderboardQuery({
    @Default(RatingExercise.squat) RatingExercise exercise,
    String? gymId,
    @Default(LeaderboardPeriod.allTime) LeaderboardPeriod period,
    @Default(LeaderboardMetric.maxWeight) LeaderboardMetric metric,
    Sex? sex,
    WeightClass? weightClass,
  }) = _LeaderboardQuery;
}
