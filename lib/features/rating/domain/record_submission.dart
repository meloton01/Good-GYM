import 'package:freezed_annotation/freezed_annotation.dart';

part 'record_submission.freezed.dart';

/// Данные нового рекорда до загрузки видео на сервер.
@freezed
abstract class RecordSubmission with _$RecordSubmission {
  /// Создаёт заявку на рекорд; [videoPath] указывает на сжатое локальное видео.
  const factory RecordSubmission({
    required String gymId,
    required String exerciseId,
    required double weightKg,
    required int reps,
    required DateTime performedAt,
    required String videoPath,
  }) = _RecordSubmission;
}
