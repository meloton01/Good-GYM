import '../../../core/constants/app_limits.dart';
import '../../../core/errors/result.dart';
import '../../../core/pagination/paged_result.dart';
import 'gym_record.dart';
import 'leaderboard_entry.dart';
import 'leaderboard_query.dart';
import 'record_badge.dart';
import 'record_submission.dart';
import 'video_upload.dart';

/// Рекорды, таблицы рейтинга и очередь модерации; статус меняет только сервер.
abstract interface class RecordRepository {
  /// Страница таблицы по фильтру на дату [now].
  Future<Result<PagedResult<LeaderboardEntry>>> fetchLeaderboard(
    LeaderboardQuery query, {
    required DateTime now,
    String? cursor,
    int limit = AppLimits.pageSize,
  });

  /// Поток своих рекордов в любом статусе, новые сверху.
  Stream<List<GymRecord>> watchMyRecords(String uid, {int limit});

  /// Поток одного рекорда; null, если его нет или он скрыт.
  Stream<GymRecord?> watchRecord(String recordId);

  /// Страница одобренных рекордов пользователя, новые сверху.
  Future<Result<PagedResult<GymRecord>>> fetchApprovedRecords(
    String uid, {
    String? cursor,
    int limit = AppLimits.pageSize,
  });

  /// Значки пользователя по его лучшим результатам.
  Future<Result<Set<RecordBadge>>> fetchBadges(String uid);

  /// Начинает загрузку сжатого видео [localPath] под id [uploadId].
  VideoUpload uploadVideo({
    required String uid,
    required String uploadId,
    required String localPath,
  });

  /// Отправляет рекорд на проверку; статус всегда pending.
  Future<Result<void>> submitRecord(RecordSubmission submission);

  /// Подаёт единственное обжалование отказа.
  Future<Result<void>> appealRecord(String recordId);

  /// Страница рекордов на проверке, старые сверху.
  Future<Result<PagedResult<GymRecord>>> fetchModerationQueue({
    String? cursor,
    int limit = AppLimits.pageSize,
  });

  /// Одобряет рекорд; выполняется на сервере.
  Future<Result<void>> approveRecord(String recordId);

  /// Отклоняет рекорд с причиной; выполняется на сервере.
  Future<Result<void>> rejectRecord(String recordId, {required String reason});

  /// Временная ссылка на видео рекорда.
  Future<Result<Uri>> videoUrl(String recordId);

  /// Свои рекорды в виде, пригодном для JSON.
  Future<Result<List<Map<String, Object?>>>> exportData(String uid);

  /// Удаляет рекорды, строки таблиц и видео пользователя.
  Future<Result<void>> deleteAllData();
}
