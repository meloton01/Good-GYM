import '../../../core/constants/app_limits.dart';
import '../../../core/errors/result.dart';
import '../../../core/pagination/paged_result.dart';
import 'gym_record.dart';
import 'leaderboard_query.dart';
import 'record_submission.dart';

/// Рекорды, таблицы рейтинга и очередь модерации.
abstract interface class RecordRepository {
  /// Возвращает страницу одобренных рекордов по фильтру.
  Future<Result<PagedResult<GymRecord>>> fetchLeaderboard(
    LeaderboardQuery query, {
    String? cursor,
    int limit = AppLimits.pageSize,
  });

  /// Поток всех рекордов пользователя с любым статусом.
  Stream<List<GymRecord>> watchUserRecords(String uid);

  /// Отправляет рекорд на проверку; статус всегда pending.
  Future<Result<GymRecord>> submitRecord(RecordSubmission submission);

  /// Подаёт единственное обжалование отказа.
  Future<Result<void>> appealRejection(String recordId);

  /// Возвращает страницу рекордов, ожидающих проверки, кроме своих.
  Future<Result<PagedResult<GymRecord>>> fetchModerationQueue({
    String? cursor,
    int limit = AppLimits.pageSize,
  });

  /// Одобряет рекорд; выполняется на сервере.
  Future<Result<void>> approveRecord(String recordId);

  /// Отклоняет рекорд с причиной; выполняется на сервере.
  Future<Result<void>> rejectRecord(String recordId, {required String reason});
}
