import 'dart:async';

import 'package:firebase_storage/firebase_storage.dart';

import '../../../core/errors/app_failure.dart';
import '../../../core/errors/result.dart';
import '../domain/video_upload.dart';

/// Загрузка видео в Firebase Storage; SDK сам продолжает передачу после кратких обрывов сети.
class StorageVideoUpload implements VideoUpload {
  /// Оборачивает запущенную задачу загрузки [task].
  StorageVideoUpload(this._task);

  final UploadTask _task;

  /// Доля переданных байт из событий задачи.
  @override
  Stream<double> get progress => _task.snapshotEvents.map(
    (snapshot) => snapshot.totalBytes == 0
        ? 0
        : snapshot.bytesTransferred / snapshot.totalBytes,
  );

  /// Итог задачи: успех, отмена или ошибка Storage.
  @override
  Future<Result<void>> get done async {
    try {
      await _task;
      return const Success(null);
    } on FirebaseException catch (error) {
      return Failure(_mapFailure(error), cause: error);
    }
  }

  /// Ставит задачу на паузу.
  @override
  Future<void> pause() => _task.pause();

  /// Продолжает задачу.
  @override
  Future<void> resume() => _task.resume();

  /// Отменяет задачу.
  @override
  Future<void> cancel() => _task.cancel();

  /// Код ошибки Storage в ошибку приложения.
  static AppFailure _mapFailure(FirebaseException error) {
    return switch (error.code) {
      'canceled' => AppFailure.cancelled,
      'unauthorized' || 'unauthenticated' => AppFailure.videoInvalid,
      'retry-limit-exceeded' || 'unknown' => AppFailure.network,
      'quota-exceeded' => AppFailure.tooManyRequests,
      _ => AppFailure.unknown,
    };
  }
}
