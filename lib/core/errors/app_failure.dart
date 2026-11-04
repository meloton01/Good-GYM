/// Типы ошибок, которые слой данных отдаёт в UI вместо технических исключений.
enum AppFailure {
  network,
  permissionDenied,
  notFound,
  invalidInput,
  storage,
  unknown,
}
