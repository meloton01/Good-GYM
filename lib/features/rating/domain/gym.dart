import 'package:freezed_annotation/freezed_annotation.dart';

part 'gym.freezed.dart';

/// Спортзал, внутри которого считается рейтинг.
@freezed
abstract class Gym with _$Gym {
  /// Создаёт данные зала.
  const factory Gym({
    required String id,
    required String name,
    required String city,
    required String creatorId,
  }) = _Gym;
}
