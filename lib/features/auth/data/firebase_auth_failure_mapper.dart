import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/errors/app_failure.dart';

/// Переводит код ошибки Firebase Auth в ошибку приложения.
AppFailure mapFirebaseAuthFailure(FirebaseAuthException error) {
  return switch (error.code) {
    'invalid-credential' ||
    'wrong-password' ||
    'user-not-found' ||
    'invalid-login-credentials' => AppFailure.invalidCredentials,
    'invalid-email' => AppFailure.invalidInput,
    'email-already-in-use' => AppFailure.emailAlreadyInUse,
    'weak-password' => AppFailure.weakPassword,
    'too-many-requests' => AppFailure.tooManyRequests,
    'network-request-failed' => AppFailure.network,
    'user-disabled' => AppFailure.permissionDenied,
    'account-exists-with-different-credential' =>
      AppFailure.accountExistsWithDifferentCredential,
    'operation-not-allowed' ||
    'invalid-api-key' ||
    'app-not-authorized' => AppFailure.providerUnavailable,
    'canceled' ||
    'web-context-canceled' ||
    'popup-closed-by-user' ||
    'cancelled-popup-request' => AppFailure.cancelled,
    'requires-recent-login' ||
    'user-mismatch' => AppFailure.requiresRecentLogin,
    _ => AppFailure.unknown,
  };
}

/// Переводит код ошибки Google Sign-In в ошибку приложения.
AppFailure mapGoogleSignInFailure(GoogleSignInExceptionCode code) {
  return switch (code) {
    GoogleSignInExceptionCode.canceled ||
    GoogleSignInExceptionCode.interrupted => AppFailure.cancelled,
    GoogleSignInExceptionCode.clientConfigurationError ||
    GoogleSignInExceptionCode.providerConfigurationError ||
    GoogleSignInExceptionCode.uiUnavailable => AppFailure.providerUnavailable,
    _ => AppFailure.unknown,
  };
}
