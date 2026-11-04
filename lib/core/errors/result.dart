import 'app_failure.dart';

/// Результат операции: значение или типизированная ошибка, без выброса исключений в UI.
sealed class Result<T> {
  /// Базовый конструктор для наследников.
  const Result();
}

/// Успешный результат со значением.
final class Success<T> extends Result<T> {
  /// Оборачивает значение успешной операции.
  const Success(this.value);

  final T value;
}

/// Неуспешный результат с причиной для пользователя и исходной ошибкой для логов.
final class Failure<T> extends Result<T> {
  /// Оборачивает ошибку операции.
  const Failure(this.failure, {this.cause});

  final AppFailure failure;
  final Object? cause;
}
