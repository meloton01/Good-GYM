import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_failure.dart';
import '../../../core/errors/result.dart';
import '../../../core/ids/random_id.dart';
import '../../auth/data/auth_repository_provider.dart';
import '../data/record_repository_providers.dart';
import '../domain/video_source.dart';
import '../domain/video_upload.dart';
import 'record_upload_state.dart';

/// Видео подаваемого рекорда; сбрасывается, когда экран подачи закрыт.
final recordUploadProvider =
    NotifierProvider.autoDispose<RecordUploadController, RecordUploadState>(
      RecordUploadController.new,
    );

/// Выбирает, сжимает и загружает видео; умеет паузу, продолжение и повтор.
class RecordUploadController extends Notifier<RecordUploadState> {
  VideoUpload? _upload;
  StreamSubscription<double>? _progress;
  bool _uploaded = false;

  /// Пустое состояние; при закрытии экрана незавершённая загрузка отменяется.
  @override
  RecordUploadState build() {
    ref.onDispose(() {
      _progress?.cancel();
      if (!_uploaded) {
        _upload?.cancel();
      }
    });
    return const RecordUploadState();
  }

  /// Берёт видео с камеры или из галереи и сразу начинает загрузку.
  Future<void> pick(VideoOrigin origin) async {
    final previous = state;
    state = const RecordUploadState(phase: UploadPhase.preparing);
    final result = await ref.read(videoSourceProvider).pick(origin);
    if (!ref.mounted) {
      return;
    }
    switch (result) {
      case null:
        state = previous;
      case Failure(:final failure):
        state = RecordUploadState(phase: UploadPhase.failed, failure: failure);
      case Success(:final value):
        await _start(value);
    }
  }

  /// Ставит загрузку на паузу.
  Future<void> pause() async {
    await _upload?.pause();
    state = state.copyWith(phase: UploadPhase.paused);
  }

  /// Продолжает загрузку с места остановки.
  Future<void> resume() async {
    await _upload?.resume();
    state = state.copyWith(phase: UploadPhase.uploading);
  }

  /// Загружает выбранное видео заново после ошибки.
  Future<void> retry() async {
    final path = state.videoPath;
    if (path != null) {
      await _start(path);
    }
  }

  /// Запускает загрузку файла [path] под новым id и следит за прогрессом.
  Future<void> _start(String path) async {
    final uid = ref.read(authUserProvider).value?.uid;
    if (uid == null) {
      state = const RecordUploadState(
        phase: UploadPhase.failed,
        failure: AppFailure.permissionDenied,
      );
      return;
    }
    await _progress?.cancel();
    final uploadId = randomId();
    final upload = ref
        .read(recordRepositoryProvider)
        .uploadVideo(uid: uid, uploadId: uploadId, localPath: path);
    _upload = upload;
    _uploaded = false;
    state = RecordUploadState(
      phase: UploadPhase.uploading,
      videoPath: path,
      uploadId: uploadId,
    );
    _progress = upload.progress.listen((value) {
      if (ref.mounted && state.phase != UploadPhase.done) {
        state = state.copyWith(progress: value, phase: state.phase);
      }
    });
    final result = await upload.done;
    if (!ref.mounted || _upload != upload) {
      return;
    }
    _uploaded = result is Success<void>;
    state = switch (result) {
      Success() => state.copyWith(phase: UploadPhase.done, progress: 1),
      Failure(:final failure) => state.copyWith(
        phase: UploadPhase.failed,
        failure: failure,
      ),
    };
  }
}
