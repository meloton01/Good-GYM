import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../core/navigation/tab_definition.dart';
import '../domain/workout_template.dart';
import 'exercise_picker_screen.dart';
import 'exercise_progress_screen.dart';
import 'template_editor_screen.dart';
import 'workout_detail_screen.dart';
import 'workout_editor_screen.dart';
import 'workout_screen.dart';
import 'workout_session_screen.dart';

/// Вкладка «Тренировки» для реестра вкладок.
final workoutTab = TabDefinition(
  path: '/workout',
  icon: Icons.fitness_center_outlined,
  selectedIcon: Icons.fitness_center_rounded,
  label: (l10n) => l10n.tabWorkout,
  builder: (context) => const WorkoutScreen(),
  routes: [
    GoRoute(
      path: AppRoutes.workoutPlanSegment,
      builder: (context, state) =>
          WorkoutEditorScreen(initial: state.extra as WorkoutTemplate?),
    ),
    GoRoute(
      path: AppRoutes.workoutSessionSegment,
      builder: (context, state) => const WorkoutSessionScreen(),
    ),
    GoRoute(
      path: AppRoutes.exercisePickerSegment,
      builder: (context, state) => const ExercisePickerScreen(),
    ),
    GoRoute(
      path: AppRoutes.workoutTemplateSegment,
      builder: (context, state) =>
          TemplateEditorScreen(templateId: state.pathParameters['templateId']!),
    ),
    GoRoute(
      path: AppRoutes.workoutDetailSegment,
      builder: (context, state) =>
          WorkoutDetailScreen(workoutId: state.pathParameters['workoutId']!),
    ),
    GoRoute(
      path: AppRoutes.exerciseProgressSegment,
      builder: (context, state) => ExerciseProgressScreen(
        exerciseId: state.pathParameters['exerciseId']!,
      ),
    ),
  ],
);
