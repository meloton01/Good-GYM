import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../core/errors/result.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/failure_snack_bar.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/workout_exercise.dart';
import 'active_workout_controller.dart';

/// Начинает тренировку по плану и открывает её; идущую тренировку заменяет только после подтверждения.
Future<void> startWorkout(
  BuildContext context,
  WidgetRef ref, {
  required String ownerId,
  required String title,
  required List<WorkoutExercise> exercises,
  bool replaceRoute = false,
}) async {
  final l10n = AppLocalizations.of(context);
  if (ref.read(activeWorkoutProvider) != null) {
    final replace = await showConfirmDialog(
      context,
      title: l10n.workoutReplaceTitle,
      message: l10n.workoutReplaceMessage,
      confirmLabel: l10n.workoutStart,
      destructive: true,
    );
    if (!replace || !context.mounted) {
      return;
    }
  }
  final result = await ref
      .read(activeWorkoutProvider.notifier)
      .start(ownerId: ownerId, title: title, exercises: exercises);
  if (!context.mounted) {
    return;
  }
  if (result is Failure<void>) {
    showFailureSnackBar(context, result.failure);
  }
  if (replaceRoute) {
    context.pushReplacement(AppRoutes.workoutSession);
  } else {
    await context.push(AppRoutes.workoutSession);
  }
}
