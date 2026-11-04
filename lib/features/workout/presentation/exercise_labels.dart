import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../domain/exercise.dart';
import '../domain/muscle_group.dart';

/// Локализованное название упражнения.
extension ExerciseLabels on Exercise {
  /// Название своего упражнения как есть, встроенного — из ARB.
  String name(AppLocalizations l10n) {
    return customName ??
        switch (id) {
          'squat' => l10n.exerciseSquat,
          'bench_press' => l10n.exerciseBenchPress,
          'deadlift' => l10n.exerciseDeadlift,
          'pull_up' => l10n.exercisePullUp,
          'overhead_press' => l10n.exerciseOverheadPress,
          'barbell_row' => l10n.exerciseBarbellRow,
          'lat_pulldown' => l10n.exerciseLatPulldown,
          'incline_bench_press' => l10n.exerciseInclineBenchPress,
          'push_up' => l10n.exercisePushUp,
          'dip' => l10n.exerciseDip,
          'leg_press' => l10n.exerciseLegPress,
          'lunge' => l10n.exerciseLunge,
          'romanian_deadlift' => l10n.exerciseRomanianDeadlift,
          'lateral_raise' => l10n.exerciseLateralRaise,
          'biceps_curl' => l10n.exerciseBicepsCurl,
          'triceps_extension' => l10n.exerciseTricepsExtension,
          'crunch' => l10n.exerciseCrunch,
          'hanging_leg_raise' => l10n.exerciseHangingLegRaise,
          _ => l10n.exerciseUnknown,
        };
  }
}

/// Локализованное название и иконка группы мышц.
extension MuscleGroupLabels on MuscleGroup {
  /// Название группы на языке интерфейса.
  String label(AppLocalizations l10n) => switch (this) {
    MuscleGroup.chest => l10n.muscleChest,
    MuscleGroup.back => l10n.muscleBack,
    MuscleGroup.legs => l10n.muscleLegs,
    MuscleGroup.shoulders => l10n.muscleShoulders,
    MuscleGroup.arms => l10n.muscleArms,
    MuscleGroup.core => l10n.muscleCore,
  };

  /// Иконка группы из того же набора Material Rounded, что и остальной интерфейс.
  IconData get icon => switch (this) {
    MuscleGroup.chest => Icons.fitness_center_rounded,
    MuscleGroup.back => Icons.rowing_rounded,
    MuscleGroup.legs => Icons.directions_run_rounded,
    MuscleGroup.shoulders => Icons.sports_gymnastics_rounded,
    MuscleGroup.arms => Icons.sports_mma_rounded,
    MuscleGroup.core => Icons.self_improvement_rounded,
  };
}
