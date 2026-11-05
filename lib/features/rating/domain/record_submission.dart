import 'package:freezed_annotation/freezed_annotation.dart';

import 'rating_exercise.dart';
import 'sex.dart';

part 'record_submission.freezed.dart';

/// Заявка на рекорд; вес тела нужен только для категории и не сохраняется в рекорде.
@freezed
abstract class RecordSubmission with _$RecordSubmission {
  /// Создаёт заявку для видео, уже загруженного под [uploadId].
  const factory RecordSubmission({
    required String uploadId,
    required RatingExercise exercise,
    required double weightKg,
    required int reps,
    required DateTime performedAt,
    required Sex sex,
    required double bodyWeightKg,
  }) = _RecordSubmission;
}
