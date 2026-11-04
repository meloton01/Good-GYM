import 'package:flutter_test/flutter_test.dart';
import 'package:good_gym/app/router/app_routes.dart';
import 'package:good_gym/app/router/session_redirect.dart';
import 'package:good_gym/app/session/session_state.dart';
import 'package:good_gym/core/errors/app_failure.dart';
import 'package:good_gym/features/auth/domain/auth_user.dart';
import 'package:good_gym/features/profile/domain/user_profile.dart';
import 'package:good_gym/features/profile/domain/user_role.dart';

void main() {
  const home = '/home';
  const user = AuthUser(uid: 'u', email: 'u@example.com', emailVerified: true);
  const profile = UserProfile(uid: 'u', nickname: 'u.u', role: UserRole.coach);

  String? redirect(SessionState session, String location) =>
      sessionRedirect(session, location, homePath: home);

  test('signed out user can open only auth screens', () {
    const session = SessionSignedOut();
    expect(redirect(session, home), AppRoutes.signIn);
    expect(redirect(session, AppRoutes.profileSetup), AppRoutes.signIn);
    expect(redirect(session, AppRoutes.signUp), isNull);
    expect(redirect(session, AppRoutes.resetPassword), isNull);
  });

  test('unverified and profileless users are held on their step', () {
    expect(
      redirect(const SessionEmailUnverified(user), home),
      AppRoutes.verifyEmail,
    );
    expect(
      redirect(const SessionNeedsProfile(user), AppRoutes.signIn),
      AppRoutes.profileSetup,
    );
    expect(
      redirect(const SessionNeedsProfile(user), AppRoutes.profileSetup),
      isNull,
    );
  });

  test('ready session leaves gates and keeps tab locations', () {
    const session = SessionReady(user, profile);
    expect(redirect(session, AppRoutes.signIn), home);
    expect(redirect(session, AppRoutes.splash), home);
    expect(redirect(session, '/settings'), isNull);
  });

  test('loading and errors show their screens', () {
    expect(redirect(const SessionLoading(), home), AppRoutes.splash);
    expect(
      redirect(const SessionError(AppFailure.network), home),
      AppRoutes.sessionError,
    );
  });
}
