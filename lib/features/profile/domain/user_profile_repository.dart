import '../../../core/errors/result.dart';
import 'user_profile.dart';

/// Чтение и изменение профилей пользователей.
abstract interface class UserProfileRepository {
  /// Поток профиля по uid; null, если профиль ещё не создан.
  Stream<UserProfile?> watchProfile(String uid);

  /// Создаёт профиль после регистрации.
  Future<Result<void>> createProfile(UserProfile profile);

  /// Сохраняет изменения профиля, включая смену роли.
  Future<Result<void>> updateProfile(UserProfile profile);

  /// Проверяет, свободен ли ник.
  Future<Result<bool>> isNicknameAvailable(String nickname);
}
