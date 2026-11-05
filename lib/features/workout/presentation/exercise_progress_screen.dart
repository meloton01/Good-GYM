import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/theme_context.dart';
import '../../../core/errors/result.dart';
import '../../../core/firebase/firestore_failure_mapper.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../auth/data/auth_repository_provider.dart';
import '../../settings/presentation/app_settings_controller.dart';
import '../domain/exercise_progress.dart';
import '../domain/workout.dart';
import 'exercise_labels.dart';
import 'progress_chart.dart';
import 'progress_metric.dart';
import 'record_summary.dart';
import 'workout_detail_providers.dart';
import 'workout_format.dart';

/// Прогресс по упражнению: график показателя и личные рекорды.
class ExerciseProgressScreen extends ConsumerStatefulWidget {
  /// Создаёт экран прогресса упражнения [exerciseId].
  const ExerciseProgressScreen({
    super.key,
    required this.exerciseId,
    this.ownerId,
  });

  final String exerciseId;

  /// uid ученика, если тренер смотрит его прогресс; null — свой прогресс.
  final String? ownerId;

  /// Создаёт состояние экрана.
  @override
  ConsumerState<ExerciseProgressScreen> createState() =>
      _ExerciseProgressScreenState();
}

/// Хранит выбранный показатель графика.
class _ExerciseProgressScreenState
    extends ConsumerState<ExerciseProgressScreen> {
  ProgressMetric? _metric;

  /// Строит загрузку, ошибку, пустое состояние или график.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final uid = widget.ownerId ?? ref.watch(authUserProvider).value?.uid ?? '';
    final key = (uid, widget.exerciseId);
    final loaded = ref.watch(exerciseHistoryProvider(key));
    final workouts = switch (loaded) {
      AsyncData(value: Success(:final value)) => value,
      _ => null,
    };
    final exercise = workouts
        ?.expand((workout) => workout.exercises)
        .where((item) => item.exercise.id == widget.exerciseId)
        .firstOrNull
        ?.exercise;
    return Scaffold(
      appBar: AppBar(title: Text(exercise?.name(l10n) ?? l10n.progressTitle)),
      body: switch (loaded) {
        AsyncData(value: Success(:final value)) => _buildProgress(uid, value),
        AsyncData(value: Failure(:final failure)) => ErrorView(
          title: l10n.progressTitle,
          failure: failure,
          onRetry: () => ref.invalidate(exerciseHistoryProvider(key)),
        ),
        AsyncError(:final error) => ErrorView(
          title: l10n.progressTitle,
          failure: failureFromError(error),
          onRetry: () => ref.invalidate(exerciseHistoryProvider(key)),
        ),
        _ => const LoadingView(),
      },
    );
  }

  /// Строит переключатель показателя, график и рекорды.
  Widget _buildProgress(String uid, List<Workout> workouts) {
    final l10n = AppLocalizations.of(context);
    final points = exerciseProgress(widget.exerciseId, workouts);
    final available = [
      for (final metric in ProgressMetric.values)
        if (points.any((point) => metric.valueOf(point.best) != null)) metric,
    ];
    if (points.isEmpty || available.isEmpty) {
      return EmptyStateView(
        icon: Icons.show_chart_rounded,
        title: l10n.progressTitle,
        message: l10n.progressEmpty,
      );
    }
    final metric = available.contains(_metric) ? _metric! : available.first;
    final format = WorkoutFormat.of(
      context,
      ref.watch(appSettingsProvider.select((s) => s.weightUnit)),
    );
    final spacing = context.spacing;
    return ListView(
      padding: EdgeInsetsDirectional.all(spacing.md),
      children: [
        if (available.length > 1)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SegmentedButton<ProgressMetric>(
              showSelectedIcon: false,
              segments: [
                for (final item in available)
                  ButtonSegment(value: item, label: Text(item.label(l10n))),
              ],
              selected: {metric},
              onSelectionChanged: (selection) =>
                  setState(() => _metric = selection.first),
            ),
          ),
        SizedBox(height: spacing.md),
        ProgressChart(points: points, metric: metric, format: format),
        SizedBox(height: spacing.sm),
        Text(
          l10n.progressPointsHint(points.length),
          style: TextStyle(color: context.colors.textSecondary),
        ),
        RecordSummary(uid: uid, exerciseId: widget.exerciseId, format: format),
      ],
    );
  }
}
