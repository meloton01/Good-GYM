import '../../../core/errors/result.dart';
import 'auth_user.dart';

/// Вход, регистрация и управление учётной записью; реализация не зависит от UI.
abstract interface class AuthRepository {
  /// Поток текущей учётной записи; null, если вход не выполнен.
  Stream<AuthUser?> watchAuthUser();

  /// Вход по email и паролю.
  Future<Result<AuthUser>> signInWithEmail({
    required String email,
    required String password,
  });

  /// Регистрация по email и паролю.
  Future<Result<AuthUser>> signUpWithEmail({
    required String email,
    required String password,
  });

  /// Вход через Google.
  Future<Result<AuthUser>> signInWithGoogle();

  /// Вход через Apple.
  Future<Result<AuthUser>> signInWithApple();

  /// Отправляет письмо для подтверждения email.
  Future<Result<void>> sendEmailVerification();

  /// Отправляет письмо для сброса пароля.
  Future<Result<void>> sendPasswordReset(String email);

  /// Выход из учётной записи.
  Future<Result<void>> signOut();

  /// Удаляет учётную запись и все данные пользователя.
  Future<Result<void>> deleteAccount();
}
