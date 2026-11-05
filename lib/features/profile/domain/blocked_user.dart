import 'package:freezed_annotation/freezed_annotation.dart';

part 'blocked_user.freezed.dart';

/// Пользователь из списка заблокированных.
@freezed
abstract class BlockedUser with _$BlockedUser {
  /// Создаёт запись блокировки пользователя [uid] с ником на момент блокировки.
  const factory BlockedUser({
    required String uid,
    required String nickname,
    DateTime? blockedAt,
  }) = _BlockedUser;
}
