import '../../../core/errors/result.dart';

/// Откуда взять видео рекорда.
enum VideoOrigin { camera, gallery }

/// Выбор и сжатие видео на устройстве перед загрузкой.
abstract interface class VideoSource {
  /// Путь к сжатому видео; null, если пользователь ничего не выбрал.
  Future<Result<String>?> pick(VideoOrigin origin);
}
