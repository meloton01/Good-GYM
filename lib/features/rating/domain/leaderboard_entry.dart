import 'package:freezed_annotation/freezed_annotation.dart';

import 'rating_exercise.dart';

part 'leaderboard_entry.freezed.dart';

/// Лучшие одобренные результаты пользователя в одной таблице.
@freezed
abstract class LeaderboardEntry with _$LeaderboardEntry {
  /// Создаёт строку таблицы; значения в килограммах.
  const factory LeaderboardEntry({
    required String uid,
    required String nickname,
    required String gymName,
    required RatingExercise exercise,
    required double bestWeightKg,
    required String bestWeightRecordId,
    required double bestE1rmKg,
    required String bestE1rmRecordId,
    required String weightClassId,
  }) = _LeaderboardEntry;
}
