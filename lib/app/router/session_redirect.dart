import '../session/session_state.dart';
import 'app_routes.dart';

/// Возвращает путь для перенаправления по состоянию сессии или null, если экран подходит.
String? sessionRedirect(
  SessionState session,
  String location, {
  required String homePath,
}) {
  String? goTo(String path) => location == path ? null : path;

  return switch (session) {
    SessionLoading() => goTo(AppRoutes.splash),
    SessionError() => goTo(AppRoutes.sessionError),
    SessionSignedOut() =>
      AppRoutes.signedOut.contains(location) ? null : AppRoutes.signIn,
    SessionEmailUnverified() => goTo(AppRoutes.verifyEmail),
    SessionNeedsProfile() => goTo(AppRoutes.profileSetup),
    SessionReady() =>
      AppRoutes.sessionGates.contains(location) ? homePath : null,
  };
}
