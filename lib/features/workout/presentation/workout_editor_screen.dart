import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/theme/theme_context.dart';
import '../../../core/errors/result.dart';
import '../../../core/ids/random_id.dart';
import '../../../core/widgets/failure_snack_bar.dart';
import '../../../core/widgets/info_snack_bar.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../auth/data/auth_repository_provider.dart';
import '../data/workout_template_repository_provider.dart';
import '../domain/exercise.dart';
import '../domain/workout_exercise.dart';
import '../domain/workout_limits.dart';
import '../domain/workout_set.dart';
import '../domain/workout_template.dart';
import 'delete_template.dart';
import 'plan_exercise_section.dart';
import 'start_workout.dart';

/// План тренировки: упражнения и подходы; запуск, сохранение шаблоном или правка шаблона.
class WorkoutEditorScreen extends ConsumerStatefulWidget {
  /// Создаёт редактор; [savedTemplate] true, если [initial] уже сохранён как шаблон.
  const WorkoutEditorScreen({
    super.key,
    this.initial,
    this.savedTemplate = false,
  });

  final WorkoutTemplate? initial;
  final bool savedTemplate;

  /// Создаёт состояние редактора.
  @override
  ConsumerState<WorkoutEditorScreen> createState() =>
      _WorkoutEditorScreenState();
}

/// Хранит название и список упражнений плана.
class _WorkoutEditorScreenState extends ConsumerState<WorkoutEditorScreen> {
  late final _title = TextEditingController(text: widget.initial?.title);
  late final List<WorkoutExercise> _items = [...?widget.initial?.exercises];
  bool _saving = false;

  /// Освобождает контроллер названия.
  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  /// Строит поле названия, упражнения и кнопки действий.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final spacing = context.spacing;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.savedTemplate ? l10n.templateEditTitle : l10n.workoutPlanTitle,
        ),
        actions: [
          if (widget.savedTemplate)
            IconButton(
              tooltip: l10n.templateDelete,
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: () => deleteTemplate(context, ref, widget.initial!.id),
            ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsetsDirectional.all(spacing.md),
          children: [
            TextField(
              controller: _title,
              maxLength: WorkoutLimits.titleMaxLength,
              decoration: InputDecoration(
                labelText: l10n.workoutTitleLabel,
                hintText: l10n.workoutDefaultTitle,
              ),
            ),
            for (var index = 0; index < _items.length; index++)
              PlanExerciseSection(
                key: ObjectKey(_items[index]),
                item: _items[index],
                onChanged: (item) => setState(() => _items[index] = item),
                onRemove: () => setState(() => _items.removeAt(index)),
              ),
            if (_items.isEmpty)
              Padding(
                padding: EdgeInsetsDirectional.symmetric(vertical: spacing.md),
                child: Text(
                  l10n.workoutPlanEmpty,
                  style: TextStyle(color: context.colors.textSecondary),
                ),
              ),
            if (_items.length < WorkoutLimits.maxExercises)
              OutlinedButton.icon(
                icon: const Icon(Icons.add_rounded),
                label: Text(l10n.exerciseAdd),
                onPressed: _addExercise,
              ),
            SizedBox(height: spacing.lg),
            PrimaryButton(label: l10n.workoutStart, onPressed: _start),
            SizedBox(height: spacing.sm),
            OutlinedButton(
              onPressed: _saving ? null : _saveTemplate,
              child: Text(
                widget.savedTemplate ? l10n.actionSave : l10n.templateSaveAs,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Название из поля или название по умолчанию.
  String get _resolvedTitle {
    final title = _title.text.trim();
    return title.isEmpty
        ? AppLocalizations.of(context).workoutDefaultTitle
        : title;
  }

  /// Открывает библиотеку и добавляет выбранное упражнение с одним подходом.
  Future<void> _addExercise() async {
    final exercise = await context.push<Exercise>(AppRoutes.exercisePicker);
    if (exercise == null || !mounted) {
      return;
    }
    setState(
      () => _items.add(
        WorkoutExercise(
          exercise: exercise,
          sets: const [
            WorkoutSet(
              reps: WorkoutLimits.defaultReps,
              restSeconds: WorkoutLimits.defaultRestSeconds,
            ),
          ],
        ),
      ),
    );
  }

  /// Проверяет, что в плане есть упражнения, иначе подсказывает добавить.
  bool _ensureNotEmpty() {
    if (_items.isNotEmpty) {
      return true;
    }
    showInfoSnackBar(context, AppLocalizations.of(context).workoutPlanEmpty);
    return false;
  }

  /// Начинает тренировку по плану вместо экрана редактора.
  Future<void> _start() async {
    final uid = ref.read(authUserProvider).value?.uid;
    if (uid == null || !_ensureNotEmpty()) {
      return;
    }
    await startWorkout(
      context,
      ref,
      ownerId: uid,
      title: _resolvedTitle,
      exercises: _items,
      replaceRoute: true,
    );
  }

  /// Сохраняет план шаблоном: новым или поверх открытого.
  Future<void> _saveTemplate() async {
    final uid = ref.read(authUserProvider).value?.uid;
    if (uid == null || !_ensureNotEmpty()) {
      return;
    }
    final l10n = AppLocalizations.of(context);
    final template = WorkoutTemplate(
      id: widget.savedTemplate ? widget.initial!.id : randomId(),
      title: _resolvedTitle,
      exercises: _items,
    );
    setState(() => _saving = true);
    final result = await ref
        .read(workoutTemplateRepositoryProvider)
        .saveTemplate(uid, template);
    if (!mounted) {
      return;
    }
    setState(() => _saving = false);
    switch (result) {
      case Success():
        showInfoSnackBar(context, l10n.templateSaved);
        if (widget.savedTemplate) {
          context.pop();
        }
      case Failure(:final failure):
        showFailureSnackBar(context, failure, onRetry: _saveTemplate);
    }
  }
}
