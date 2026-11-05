import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/result.dart';
import '../../../core/pagination/paged_controller.dart';
import '../../../core/pagination/paged_result.dart';
import '../../../core/pagination/paged_state.dart';
import '../../auth/data/auth_repository_provider.dart';
import '../data/safety_repository_provider.dart';
import '../domain/blocked_user.dart';

/// Заблокированные пользователи текущего пользователя с подгрузкой страниц.
final blockedUsersProvider =
    NotifierProvider<BlockedUsersController, PagedState<BlockedUser>>(
      BlockedUsersController.new,
    );

/// Загружает список заблокированных страницами.
class BlockedUsersController extends PagedController<BlockedUser> {
  /// Страница блокировок после [cursor]; без входа список пустой.
  @override
  Future<Result<PagedResult<BlockedUser>>> fetchPage(String? cursor) async {
    final uid = ref.read(authUserProvider).value?.uid;
    if (uid == null) {
      return const Success(PagedResult(items: []));
    }
    return ref.read(safetyRepositoryProvider).fetchBlocked(uid, cursor: cursor);
  }
}
