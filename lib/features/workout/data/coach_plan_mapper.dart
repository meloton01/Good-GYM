import '../../../core/firebase/firestore_date.dart';
import '../domain/coach_plan.dart';
import '../domain/plan_comment.dart';
import '../domain/plan_status.dart';
import 'exercise_mapper.dart';
import 'workout_fields.dart';

/// Перевод планов тренера и комментариев между моделями и документами.
abstract final class CoachPlanMapper {
  /// Поля плана, которые тренер задаёт и меняет.
  static Map<String, Object?> contentToMap(CoachPlan plan) {
    return {
      WorkoutFields.title: plan.title,
      WorkoutFields.note: plan.note,
      WorkoutFields.exercises: ExerciseMapper.itemsToList(plan.exercises),
    };
  }

  /// Собирает план ученика [athleteId]; null, если документ повреждён.
  static CoachPlan? planFromMap(
    String id,
    String athleteId,
    Map<String, dynamic> data,
  ) {
    final coachId = data[WorkoutFields.coachId];
    final coachNickname = data[WorkoutFields.coachNickname];
    final title = data[WorkoutFields.title];
    final note = data[WorkoutFields.note];
    final status = data[WorkoutFields.status];
    final workoutId = data[WorkoutFields.workoutId];
    final exercises = ExerciseMapper.itemsFromList(
      data[WorkoutFields.exercises],
    );
    if (coachId is! String ||
        coachNickname is! String ||
        title is! String ||
        exercises == null) {
      return null;
    }
    return CoachPlan(
      id: id,
      coachId: coachId,
      athleteId: athleteId,
      coachNickname: coachNickname,
      title: title,
      exercises: exercises,
      note: note is String ? note : '',
      status: status == PlanStatus.completed.name
          ? PlanStatus.completed
          : PlanStatus.assigned,
      workoutId: workoutId is String ? workoutId : null,
      createdAt: readFirestoreDate(data[WorkoutFields.createdAt]),
      completedAt: readFirestoreDate(data[WorkoutFields.completedAt]),
    );
  }

  /// Собирает комментарий; null, если документ повреждён.
  static PlanComment? commentFromMap(String id, Map<String, dynamic> data) {
    final authorId = data[WorkoutFields.authorId];
    final authorNickname = data[WorkoutFields.authorNickname];
    final text = data[WorkoutFields.text];
    if (authorId is! String || authorNickname is! String || text is! String) {
      return null;
    }
    return PlanComment(
      id: id,
      authorId: authorId,
      authorNickname: authorNickname,
      text: text,
      createdAt: readFirestoreDate(data[WorkoutFields.createdAt]),
    );
  }
}
