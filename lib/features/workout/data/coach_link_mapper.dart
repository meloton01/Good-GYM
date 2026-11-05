import '../../../core/firebase/firestore_date.dart';
import '../domain/coach_link.dart';
import '../domain/coach_link_status.dart';
import 'workout_fields.dart';

/// Перевод связи тренер-ученик между моделью и документом coachLinks/{coachId_athleteId}.
abstract final class CoachLinkMapper {
  /// Собирает связь; null, если документ повреждён.
  static CoachLink? fromMap(String id, Map<String, dynamic> data) {
    final coachId = data[WorkoutFields.coachId];
    final athleteId = data[WorkoutFields.athleteId];
    final coachNickname = data[WorkoutFields.coachNickname];
    final athleteNickname = data[WorkoutFields.athleteNickname];
    final invitedBy = data[WorkoutFields.invitedBy];
    final status = data[WorkoutFields.status];
    final parsedStatus = status is String
        ? CoachLinkStatus.values.asNameMap()[status]
        : null;
    if (coachId is! String ||
        athleteId is! String ||
        coachNickname is! String ||
        athleteNickname is! String ||
        invitedBy is! String ||
        parsedStatus == null) {
      return null;
    }
    return CoachLink(
      id: id,
      coachId: coachId,
      athleteId: athleteId,
      coachNickname: coachNickname,
      athleteNickname: athleteNickname,
      status: parsedStatus,
      invitedBy: invitedBy,
      updatedAt: readFirestoreDate(data[WorkoutFields.updatedAt]),
    );
  }
}
