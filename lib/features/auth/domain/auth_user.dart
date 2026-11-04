import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_user.freezed.dart';

/// Учётная запись, под которой выполнен вход.
@freezed
abstract class AuthUser with _$AuthUser {
  const AuthUser._();

  /// Создаёт данные учётной записи; [usesPassword] true для входа по email и паролю.
  const factory AuthUser({
    required String uid,
    String? email,
    @Default(false) bool emailVerified,
    @Default(false) bool usesPassword,
  }) = _AuthUser;

  /// Нужно ли подтвердить email перед работой: только для входа по паролю.
  bool get needsEmailVerification => usesPassword && !emailVerified;
}
