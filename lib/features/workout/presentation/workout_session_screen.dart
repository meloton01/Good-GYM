import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/theme/theme_context.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/errors/result.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/failure_snack_bar.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../settings/presentation/app_settings_controller.dart';
import '../domain/workout.dart';
import '../domain/workout_limits.dart';
import 'active_workout_controller.dart';
import 'rest_timer_controller.dart';
import 'rest_timer_panel.dart';
import 'session_actions.dart';
import 'session_exercise_view.dart';
import 'set_editor_dialog.dart';
import 'workout_format.dart';

/// Режим тренировки: текущее упражнение, отметка подходов, отдых и заметка.
class WorkoutSessionScreen extends ConsumerStatefulWidget {
  /// Создаёт экран идущей тренировки.
  const WorkoutSessionScreen({super.key});

  /// Создаёт состояние экрана.
  @override
  ConsumerState<WorkoutSessionScreen> createState() =>
      _WorkoutSessionScreenState();
}

/// Хранит номер текущего упражнения, заметку и флаг сохранения.
class _WorkoutSessionScreenState extends ConsumerState<WorkoutSessionScreen> {
  late final TextEditingController _note;
  late int _index;
  bool _finishing = false;
  bool _warnedAboutAlarm = false;

  /// Открывает первое упражнение с невыполненными подходами.
  @override
  void initState() {
    super.initState();
    final workout = ref.read(activeWorkoutProvider);
    _note = TextEditingController(text: workout?.note);
    final firstOpen = workout?.exercises.indexWhere(
      (item) => item.sets.any((set) => !set.completed),
    );
    _index = firstOpen == null || firstOpen < 0 ? 0 : firstOpen;
  }

  /// Освобождает контроллер заметки.
  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  /// Строит пустое состояние или тренировку.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final workout = ref.watch(activeWorkoutProvider);
    if (workout == null || workout.exercises.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.tabWorkout)),
        body: EmptyStateView(
          icon: Icons.fitness_center_outlined,
          title: l10n.sessionEmptyTitle,
          message: l10n.sessionEmptyMessage,
        ),
      );
    }
    final format = WorkoutFormat.of(
      context,
      ref.watch(appSettingsProvider.select((s) => s.weightUnit)),
    );
    final index = _index.clamp(0, workout.exercises.length - 1);
    final controller = ref.read(activeWorkoutProvider.notifier);
    final spacing = context.spacing;
    return Scaffold(
      appBar: AppBar(
        title: Text(workout.title),
        actions: [
          IconButton(
            tooltip: l10n.workoutDiscard,
            icon: const Icon(Icons.close_rounded),
            onPressed: () => discardWorkout(context, ref),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsetsDirectional.all(spacing.md),
          children: [
            Text(
              l10n.workoutStartedAt(format.dateTime(workout.startedAt)),
              style: TextStyle(color: context.colors.textSecondary),
            ),
            SizedBox(height: spacing.md),
            RestTimerPanel(
              format: format,
              onExtend: () =>
                  _rest(WorkoutLimits.restStepSeconds, extend: true),
              onSkip: ref.read(restTimerProvider.notifier).stop,
            ),
            SessionExerciseView(
              item: workout.exercises[index],
              index: index,
              count: workout.exercises.length,
              format: format,
              onSelect: (value) => setState(() => _index = value),
              onToggle: (setIndex) => _toggle(workout, index, setIndex),
              onEdit: (setIndex) => _edit(workout, index, setIndex),
              onAddSet: () => controller.addSet(index),
            ),
            SizedBox(height: spacing.md),
            TextField(
              controller: _note,
              minLines: 1,
              maxLines: 4,
              maxLength: WorkoutLimits.noteMaxLength,
              decoration: InputDecoration(labelText: l10n.workoutNoteLabel),
              onChanged: controller.setNote,
            ),
            SizedBox(height: spacing.md),
            PrimaryButton(
              label: l10n.workoutFinish,
              loading: _finishing,
              onPressed: () => _finish(workout),
            ),
          ],
        ),
      ),
    );
  }

  /// Переключает подход; выполненный подход запускает отдых.
  Future<void> _toggle(Workout workout, int index, int setIndex) async {
    final set = workout.exercises[index].sets[setIndex];
    await ref.read(activeWorkoutProvider.notifier).toggleSet(index, setIndex);
    if (!set.completed && set.restSeconds > 0) {
      await _rest(set.restSeconds);
    }
  }

  /// Открывает правку подхода и сохраняет результат.
  Future<void> _edit(Workout workout, int index, int setIndex) async {
    final edited = await showSetEditor(
      context,
      initial: workout.exercises[index].sets[setIndex],
      unit: ref.read(appSettingsProvider).weightUnit,
    );
    if (edited != null) {
      await ref
          .read(activeWorkoutProvider.notifier)
          .updateSet(index, setIndex, edited);
    }
  }

  /// Запускает или продлевает отдых; об отключённых уведомлениях сообщает один раз.
  Future<void> _rest(int seconds, {bool extend = false}) async {
    final result = await requestRest(context, ref, seconds, extend: extend);
    if (result case Failure(:final failure) when mounted) {
      if (failure != AppFailure.notificationsDenied || !_warnedAboutAlarm) {
        _warnedAboutAlarm = true;
        showFailureSnackBar(context, failure);
      }
    }
  }

  /// Сохраняет тренировку; о невыполненных подходах предупреждает заранее.
  Future<void> _finish(Workout workout) async {
    final l10n = AppLocalizations.of(context);
    final hasOpen = workout.exercises.any(
      (item) => item.sets.any((set) => !set.completed),
    );
    if (hasOpen &&
        !await showConfirmDialog(
          context,
          title: l10n.workoutFinish,
          message: l10n.workoutFinishOpenSets,
          confirmLabel: l10n.workoutFinish,
        )) {
      return;
    }
    setState(() => _finishing = true);
    final result = await ref.read(activeWorkoutProvider.notifier).finish();
    if (!mounted) {
      return;
    }
    setState(() => _finishing = false);
    switch (result) {
      case Success(:final value):
        await completePlan(context, ref, workout, value);
        if (mounted) {
          context.pushReplacement(AppRoutes.workoutDetail(value));
        }
      case Failure(:final failure):
        showFailureSnackBar(context, failure);
    }
  }
}
