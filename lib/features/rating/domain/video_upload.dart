import '../../../core/errors/result.dart';

/// Идущая загрузка видео: прогресс, пауза и продолжение после обрыва.
abstract interface class VideoUpload {
  /// Доля загруженного от 0 до 1.
  Stream<double> get progress;

  /// Завершается, когда файл загружен или загрузка не удалась.
  Future<Result<void>> get done;

  /// Ставит загрузку на паузу.
  Future<void> pause();

  /// Продолжает загрузку с места остановки.
  Future<void> resume();

  /// Отменяет загрузку.
  Future<void> cancel();
}
