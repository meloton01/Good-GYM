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

  static const String workoutPlanSegment = 'plan';
  static const String workoutPlan = '/workout/$workoutPlanSegment';
  static const String workoutSessionSegment = 'session';
  static const String workoutSession = '/workout/$workoutSessionSegment';
  static const String exercisePickerSegment = 'exercises';
  static const String exercisePicker = '/workout/$exercisePickerSegment';
  static const String workoutTemplateSegment = 'templates/:templateId';
  static const String workoutDetailSegment = 'history/:workoutId';
  static const String exerciseProgressSegment = 'progress/:exerciseId';
  static const String coachQrSegment = 'coach/qr';
  static const String coachQr = '/workout/$coachQrSegment';
  static const String coachScanSegment = 'coach/scan';
  static const String coachScan = '/workout/$coachScanSegment';
  static const String studentSegment = 'students/:athleteId';
  static const String planEditorSegment = 'plan-editor';
  static const String planDetailSegment = 'plans/:athleteId/:planId';
  static const String myPlansSegment = 'plans';
  static const String myPlans = '/workout/$myPlansSegment';

  /// Параметр запроса с uid владельца тренировки, если это не текущий пользователь.
  static const String ownerParameter = 'owner';

  /// Путь редактора сохранённого шаблона.
  static String workoutTemplate(String templateId) =>
      '/workout/templates/$templateId';

  /// Путь завершённой тренировки; [owner] задан, когда тренер смотрит тренировку ученика.
  static String workoutDetail(String workoutId, {String? owner}) =>
      _withOwner('/workout/history/$workoutId', owner);

  /// Путь графика прогресса по упражнению; [owner] задан для ученика тренера.
  static String exerciseProgress(String exerciseId, {String? owner}) =>
      _withOwner('/workout/progress/$exerciseId', owner);

  /// Путь экрана ученика у тренера.
  static String student(String athleteId) => '/workout/students/$athleteId';

  /// Путь редактора плана для ученика.
  static String planEditor(String athleteId) =>
      '${student(athleteId)}/$planEditorSegment';

  /// Путь плана тренера.
  static String planDetail(String athleteId, String planId) =>
      '/workout/plans/$athleteId/$planId';

  /// Добавляет uid владельца в запрос, если он задан.
  static String _withOwner(String path, String? owner) => owner == null
      ? path
      : Uri(path: path, queryParameters: {ownerParameter: owner}).toString();

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
