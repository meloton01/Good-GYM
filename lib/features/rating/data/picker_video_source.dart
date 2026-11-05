import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_compress/video_compress.dart';

import '../../../core/errors/app_failure.dart';
import '../../../core/errors/result.dart';
import '../domain/record_limits.dart';
import '../domain/video_source.dart';

/// Видео с камеры или из галереи, сжатое на устройстве до среднего качества.
class PickerVideoSource implements VideoSource {
  /// Создаёт источник поверх image_picker.
  PickerVideoSource({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  /// Выбирает видео, сжимает его и проверяет длительность и размер.
  @override
  Future<Result<String>?> pick(VideoOrigin origin) async {
    final XFile? picked;
    try {
      picked = await _picker.pickVideo(
        source: origin == VideoOrigin.camera
            ? ImageSource.camera
            : ImageSource.gallery,
        maxDuration: RecordLimits.maxVideoDuration,
      );
    } on Exception catch (error) {
      return Failure(AppFailure.permissionDenied, cause: error);
    }
    if (picked == null) {
      return null;
    }
    return kIsWeb ? Success(picked.path) : _compress(picked.path);
  }

  /// Сжимает видео; слишком длинное или большое после сжатия отклоняет.
  Future<Result<String>> _compress(String path) async {
    final MediaInfo? info;
    try {
      info = await VideoCompress.compressVideo(
        path,
        quality: VideoQuality.MediumQuality,
        includeAudio: true,
      );
    } on Exception catch (error) {
      return Failure(AppFailure.videoInvalid, cause: error);
    }
    final file = info?.file;
    if (info == null || file == null) {
      return const Failure(AppFailure.videoInvalid);
    }
    final duration = Duration(milliseconds: (info.duration ?? 0).round());
    // Небольшой запас: камеры записывают на долю секунды дольше заданного лимита.
    if (duration > RecordLimits.maxVideoDuration + const Duration(seconds: 1)) {
      return const Failure(AppFailure.videoTooLong);
    }
    final size = await File(file.path).length();
    if (size == 0 || size > RecordLimits.maxVideoBytes) {
      return const Failure(AppFailure.videoInvalid);
    }
    return Success(file.path);
  }
}
