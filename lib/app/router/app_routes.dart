/// Пути экранов вне вкладок.
abstract final class AppRoutes {
  static const String splash = '/splash';
  static const String sessionError = '/session-error';
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  static const String resetPassword = '/reset-password';
  static const String verifyEmail = '/verify-email';
  static const String profileSetup = '/profile-setup';

  /// Экраны, доступные без входа.
  static const Set<String> signedOut = {signIn, signUp, resetPassword};

  /// Служебные экраны сессии, с которых готовая сессия уводит во вкладки.
  static const Set<String> sessionGates = {
    splash,
    sessionError,
    verifyEmail,
    profileSetup,
    ...signedOut,
  };
}
