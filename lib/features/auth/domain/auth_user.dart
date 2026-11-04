import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_user.freezed.dart';

/// Учётная запись, под которой выполнен вход.
@freezed
abstract class AuthUser with _$AuthUser {
  /// Создаёт данные учётной записи.
  const factory AuthUser({
    required String uid,
    String? email,
    @Default(false) bool emailVerified,
  }) = _AuthUser;
}
