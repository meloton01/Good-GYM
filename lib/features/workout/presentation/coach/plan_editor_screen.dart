import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/theme_context.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/ids/random_id.dart';
import '../../../../core/widgets/failure_snack_bar.dart';
import '../../../../core/widgets/info_snack_bar.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../auth/data/auth_repository_provider.dart';
import '../../../profile/data/user_profile_repository_provider.dart';
import '../../data/coach_repository_providers.dart';
import '../../domain/coach_limits.dart';
import '../../domain/coach_plan.dart';
import '../../domain/exercise.dart';
import '../../domain/workout_exercise.dart';
import '../../domain/workout_limits.dart';
import '../../domain/workout_set.dart';
import '../plan_exercise_section.dart';

/// Тренер составляет новый план для ученика или правит назначенный.
class PlanEditorScreen extends ConsumerStatefulWidget {
  /// Создаёт редактор плана ученика [athleteId]; [initial] задан при правке.
  const PlanEditorScreen({super.key, required this.athleteId, this.initial});

  final String athleteId;
  final CoachPlan? initial;

  /// Создаёт состояние редактора.
  @override
  ConsumerState<PlanEditorScreen> createState() => _PlanEditorScreenState();
}

/// Хранит название, заметку и упражнения плана.
class _PlanEditorScreenState extends ConsumerState<PlanEditorScreen> {
  late final _title = TextEditingController(text: widget.initial?.title);
  late final _note = TextEditingController(text: widget.initial?.note);
  late final List<WorkoutExercise> _items = [...?widget.initial?.exercises];
  bool _saving = false;

  /// Освобождает контроллеры полей.
  @override
  void dispose() {
    _title.dispose();
    _note.dispose();
    super.dispose();
  }

  /// Строит поля плана, упражнения и кнопку сохранения.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final spacing = context.spacing;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.initial == null ? l10n.coachNewPlan : l10n.coachEditPlan,
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsetsDirectional.all(spacing.md),
          children: [
            TextField(
              controller: _title,
              maxLength: WorkoutLimits.titleMaxLength,
              decoration: InputDecoration(labelText: l10n.workoutTitleLabel),
            ),
            TextField(
              controller: _note,
              minLines: 1,
              maxLines: 4,
              maxLength: CoachLimits.planNoteMaxLength,
              decoration: InputDecoration(labelText: l10n.coachPlanNoteLabel),
            ),
            for (var index = 0; index < _items.length; index++)
              PlanExerciseSection(
                key: ObjectKey(_items[index]),
                item: _items[index],
                onChanged: (item) => setState(() => _items[index] = item),
                onRemove: () => setState(() => _items.removeAt(index)),
              ),
            if (_items.length < WorkoutLimits.maxExercises)
              OutlinedButton.icon(
                icon: const Icon(Icons.add_rounded),
                label: Text(l10n.exerciseAdd),
                onPressed: _addExercise,
              ),
            SizedBox(height: spacing.lg),
            PrimaryButton(
              label: l10n.actionSave,
              loading: _saving,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }

  /// Открывает библиотеку и добавляет упражнение с одним подходом.
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

  /// Создаёт или обновляет план и закрывает редактор.
  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final uid = ref.read(authUserProvider).value?.uid;
    final me = uid == null ? null : ref.read(userProfileProvider(uid)).value;
    if (me == null) {
      return;
    }
    if (_items.isEmpty) {
      showInfoSnackBar(context, l10n.workoutPlanEmpty);
      return;
    }
    final title = _title.text.trim();
    final plan =
        (widget.initial ??
                CoachPlan(
                  id: randomId(),
                  coachId: me.uid,
                  athleteId: widget.athleteId,
                  coachNickname: me.nickname,
                  title: '',
                  exercises: const [],
                ))
            .copyWith(
              title: title.isEmpty ? l10n.workoutDefaultTitle : title,
              note: _note.text.trim(),
              exercises: _items,
            );
    setState(() => _saving = true);
    final repository = ref.read(coachPlanRepositoryProvider);
    final result = widget.initial == null
        ? await repository.createPlan(plan)
        : await repository.updatePlan(plan);
    if (!mounted) {
      return;
    }
    setState(() => _saving = false);
    switch (result) {
      case Success():
        showInfoSnackBar(context, l10n.coachPlanSaved);
        context.pop();
      case Failure(:final failure):
        showFailureSnackBar(context, failure, onRetry: _save);
    }
  }
}
