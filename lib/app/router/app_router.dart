import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/reset_password_screen.dart';
import '../../features/auth/presentation/sign_in_screen.dart';
import '../../features/auth/presentation/sign_up_screen.dart';
import '../../features/auth/presentation/verify_email_screen.dart';
import '../../features/profile/presentation/profile_setup_screen.dart';
import '../session/session_error_screen.dart';
import '../session/session_provider.dart';
import '../session/splash_screen.dart';
import '../tabs_registry.dart';
import 'app_routes.dart';
import 'app_shell.dart';
import 'session_redirect.dart';

/// Роутер приложения: экраны сессии и по одной ветке на каждую вкладку из реестра.
final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(sessionProvider, (previous, next) => refresh.value++);

  final router = GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: refresh,
    redirect: (context, state) => sessionRedirect(
      ref.read(sessionProvider),
      state.matchedLocation,
      homePath: appTabs.first.path,
    ),
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.sessionError,
        builder: (context, state) => const SessionErrorScreen(),
      ),
      GoRoute(
        path: AppRoutes.signIn,
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: AppRoutes.signUp,
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        builder: (context, state) => const ResetPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.verifyEmail,
        builder: (context, state) => const VerifyEmailScreen(),
      ),
      GoRoute(
        path: AppRoutes.profileSetup,
        builder: (context, state) => const ProfileSetupScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell, tabs: appTabs),
        branches: [
          for (final tab in appTabs)
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: tab.path,
                  builder: (context, state) => tab.builder(context),
                  routes: tab.routes,
                ),
              ],
            ),
        ],
      ),
    ],
  );
  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });
  return router;
});
