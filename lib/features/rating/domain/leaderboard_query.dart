import 'package:freezed_annotation/freezed_annotation.dart';

import 'leaderboard_metric.dart';
import 'leaderboard_period.dart';

part 'leaderboard_query.freezed.dart';

/// Фильтры таблицы рекордов.
@freezed
abstract class LeaderboardQuery with _$LeaderboardQuery {
  /// Создаёт фильтр; [gymId] null означает общий рейтинг.
  const factory LeaderboardQuery({
    required String exerciseId,
    String? gymId,
    @Default(LeaderboardPeriod.allTime) LeaderboardPeriod period,
    @Default(LeaderboardMetric.maxWeight) LeaderboardMetric metric,
  }) = _LeaderboardQuery;
}
