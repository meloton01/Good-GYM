import 'exercise.dart';
import 'muscle_group.dart';

/// Встроенная библиотека упражнений; id совпадают с упражнениями рейтинга.
abstract final class BuiltInExercises {
  static const Exercise squat = Exercise(
    id: 'squat',
    muscleGroup: MuscleGroup.legs,
  );
  static const Exercise benchPress = Exercise(
    id: 'bench_press',
    muscleGroup: MuscleGroup.chest,
  );
  static const Exercise deadlift = Exercise(
    id: 'deadlift',
    muscleGroup: MuscleGroup.back,
  );
  static const Exercise pullUp = Exercise(
    id: 'pull_up',
    muscleGroup: MuscleGroup.back,
  );
  static const Exercise overheadPress = Exercise(
    id: 'overhead_press',
    muscleGroup: MuscleGroup.shoulders,
  );
  static const Exercise barbellRow = Exercise(
    id: 'barbell_row',
    muscleGroup: MuscleGroup.back,
  );
  static const Exercise latPulldown = Exercise(
    id: 'lat_pulldown',
    muscleGroup: MuscleGroup.back,
  );
  static const Exercise inclineBenchPress = Exercise(
    id: 'incline_bench_press',
    muscleGroup: MuscleGroup.chest,
  );
  static const Exercise pushUp = Exercise(
    id: 'push_up',
    muscleGroup: MuscleGroup.chest,
  );
  static const Exercise dip = Exercise(
    id: 'dip',
    muscleGroup: MuscleGroup.arms,
  );
  static const Exercise legPress = Exercise(
    id: 'leg_press',
    muscleGroup: MuscleGroup.legs,
  );
  static const Exercise lunge = Exercise(
    id: 'lunge',
    muscleGroup: MuscleGroup.legs,
  );
  static const Exercise romanianDeadlift = Exercise(
    id: 'romanian_deadlift',
    muscleGroup: MuscleGroup.legs,
  );
  static const Exercise lateralRaise = Exercise(
    id: 'lateral_raise',
    muscleGroup: MuscleGroup.shoulders,
  );
  static const Exercise bicepsCurl = Exercise(
    id: 'biceps_curl',
    muscleGroup: MuscleGroup.arms,
  );
  static const Exercise tricepsExtension = Exercise(
    id: 'triceps_extension',
    muscleGroup: MuscleGroup.arms,
  );
  static const Exercise crunch = Exercise(
    id: 'crunch',
    muscleGroup: MuscleGroup.core,
  );
  static const Exercise hangingLegRaise = Exercise(
    id: 'hanging_leg_raise',
    muscleGroup: MuscleGroup.core,
  );

  /// Все встроенные упражнения в порядке показа.
  static const List<Exercise> all = [
    squat,
    benchPress,
    deadlift,
    pullUp,
    overheadPress,
    barbellRow,
    latPulldown,
    inclineBenchPress,
    pushUp,
    dip,
    legPress,
    lunge,
    romanianDeadlift,
    lateralRaise,
    bicepsCurl,
    tricepsExtension,
    crunch,
    hangingLegRaise,
  ];
}
