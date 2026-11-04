import '../domain/body_metrics.dart';
import '../domain/profile_visibility.dart';
import '../domain/user_profile.dart';
import '../domain/user_role.dart';
import 'user_profile_fields.dart';

/// Перевод профиля и данных о теле между моделями и документами Firestore.
abstract final class UserProfileMapper {
  /// Собирает профиль из документа; без ника или с неизвестной ролью бросает FormatException.
  static UserProfile fromMap(String uid, Map<String, dynamic> data) {
    final role = _enum(data[UserProfileFields.role], UserRole.values);
    final nickname = data[UserProfileFields.nickname];
    if (role == null || nickname is! String) {
      throw const FormatException(
        'users document has invalid nickname or role',
      );
    }
    final bio = data[UserProfileFields.bio];
    final gymId = data[UserProfileFields.gymId];
    final gymName = data[UserProfileFields.gymName];
    return UserProfile(
      uid: uid,
      nickname: nickname,
      role: role,
      bio: bio is String ? bio : '',
      gymId: gymId is String ? gymId : null,
      gymName: gymName is String ? gymName : null,
      profileVisibility:
          _enum(
            data[UserProfileFields.profileVisibility],
            ProfileVisibility.values,
          ) ??
          ProfileVisibility.everyone,
      recordsVisibility:
          _enum(
            data[UserProfileFields.recordsVisibility],
            ProfileVisibility.values,
          ) ??
          ProfileVisibility.everyone,
    );
  }

  /// Поля профиля, которые владелец меняет на экране редактирования.
  static Map<String, Object?> editableFields(UserProfile profile) {
    return {
      UserProfileFields.nickname: profile.nickname,
      UserProfileFields.bio: profile.bio,
      UserProfileFields.gymId: profile.gymId,
      UserProfileFields.gymName: profile.gymName,
      UserProfileFields.profileVisibility: profile.profileVisibility.name,
      UserProfileFields.recordsVisibility: profile.recordsVisibility.name,
    };
  }

  /// Собирает данные о теле из документа; отсутствующий документ даёт пустые данные.
  static BodyMetrics bodyFromMap(Map<String, dynamic>? data) {
    final weight = data?[UserProfileFields.weightKg];
    final height = data?[UserProfileFields.heightCm];
    return BodyMetrics(
      weightKg: weight is num ? weight.toDouble() : null,
      heightCm: height is num ? height.toDouble() : null,
    );
  }

  /// Поля документа с данными о теле.
  static Map<String, Object?> bodyToMap(BodyMetrics metrics) {
    return {
      UserProfileFields.weightKg: metrics.weightKg,
      UserProfileFields.heightCm: metrics.heightCm,
    };
  }

  /// Читает enum по имени или null, если значение неизвестно.
  static T? _enum<T extends Enum>(Object? name, List<T> values) {
    return name is String ? values.asNameMap()[name] : null;
  }
}
