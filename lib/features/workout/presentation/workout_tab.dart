import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../core/navigation/tab_definition.dart';
import '../domain/coach_plan.dart';
import '../domain/workout_template.dart';
import 'coach/my_plans_screen.dart';
import 'coach/my_qr_screen.dart';
import 'coach/plan_detail_screen.dart';
import 'coach/plan_editor_screen.dart';
import 'coach/qr_scan_screen.dart';
import 'coach/student_screen.dart';
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
      path: AppRoutes.coachQrSegment,
      builder: (context, state) => const MyQrScreen(),
    ),
    GoRoute(
      path: AppRoutes.coachScanSegment,
      builder: (context, state) => const QrScanScreen(),
    ),
    GoRoute(
      path: AppRoutes.myPlansSegment,
      builder: (context, state) => const MyPlansScreen(),
    ),
    GoRoute(
      path: AppRoutes.planDetailSegment,
      builder: (context, state) => PlanDetailScreen(
        athleteId: state.pathParameters['athleteId']!,
        planId: state.pathParameters['planId']!,
      ),
    ),
    GoRoute(
      path: AppRoutes.studentSegment,
      builder: (context, state) =>
          StudentScreen(athleteId: state.pathParameters['athleteId']!),
      routes: [
        GoRoute(
          path: AppRoutes.planEditorSegment,
          builder: (context, state) => PlanEditorScreen(
            athleteId: state.pathParameters['athleteId']!,
            initial: state.extra as CoachPlan?,
          ),
        ),
      ],
    ),
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
      builder: (context, state) => WorkoutDetailScreen(
        workoutId: state.pathParameters['workoutId']!,
        ownerId: state.uri.queryParameters[AppRoutes.ownerParameter],
      ),
    ),
    GoRoute(
      path: AppRoutes.exerciseProgressSegment,
      builder: (context, state) => ExerciseProgressScreen(
        exerciseId: state.pathParameters['exerciseId']!,
        ownerId: state.uri.queryParameters[AppRoutes.ownerParameter],
      ),
    ),
  ],
);
