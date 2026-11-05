/// Коллекции, поля и функции рекордов; совпадают с functions/ и firestore.rules.
abstract final class RecordFields {
  static const String records = 'records';
  static const String leaderboard = 'leaderboard';

  static const String uid = 'uid';
  static const String nickname = 'nickname';
  static const String gymId = 'gymId';
  static const String gymName = 'gymName';
  static const String exerciseId = 'exerciseId';
  static const String weightKg = 'weightKg';
  static const String reps = 'reps';
  static const String e1rmKg = 'e1rmKg';
  static const String sex = 'sex';
  static const String weightClass = 'weightClass';
  static const String status = 'status';
  static const String appealed = 'appealed';
  static const String moderatorId = 'moderatorId';
  static const String rejectionReason = 'rejectionReason';
  static const String performedAt = 'performedAt';
  static const String createdAt = 'createdAt';
  static const String videoPath = 'videoPath';

  static const String period = 'period';
  static const String scope = 'scope';
  static const String globalScope = 'global';
  static const String bestWeightKg = 'bestWeightKg';
  static const String bestWeightRecordId = 'bestWeightRecordId';
  static const String bestE1rmKg = 'bestE1rmKg';
  static const String bestE1rmRecordId = 'bestE1rmRecordId';

  static const String recordId = 'recordId';
  static const String uploadId = 'uploadId';
  static const String bodyWeightKg = 'bodyWeightKg';
  static const String reason = 'reason';
  static const String url = 'url';

  static const String functionsRegion = 'europe-west1';
  static const String submitRecord = 'submitRecord';
  static const String approveRecord = 'approveRecord';
  static const String rejectRecord = 'rejectRecord';
  static const String appealRecord = 'appealRecord';
  static const String recordVideoUrl = 'recordVideoUrl';
  static const String deleteRecordData = 'deleteRecordData';

  static const String videoContentType = 'video/mp4';

  /// Путь к видео в Storage; правила Storage разрешают только такие имена.
  static String videoPathFor(String uid, String uploadId) =>
      'records/$uid/$uploadId.mp4';
}
