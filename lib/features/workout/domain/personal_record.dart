import 'package:freezed_annotation/freezed_annotation.dart';

import 'exercise.dart';
import 'record_value.dart';

part 'personal_record.freezed.dart';

/// Личные рекорды по упражнению; отдельно от рейтинга зала, без проверки видео.
@freezed
abstract class PersonalRecord with _$PersonalRecord {
  /// Создаёт рекорды упражнения; показатель null, если его ещё не было.
  const factory PersonalRecord({
    required Exercise exercise,
    RecordValue? maxWeightKg,
    RecordValue? bestE1rmKg,
    RecordValue? maxReps,
  }) = _PersonalRecord;
}
