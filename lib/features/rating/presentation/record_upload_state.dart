import '../../../core/errors/app_failure.dart';

/// Этап загрузки видео рекорда.
enum UploadPhase { idle, preparing, uploading, paused, failed, done }

/// Видео рекорда: локальный файл, id загрузки, прогресс и ошибка.
class RecordUploadState {
  /// Создаёт состояние; [uploadId] задан, когда загрузка запущена.
  const RecordUploadState({
    this.phase = UploadPhase.idle,
    this.videoPath,
    this.uploadId,
    this.progress = 0,
    this.failure,
  });

  final UploadPhase phase;
  final String? videoPath;
  final String? uploadId;
  final double progress;
  final AppFailure? failure;

  /// Видео загружено, рекорд можно отправлять.
  bool get isReady => phase == UploadPhase.done && uploadId != null;

  /// Копия с изменёнными полями; [failure] сбрасывается, если не передан.
  RecordUploadState copyWith({
    UploadPhase? phase,
    String? videoPath,
    String? uploadId,
    double? progress,
    AppFailure? failure,
  }) {
    return RecordUploadState(
      phase: phase ?? this.phase,
      videoPath: videoPath ?? this.videoPath,
      uploadId: uploadId ?? this.uploadId,
      progress: progress ?? this.progress,
      failure: failure,
    );
  }
}
