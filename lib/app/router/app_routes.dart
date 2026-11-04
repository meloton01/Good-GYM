/// Пути экранов вне вкладок.
abstract final class AppRoutes {
  static const String splash = '/splash';
  static const String sessionError = '/session-error';
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  static const String resetPassword = '/reset-password';
  static const String verifyEmail = '/verify-email';
  static const String profileSetup = '/profile-setup';

  /// Вложенные экраны вкладок: сегмент для GoRoute и полный путь для перехода.
  static const String appearanceSegment = 'appearance';
  static const String appearance = '/settings/$appearanceSegment';
  static const String changeEmailSegment = 'change-email';
  static const String changeEmail = '/settings/$changeEmailSegment';
  static const String changePasswordSegment = 'change-password';
  static const String changePassword = '/settings/$changePasswordSegment';
  static const String profileEditSegment = 'edit';
  static const String profileEdit = '/profile/$profileEditSegment';
  static const String gymPickerSegment = 'gym';
  static const String gymPicker = '$profileEdit/$gymPickerSegment';
  static const String publicProfileSegment = 'users/:uid';

  /// Путь публичного профиля пользователя.
  static String publicProfile(String uid) => '/profile/users/$uid';

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
