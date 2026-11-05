import '../../../core/firebase/firestore_date.dart';
import '../domain/gym_record.dart';
import '../domain/leaderboard_entry.dart';
import '../domain/rating_exercise.dart';
import '../domain/record_status.dart';
import '../domain/sex.dart';
import 'record_fields.dart';

/// Разбор документов рекордов и таблиц; повреждённые документы дают null.
abstract final class RecordMapper {
  /// Рекорд из документа records/{id}.
  static GymRecord? recordFromMap(String id, Map<String, dynamic> data) {
    final exercise = RatingExercise.fromId(
      data[RecordFields.exerciseId] as String?,
    );
    final status = RecordStatus.values.asNameMap()[data[RecordFields.status]];
    final sex = Sex.values.asNameMap()[data[RecordFields.sex]];
    final performedAt = readFirestoreDate(data[RecordFields.performedAt]);
    final uid = data[RecordFields.uid];
    final weight = data[RecordFields.weightKg];
    final reps = data[RecordFields.reps];
    final e1rm = data[RecordFields.e1rmKg];
    if (exercise == null ||
        status == null ||
        sex == null ||
        performedAt == null ||
        uid is! String ||
        weight is! num ||
        reps is! int ||
        e1rm is! num) {
      return null;
    }
    return GymRecord(
      id: id,
      uid: uid,
      nickname: _text(data[RecordFields.nickname]),
      gymName: _text(data[RecordFields.gymName]),
      exercise: exercise,
      weightKg: weight.toDouble(),
      reps: reps,
      e1rmKg: e1rm.toDouble(),
      sex: sex,
      weightClassId: _text(data[RecordFields.weightClass]),
      status: status,
      performedAt: performedAt,
      createdAt: readFirestoreDate(data[RecordFields.createdAt]),
      moderatorId: data[RecordFields.moderatorId] as String?,
      rejectionReason: data[RecordFields.rejectionReason] as String?,
      appealed: data[RecordFields.appealed] == true,
    );
  }

  /// Строка таблицы из документа leaderboard/{id}.
  static LeaderboardEntry? entryFromMap(Map<String, dynamic> data) {
    final exercise = RatingExercise.fromId(
      data[RecordFields.exerciseId] as String?,
    );
    final uid = data[RecordFields.uid];
    final weight = data[RecordFields.bestWeightKg];
    final e1rm = data[RecordFields.bestE1rmKg];
    if (exercise == null || uid is! String || weight is! num || e1rm is! num) {
      return null;
    }
    return LeaderboardEntry(
      uid: uid,
      nickname: _text(data[RecordFields.nickname]),
      gymName: _text(data[RecordFields.gymName]),
      exercise: exercise,
      bestWeightKg: weight.toDouble(),
      bestWeightRecordId: _text(data[RecordFields.bestWeightRecordId]),
      bestE1rmKg: e1rm.toDouble(),
      bestE1rmRecordId: _text(data[RecordFields.bestE1rmRecordId]),
      weightClassId: _text(data[RecordFields.weightClass]),
    );
  }

  /// Строка или пустая строка для отсутствующего поля.
  static String _text(Object? value) => value is String ? value : '';
}
