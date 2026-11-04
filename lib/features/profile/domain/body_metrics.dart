import 'package:freezed_annotation/freezed_annotation.dart';

part 'body_metrics.freezed.dart';

/// Вес и рост пользователя; видны только владельцу.
@freezed
abstract class BodyMetrics with _$BodyMetrics {
  /// Создаёт данные о теле в метрических единицах.
  const factory BodyMetrics({double? weightKg, double? heightCm}) =
      _BodyMetrics;
}
