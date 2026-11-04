import 'package:freezed_annotation/freezed_annotation.dart';

import 'user_role.dart';

part 'user_profile.freezed.dart';

/// Публичная часть профиля пользователя.
@freezed
abstract class UserProfile with _$UserProfile {
  /// Создаёт профиль пользователя.
  const factory UserProfile({
    required String uid,
    required String nickname,
    required UserRole role,
  }) = _UserProfile;
}
