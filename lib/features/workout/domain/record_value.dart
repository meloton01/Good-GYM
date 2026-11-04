import 'package:freezed_annotation/freezed_annotation.dart';

part 'record_value.freezed.dart';

/// Значение личного рекорда и тренировка, в которой он поставлен.
@freezed
abstract class RecordValue with _$RecordValue {
  /// Создаёт значение рекорда.
  const factory RecordValue({
    required double value,
    required String workoutId,
    required DateTime achievedAt,
  }) = _RecordValue;
}
