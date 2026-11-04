import 'package:freezed_annotation/freezed_annotation.dart';

import 'record_status.dart';

part 'gym_record.freezed.dart';

/// Рекорд с видео и статусом проверки.
@freezed
abstract class GymRecord with _$GymRecord {
  /// Создаёт данные рекорда; [estimatedOneRepMaxKg] считает сервер.
  const factory GymRecord({
    required String id,
    required String uid,
    required String gymId,
    required String exerciseId,
    required double weightKg,
    required int reps,
    required double estimatedOneRepMaxKg,
    required String videoUrl,
    required RecordStatus status,
    required DateTime performedAt,
    required DateTime createdAt,
    String? moderatorId,
    String? rejectionReason,
    @Default(false) bool appealed,
  }) = _GymRecord;
}
