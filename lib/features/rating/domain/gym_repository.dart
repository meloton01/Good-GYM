import '../../../core/constants/app_limits.dart';
import '../../../core/errors/result.dart';
import '../../../core/pagination/paged_result.dart';
import 'gym.dart';

/// Поиск и создание залов.
abstract interface class GymRepository {
  /// Ищет залы по названию или городу постранично.
  Future<Result<PagedResult<Gym>>> searchGyms({
    required String query,
    String? cursor,
    int limit = AppLimits.pageSize,
  });

  /// Создаёт зал от имени текущего пользователя.
  Future<Result<Gym>> createGym({required String name, required String city});
}
