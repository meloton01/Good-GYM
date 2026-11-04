import '../../../core/errors/result.dart';
import 'auth_user.dart';

/// Вход, регистрация и управление учётной записью; реализация не зависит от UI.
abstract interface class AuthRepository {
  /// Поток текущей учётной записи, включая смену статуса подтверждения email.
  Stream<AuthUser?> watchAuthUser();

  /// Вход по email и паролю.
  Future<Result<void>> signInWithEmail({
    required String email,
    required String password,
  });

  /// Регистрация по email и паролю с отправкой письма для подтверждения.
  Future<Result<void>> signUpWithEmail({
    required String email,
    required String password,
    required String languageCode,
  });

  /// Вход через Google.
  Future<Result<void>> signInWithGoogle();

  /// Вход через Apple.
  Future<Result<void>> signInWithApple();

  /// Отправляет письмо для подтверждения email ещё раз на языке [languageCode].
  Future<Result<void>> sendEmailVerification({required String languageCode});

  /// Перечитывает учётную запись с сервера и возвращает, подтверждён ли email.
  Future<Result<bool>> reloadEmailVerification();

  /// Отправляет письмо для сброса пароля.
  Future<Result<void>> sendPasswordReset(
    String email, {
    required String languageCode,
  });

  /// Выход из учётной записи.
  Future<Result<void>> signOut();

  /// Подтверждает личность перед опасным действием: паролем или повторным входом через провайдера.
  Future<Result<void>> reauthenticate({String? password});

  /// Меняет пароль; требует недавнего [reauthenticate].
  Future<Result<void>> changePassword(String newPassword);

  /// Отправляет письмо на новый email; адрес сменится после перехода по ссылке.
  Future<Result<void>> changeEmail(
    String newEmail, {
    required String languageCode,
  });

  /// Удаляет учётную запись; требует недавнего [reauthenticate].
  Future<Result<void>> deleteAccount();
}
