import '../../../core/errors/result.dart';
import 'user_profile.dart';
import 'user_role.dart';

/// Чтение и изменение профилей пользователей.
abstract interface class UserProfileRepository {
  /// Поток профиля по uid; null, если профиль ещё не создан.
  Stream<UserProfile?> watchProfile(String uid);

  /// Создаёт профиль и закрепляет ник; занятый ник даёт AppFailure.nicknameTaken.
  Future<Result<void>> createProfile({
    required String uid,
    required String nickname,
    required UserRole role,
  });

  /// Меняет роль на одну из [UserRole.selectable].
  Future<Result<void>> updateRole({
    required String uid,
    required UserRole role,
  });
}
