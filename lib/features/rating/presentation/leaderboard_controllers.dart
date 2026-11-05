import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/result.dart';
import '../../../core/pagination/paged_controller.dart';
import '../../../core/pagination/paged_result.dart';
import '../../../core/pagination/paged_state.dart';
import '../../../core/time/clock_provider.dart';
import '../../auth/data/auth_repository_provider.dart';
import '../../profile/data/user_profile_repository_provider.dart';
import '../data/record_repository_providers.dart';
import '../domain/gym_record.dart';
import '../domain/leaderboard_entry.dart';
import '../domain/leaderboard_query.dart';

/// Текущие фильтры таблицы; живут, пока открыто приложение.
final leaderboardFilterProvider =
    NotifierProvider<LeaderboardFilterController, LeaderboardQuery>(
      LeaderboardFilterController.new,
    );

/// Хранит фильтры таблицы.
class LeaderboardFilterController extends Notifier<LeaderboardQuery> {
  /// Присед за всё время в зале пользователя, если зал выбран, иначе общий рейтинг.
  @override
  LeaderboardQuery build() {
    final uid = ref.read(authUserProvider).value?.uid;
    final gymId = uid == null
        ? null
        : ref.read(userProfileProvider(uid)).value?.gymId;
    return LeaderboardQuery(gymId: gymId);
  }

  /// Заменяет фильтры.
  void update(LeaderboardQuery query) => state = query;
}

/// Таблица по фильтру с подгрузкой страниц.
final leaderboardProvider =
    NotifierProvider.family<
      LeaderboardController,
      PagedState<LeaderboardEntry>,
      LeaderboardQuery
    >(LeaderboardController.new);

/// Загружает строки таблицы страницами.
class LeaderboardController extends PagedController<LeaderboardEntry> {
  /// Создаёт контроллер для фильтра [query].
  LeaderboardController(this.query);

  final LeaderboardQuery query;

  /// Страница таблицы на текущую дату.
  @override
  Future<Result<PagedResult<LeaderboardEntry>>> fetchPage(String? cursor) {
    return ref
        .read(recordRepositoryProvider)
        .fetchLeaderboard(
          query,
          now: ref.read(clockProvider)(),
          cursor: cursor,
        );
  }
}

/// Очередь модератора с подгрузкой страниц.
final moderationQueueProvider =
    NotifierProvider<ModerationQueueController, PagedState<GymRecord>>(
      ModerationQueueController.new,
    );

/// Загружает рекорды на проверке страницами.
class ModerationQueueController extends PagedController<GymRecord> {
  /// Страница очереди, старые заявки сверху.
  @override
  Future<Result<PagedResult<GymRecord>>> fetchPage(String? cursor) {
    return ref
        .read(recordRepositoryProvider)
        .fetchModerationQueue(cursor: cursor);
  }
}

/// Одобренные рекорды пользователя с подгрузкой страниц.
final approvedRecordsProvider =
    NotifierProvider.family<
      ApprovedRecordsController,
      PagedState<GymRecord>,
      String
    >(ApprovedRecordsController.new);

/// Загружает историю одобренных рекордов страницами.
class ApprovedRecordsController extends PagedController<GymRecord> {
  /// Создаёт контроллер истории пользователя [uid].
  ApprovedRecordsController(this.uid);

  final String uid;

  /// Страница истории, новые сверху.
  @override
  Future<Result<PagedResult<GymRecord>>> fetchPage(String? cursor) {
    return ref
        .read(recordRepositoryProvider)
        .fetchApprovedRecords(uid, cursor: cursor);
  }
}
