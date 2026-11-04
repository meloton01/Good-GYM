/// Типы ошибок, которые слой данных отдаёт в UI вместо технических исключений.
enum AppFailure {
  network,
  permissionDenied,
  notFound,
  invalidInput,
  storage,
  invalidCredentials,
  emailAlreadyInUse,
  weakPassword,
  tooManyRequests,
  nicknameTaken,
  accountExistsWithDifferentCredential,
  providerUnavailable,
  cancelled,
  requiresRecentLogin,
  unknown,
}
