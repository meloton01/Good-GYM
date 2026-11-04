import '../../../core/errors/result.dart';
import 'rest_alarm_text.dart';

/// Системное уведомление об окончании отдыха; срабатывает, даже если приложение свёрнуто.
abstract interface class RestAlarm {
  /// Планирует уведомление на [at] вместо предыдущего.
  Future<Result<void>> schedule(DateTime at, RestAlarmText text);

  /// Отменяет запланированное уведомление.
  Future<void> cancel();
}
