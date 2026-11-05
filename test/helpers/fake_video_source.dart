import 'package:good_gym/core/errors/result.dart';
import 'package:good_gym/features/rating/domain/video_source.dart';

/// Источник видео без камеры: сразу отдаёт [result].
class FakeVideoSource implements VideoSource {
  /// Создаёт источник; по умолчанию возвращает путь к сжатому видео.
  FakeVideoSource({this.result = const Success('/videos/lift.mp4')});

  Result<String>? result;

  /// Возвращает заданный результат.
  @override
  Future<Result<String>?> pick(VideoOrigin origin) async => result;
}
