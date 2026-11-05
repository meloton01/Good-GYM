/// Ограничения рекордов; те же значения проверяет функция submitRecord.
abstract final class RecordLimits {
  static const double maxWeightKg = 500;
  static const int minReps = 1;
  static const int maxReps = 100;
  static const double minBodyWeightKg = 30;
  static const double maxBodyWeightKg = 300;
  static const int maxVideoBytes = 50 * 1024 * 1024;
  static const Duration maxVideoDuration = Duration(seconds: 60);
  static const int minReasonLength = 3;
  static const int maxReasonLength = 300;
  static const int maxPerformedAgeDays = 365;
}
