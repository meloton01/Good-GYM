import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/theme/theme_context.dart';
import '../../../core/errors/result.dart';
import '../../../core/firebase/firestore_failure_mapper.dart';
import '../../../core/ids/random_id.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/failure_snack_bar.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/section_header.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../auth/data/auth_repository_provider.dart';
import '../../settings/presentation/app_settings_controller.dart';
import '../data/workout_repository_provider.dart';
import '../domain/workout.dart';
import '../domain/workout_template.dart';
import 'exercise_labels.dart';
import 'workout_detail_providers.dart';
import 'workout_format.dart';
import 'workout_history_controller.dart';

/// Завершённая тренировка: подходы, заметка, повтор и удаление.
class WorkoutDetailScreen extends ConsumerWidget {
  /// Создаёт экран тренировки [workoutId].
  const WorkoutDetailScreen({super.key, required this.workoutId, this.ownerId});

  final String workoutId;

  /// uid ученика, если тренер смотрит его тренировку; null — своя тренировка.
  final String? ownerId;

  /// Строит загрузку, ошибку или данные тренировки.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final me = ref.watch(authUserProvider).value?.uid ?? '';
    final readOnly = ownerId != null && ownerId != me;
    final key = (ownerId ?? me, workoutId);
    final loaded = ref.watch(workoutDetailProvider(key));
    final workout = switch (loaded) {
      AsyncData(value: Success(:final value)) => value,
      _ => null,
    };
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.workoutDetailTitle),
        actions: [
          if (workout != null && !readOnly)
            IconButton(
              tooltip: l10n.workoutDelete,
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: () => _delete(context, ref, workout),
            ),
        ],
      ),
      body: switch (loaded) {
        AsyncData(value: Success(:final value)) => _Details(
          workout: value,
          readOnly: readOnly,
        ),
        AsyncData(value: Failure(:final failure)) => ErrorView(
          title: l10n.workoutDetailTitle,
          failure: failure,
          onRetry: () => ref.invalidate(workoutDetailProvider(key)),
        ),
        AsyncError(:final error) => ErrorView(
          title: l10n.workoutDetailTitle,
          failure: failureFromError(error),
          onRetry: () => ref.invalidate(workoutDetailProvider(key)),
        ),
        _ => const LoadingView(),
      },
    );
  }

  /// Удаляет тренировку после подтверждения и возвращает к истории.
  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    Workout workout,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showConfirmDialog(
      context,
      title: l10n.workoutDelete,
      message: l10n.workoutDeleteMessage,
      confirmLabel: l10n.actionDelete,
      destructive: true,
    );
    if (!confirmed || !context.mounted) {
      return;
    }
    final result = await ref
        .read(workoutRepositoryProvider)
        .deleteWorkout(workout);
    if (!context.mounted) {
      return;
    }
    switch (result) {
      case Success():
        ref.invalidate(workoutHistoryProvider(workout.ownerId));
        context.pop();
      case Failure(:final failure):
        showFailureSnackBar(context, failure);
    }
  }
}

/// Список упражнений и подходов тренировки.
class _Details extends ConsumerWidget {
  /// Создаёт блок данных тренировки.
  const _Details({required this.workout, required this.readOnly});

  final Workout workout;

  /// Тренировка ученика: без повтора.
  final bool readOnly;

  /// Строит заголовок, заметку, упражнения и кнопку повтора.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final format = WorkoutFormat.of(
      context,
      ref.watch(appSettingsProvider.select((s) => s.weightUnit)),
    );
    final spacing = context.spacing;
    return ListView(
      padding: EdgeInsetsDirectional.only(bottom: spacing.lg),
      children: [
        ListTile(
          title: Text(
            workout.title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          subtitle: Text(
            '${format.dateTime(workout.startedAt)}\n${format.summary(workout)}',
          ),
          isThreeLine: true,
        ),
        if (workout.note.isNotEmpty)
          ListTile(
            leading: const Icon(Icons.notes_rounded),
            title: Text(workout.note),
          ),
        for (final item in workout.exercises) ...[
          SectionHeader(title: item.exercise.name(l10n)),
          for (var index = 0; index < item.sets.length; index++)
            ListTile(
              title: Text(l10n.setNumber(index + 1)),
              subtitle: Text(format.set(item.sets[index])),
            ),
        ],
        if (!readOnly)
          Padding(
            padding: EdgeInsetsDirectional.all(spacing.md),
            child: PrimaryButton(
              label: l10n.workoutRepeat,
              onPressed: () => context.push(
                AppRoutes.workoutPlan,
                extra: WorkoutTemplate(
                  id: randomId(),
                  title: workout.title,
                  exercises: workout.exercises,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
