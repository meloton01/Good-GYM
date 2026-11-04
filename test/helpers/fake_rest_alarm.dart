import 'package:good_gym/core/errors/result.dart';
import 'package:good_gym/features/workout/domain/rest_alarm.dart';
import 'package:good_gym/features/workout/domain/rest_alarm_text.dart';

/// Тестовый будильник отдыха: запоминает запланированное время.
class FakeRestAlarm implements RestAlarm {
  /// Время запланированного уведомления; null, если его нет.
  DateTime? scheduledAt;

  /// Результат, который вернёт schedule.
  Result<void> result = const Success(null);

  @override
  Future<Result<void>> schedule(DateTime at, RestAlarmText text) async {
    scheduledAt = at;
    return result;
  }

  @override
  Future<void> cancel() async {
    scheduledAt = null;
  }
}
