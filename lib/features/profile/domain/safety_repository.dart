import '../../../core/constants/app_limits.dart';
import '../../../core/errors/result.dart';
import '../../../core/pagination/paged_result.dart';
import 'blocked_user.dart';
import 'user_report.dart';

/// Жалобы на пользователей и контент, блокировка пользователей.
abstract interface class SafetyRepository {
  /// Поток: заблокировал ли [uid] пользователя [otherUid].
  Stream<bool> watchIsBlocked({required String uid, required String otherUid});

  /// Страница заблокированных пользователей, новые сверху.
  Future<Result<PagedResult<BlockedUser>>> fetchBlocked(
    String uid, {
    String? cursor,
    int limit = AppLimits.pageSize,
  });

  /// Блокирует пользователя [user] от имени [uid].
  Future<Result<void>> block(String uid, BlockedUser user);

  /// Снимает блокировку пользователя [otherUid].
  Future<Result<void>> unblock({required String uid, required String otherUid});

  /// Отправляет жалобу; повторная жалоба на ту же цель не создаёт новую.
  Future<Result<void>> report(UserReport report);

  /// Собирает блокировки и жалобы пользователя для выгрузки.
  Future<Result<Map<String, Object?>>> exportData(String uid);

  /// Удаляет блокировки и жалобы пользователя.
  Future<Result<void>> deleteAllData(String uid);
}
