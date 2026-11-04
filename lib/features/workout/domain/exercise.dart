import 'package:freezed_annotation/freezed_annotation.dart';

import 'muscle_group.dart';

part 'exercise.freezed.dart';

/// Упражнение из библиотеки: встроенное или созданное пользователем.
@freezed
abstract class Exercise with _$Exercise {
  const Exercise._();

  /// Создаёт упражнение; у встроенного [customName] null и название берётся из ARB по [id].
  const factory Exercise({
    required String id,
    required MuscleGroup muscleGroup,
    String? customName,
  }) = _Exercise;

  /// Создано ли упражнение пользователем.
  bool get isCustom => customName != null;
}
