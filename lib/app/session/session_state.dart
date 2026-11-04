import '../../core/errors/app_failure.dart';
import '../../features/auth/domain/auth_user.dart';
import '../../features/profile/domain/user_profile.dart';

/// Состояние сессии, по которому роутер решает, какой экран показать.
sealed class SessionState {
  /// Базовый конструктор для наследников.
  const SessionState();
}

/// Учётная запись или профиль ещё загружаются.
final class SessionLoading extends SessionState {
  /// Создаёт состояние загрузки.
  const SessionLoading();
}

/// Вход не выполнен.
final class SessionSignedOut extends SessionState {
  /// Создаёт состояние без входа.
  const SessionSignedOut();
}

/// Вход по паролю выполнен, но email не подтверждён.
final class SessionEmailUnverified extends SessionState {
  /// Создаёт состояние ожидания подтверждения email.
  const SessionEmailUnverified(this.user);

  final AuthUser user;
}

/// Вход выполнен, профиль ещё не создан: нужно выбрать ник и роль.
final class SessionNeedsProfile extends SessionState {
  /// Создаёт состояние создания профиля.
  const SessionNeedsProfile(this.user);

  final AuthUser user;
}

/// Вход выполнен и профиль загружен.
final class SessionReady extends SessionState {
  /// Создаёт рабочее состояние сессии.
  const SessionReady(this.user, this.profile);

  final AuthUser user;
  final UserProfile profile;
}

/// Не удалось загрузить учётную запись или профиль.
final class SessionError extends SessionState {
  /// Создаёт состояние ошибки сессии.
  const SessionError(this.failure);

  final AppFailure failure;
}
