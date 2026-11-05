import 'package:freezed_annotation/freezed_annotation.dart';

import 'rating_exercise.dart';
import 'record_status.dart';
import 'sex.dart';

part 'gym_record.freezed.dart';

/// Рекорд с видео и статусом проверки; видео открывается по временной ссылке.
@freezed
abstract class GymRecord with _$GymRecord {
  /// Создаёт данные рекорда; [e1rmKg] и [weightClassId] считает сервер.
  const factory GymRecord({
    required String id,
    required String uid,
    required String nickname,
    required String gymName,
    required RatingExercise exercise,
    required double weightKg,
    required int reps,
    required double e1rmKg,
    required Sex sex,
    required String weightClassId,
    required RecordStatus status,
    required DateTime performedAt,
    DateTime? createdAt,
    String? moderatorId,
    String? rejectionReason,
    @Default(false) bool appealed,
  }) = _GymRecord;

  const GymRecord._();

  /// Автор может обжаловать отказ один раз.
  bool get canAppeal => status == RecordStatus.rejected && !appealed;

  /// Ждёт ли рекорд проверки модератором [moderatorId]; свои рекорды модератор не проверяет.
  bool isReviewableBy(String moderatorId) =>
      status == RecordStatus.pending && uid != moderatorId;
}
