import 'package:firebase_core/firebase_core.dart';

import '../errors/app_failure.dart';

/// Переводит код ошибки Firestore в ошибку приложения.
AppFailure mapFirestoreFailure(FirebaseException error) {
  return switch (error.code) {
    'permission-denied' || 'unauthenticated' => AppFailure.permissionDenied,
    'not-found' => AppFailure.notFound,
    'unavailable' || 'deadline-exceeded' => AppFailure.network,
    'invalid-argument' || 'failed-precondition' => AppFailure.invalidInput,
    'resource-exhausted' => AppFailure.tooManyRequests,
    _ => AppFailure.unknown,
  };
}

/// Переводит ошибку потока данных в ошибку приложения.
AppFailure failureFromError(Object? error) {
  return error is FirebaseException
      ? mapFirestoreFailure(error)
      : AppFailure.unknown;
}
