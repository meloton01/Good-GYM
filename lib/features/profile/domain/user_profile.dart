import 'package:freezed_annotation/freezed_annotation.dart';

import 'profile_visibility.dart';
import 'user_role.dart';

part 'user_profile.freezed.dart';

/// Профиль пользователя без приватных данных о теле.
@freezed
abstract class UserProfile with _$UserProfile {
  /// Создаёт профиль; [gymName] хранится рядом с [gymId], чтобы не читать зал отдельно.
  const factory UserProfile({
    required String uid,
    required String nickname,
    required UserRole role,
    @Default('') String bio,
    String? gymId,
    String? gymName,
    @Default(ProfileVisibility.everyone) ProfileVisibility profileVisibility,
    @Default(ProfileVisibility.everyone) ProfileVisibility recordsVisibility,
  }) = _UserProfile;
}
