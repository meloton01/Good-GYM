import 'package:cloud_functions/cloud_functions.dart';

import '../../../core/errors/app_failure.dart';

/// Переводит ошибку вызова функции в ошибку приложения по details.reason, иначе по коду.
AppFailure mapFunctionsFailure(FirebaseFunctionsException error) {
  final details = error.details;
  final reason = details is Map ? details['reason'] : null;
  return switch (reason) {
    'no-gym' => AppFailure.noGym,
    'video-missing' || 'video-invalid' => AppFailure.videoInvalid,
    'own-record' => AppFailure.ownRecord,
    'not-pending' => AppFailure.recordReviewed,
    'appeal-unavailable' => AppFailure.appealUnavailable,
    'too-many-records' => AppFailure.tooManyRequests,
    'video-hidden' || 'moderator-only' => AppFailure.permissionDenied,
    _ => switch (error.code) {
      'unauthenticated' || 'permission-denied' => AppFailure.permissionDenied,
      'not-found' => AppFailure.notFound,
      'invalid-argument' || 'failed-precondition' => AppFailure.invalidInput,
      'resource-exhausted' => AppFailure.tooManyRequests,
      'unavailable' || 'deadline-exceeded' => AppFailure.network,
      _ => AppFailure.unknown,
    },
  };
}
