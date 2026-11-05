/// Допустимые значения полей профиля; совпадают с firestore.rules.
abstract final class ProfileLimits {
  static const int bioMaxLength = 300;
  static const double minWeightKg = 30;
  static const double maxWeightKg = 300;
  static const double minHeightCm = 100;
  static const double maxHeightCm = 250;
  static const int reportCommentMaxLength = 500;
}
