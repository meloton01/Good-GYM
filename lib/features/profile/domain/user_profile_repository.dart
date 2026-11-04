import '../../../core/errors/result.dart';
import 'body_metrics.dart';
import 'user_profile.dart';
import 'user_role.dart';

/// Чтение и изменение профилей пользователей и их приватных данных.
abstract interface class UserProfileRepository {
  /// Поток профиля по uid; null, если профиль ещё не создан.
  Stream<UserProfile?> watchProfile(String uid);

  /// Создаёт профиль и закрепляет ник; занятый ник даёт AppFailure.nicknameTaken.
  Future<Result<void>> createProfile({
    required String uid,
    required String nickname,
    required UserRole role,
  });

  /// Сохраняет изменения профиля; при смене ника освобождает старый.
  Future<Result<void>> updateProfile(UserProfile profile);

  /// Меняет роль на одну из [UserRole.selectable].
  Future<Result<void>> updateRole({
    required String uid,
    required UserRole role,
  });

  /// Поток приватных данных о теле владельца.
  Stream<BodyMetrics> watchBodyMetrics(String uid);

  /// Сохраняет приватные данные о теле.
  Future<Result<void>> saveBodyMetrics(String uid, BodyMetrics metrics);

  /// Собирает все данные пользователя для выгрузки.
  Future<Result<Map<String, Object?>>> exportData(String uid);

  /// Удаляет профиль, ник и приватные данные пользователя.
  Future<Result<void>> deleteAllData(String uid);
}
