import 'package:freezed_annotation/freezed_annotation.dart';

import 'plan_status.dart';
import 'workout_exercise.dart';

part 'coach_plan.freezed.dart';

/// План тренировки, который тренер назначил ученику.
@freezed
abstract class CoachPlan with _$CoachPlan {
  /// Создаёт план; [workoutId] задан, когда ученик выполнил план.
  const factory CoachPlan({
    required String id,
    required String coachId,
    required String athleteId,
    required String coachNickname,
    required String title,
    required List<WorkoutExercise> exercises,
    @Default('') String note,
    @Default(PlanStatus.assigned) PlanStatus status,
    String? workoutId,
    DateTime? createdAt,
    DateTime? completedAt,
  }) = _CoachPlan;
}
