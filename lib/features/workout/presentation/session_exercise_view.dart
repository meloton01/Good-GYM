import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../domain/workout_exercise.dart';
import '../domain/workout_limits.dart';
import 'exercise_labels.dart';
import 'workout_format.dart';

/// Текущее упражнение тренировки: переход между упражнениями и отметка подходов.
class SessionExerciseView extends StatelessWidget {
  /// Создаёт блок упражнения [index] из [count].
  const SessionExerciseView({
    super.key,
    required this.item,
    required this.index,
    required this.count,
    required this.format,
    required this.onSelect,
    required this.onToggle,
    required this.onEdit,
    required this.onAddSet,
  });

  final WorkoutExercise item;
  final int index;
  final int count;
  final WorkoutFormat format;

  /// Переход к упражнению с указанным номером.
  final ValueChanged<int> onSelect;

  /// Отметка подхода с указанным номером.
  final ValueChanged<int> onToggle;

  /// Правка подхода с указанным номером.
  final ValueChanged<int> onEdit;
  final VoidCallback onAddSet;

  /// Строит навигацию, название и подходы.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sets = item.sets;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton(
              tooltip: l10n.exercisePrevious,
              icon: const Icon(Icons.chevron_left_rounded),
              onPressed: index > 0 ? () => onSelect(index - 1) : null,
            ),
            Expanded(
              child: Text(
                l10n.exercisePosition(index + 1, count),
                textAlign: TextAlign.center,
              ),
            ),
            IconButton(
              tooltip: l10n.exerciseNext,
              icon: const Icon(Icons.chevron_right_rounded),
              onPressed: index < count - 1 ? () => onSelect(index + 1) : null,
            ),
          ],
        ),
        ListTile(
          contentPadding: EdgeInsetsDirectional.zero,
          leading: Icon(item.exercise.muscleGroup.icon),
          title: Text(
            item.exercise.name(l10n),
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        for (var setIndex = 0; setIndex < sets.length; setIndex++)
          CheckboxListTile(
            contentPadding: EdgeInsetsDirectional.zero,
            controlAffinity: ListTileControlAffinity.leading,
            value: sets[setIndex].completed,
            onChanged: (_) => onToggle(setIndex),
            title: Text(l10n.setNumber(setIndex + 1)),
            subtitle: Text(
              l10n.setWithRest(
                format.set(sets[setIndex]),
                format.rest(sets[setIndex].restSeconds),
              ),
            ),
            secondary: IconButton(
              tooltip: l10n.setEditTitle,
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => onEdit(setIndex),
            ),
          ),
        if (sets.length < WorkoutLimits.maxSets)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              icon: const Icon(Icons.add_rounded),
              label: Text(l10n.setAdd),
              onPressed: onAddSet,
            ),
          ),
      ],
    );
  }
}
