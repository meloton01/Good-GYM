import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/theme_context.dart';
import '../../../core/errors/app_failure_message.dart';
import '../../../core/errors/result.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../auth/data/auth_repository_provider.dart';
import '../data/exercise_repository_provider.dart';
import '../domain/exercise.dart';
import '../domain/muscle_group.dart';
import '../domain/workout_limits.dart';
import 'exercise_labels.dart';
import 'workout_validators.dart';

/// Показывает диалог создания своего упражнения; возвращает созданное или null.
Future<Exercise?> showCreateExerciseDialog(BuildContext context) {
  return showDialog<Exercise>(
    context: context,
    builder: (context) => const _CreateExerciseDialog(),
  );
}

/// Диалог с названием и группой мышц.
class _CreateExerciseDialog extends ConsumerStatefulWidget {
  /// Создаёт диалог.
  const _CreateExerciseDialog();

  /// Создаёт состояние диалога.
  @override
  ConsumerState<_CreateExerciseDialog> createState() =>
      _CreateExerciseDialogState();
}

/// Хранит поля, флаг отправки и текст ошибки.
class _CreateExerciseDialogState extends ConsumerState<_CreateExerciseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  MuscleGroup _group = MuscleGroup.chest;
  bool _submitting = false;
  String? _error;

  /// Освобождает контроллер названия.
  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  /// Строит поле названия, выбор группы и кнопки.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final error = _error;
    return AlertDialog(
      title: Text(l10n.exerciseCreate),
      scrollable: true,
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _name,
              maxLength: WorkoutLimits.exerciseNameMaxLength,
              decoration: InputDecoration(labelText: l10n.exerciseNameLabel),
              validator: (value) => WorkoutValidators.exerciseName(l10n, value),
            ),
            SizedBox(height: context.spacing.md),
            DropdownButtonFormField<MuscleGroup>(
              initialValue: _group,
              isExpanded: true,
              decoration: InputDecoration(labelText: l10n.exerciseGroupLabel),
              items: [
                for (final group in MuscleGroup.values)
                  DropdownMenuItem(
                    value: group,
                    child: Text(group.label(l10n)),
                  ),
              ],
              onChanged: (group) => setState(() => _group = group ?? _group),
            ),
            if (error != null) ...[
              SizedBox(height: context.spacing.md),
              Text(error, style: TextStyle(color: context.colors.error)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.actionCancel),
        ),
        TextButton(
          onPressed: _submitting ? null : _submit,
          child: Text(l10n.actionSave),
        ),
      ],
    );
  }

  /// Создаёт упражнение и закрывает диалог с ним; ошибку показывает в диалоге.
  Future<void> _submit() async {
    final uid = ref.read(authUserProvider).value?.uid;
    if (uid == null || _submitting || !_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    final result = await ref
        .read(exerciseRepositoryProvider)
        .createExercise(uid, name: _name.text, muscleGroup: _group);
    if (!mounted) {
      return;
    }
    switch (result) {
      case Success(:final value):
        Navigator.of(context).pop(value);
      case Failure(:final failure):
        setState(() {
          _submitting = false;
          _error = failure.message(AppLocalizations.of(context));
        });
    }
  }
}
