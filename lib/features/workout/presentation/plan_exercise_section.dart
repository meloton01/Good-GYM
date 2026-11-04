import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../settings/presentation/app_settings_controller.dart';
import '../domain/workout_exercise.dart';
import '../domain/workout_limits.dart';
import 'exercise_labels.dart';
import 'set_editor_dialog.dart';
import 'workout_format.dart';

/// Упражнение в плане: подходы с правкой, добавлением и удалением.
class PlanExerciseSection extends ConsumerWidget {
  /// Создаёт блок упражнения [item].
  const PlanExerciseSection({
    super.key,
    required this.item,
    required this.onChanged,
    required this.onRemove,
  });

  final WorkoutExercise item;
  final ValueChanged<WorkoutExercise> onChanged;
  final VoidCallback onRemove;

  /// Строит заголовок упражнения и список подходов.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final unit = ref.watch(appSettingsProvider.select((s) => s.weightUnit));
    final format = WorkoutFormat.of(context, unit);
    final sets = item.sets;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          contentPadding: EdgeInsetsDirectional.zero,
          leading: Icon(item.exercise.muscleGroup.icon),
          title: Text(
            item.exercise.name(l10n),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          trailing: IconButton(
            tooltip: l10n.exerciseRemove,
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: onRemove,
          ),
        ),
        for (var index = 0; index < sets.length; index++)
          ListTile(
            contentPadding: EdgeInsetsDirectional.zero,
            title: Text(l10n.setNumber(index + 1)),
            subtitle: Text(
              l10n.setWithRest(
                format.set(sets[index]),
                format.rest(sets[index].restSeconds),
              ),
            ),
            onTap: () async {
              final edited = await showSetEditor(
                context,
                initial: sets[index],
                unit: unit,
              );
              if (edited != null) {
                onChanged(item.copyWith(sets: [...sets]..[index] = edited));
              }
            },
            trailing: sets.length > 1
                ? IconButton(
                    tooltip: l10n.setRemove,
                    icon: const Icon(Icons.remove_circle_outline_rounded),
                    onPressed: () => onChanged(
                      item.copyWith(sets: [...sets]..removeAt(index)),
                    ),
                  )
                : null,
          ),
        if (sets.length < WorkoutLimits.maxSets)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              icon: const Icon(Icons.add_rounded),
              label: Text(l10n.setAdd),
              onPressed: () => onChanged(
                item.copyWith(
                  sets: [...sets, sets.last.copyWith(completed: false)],
                ),
              ),
            ),
          ),
        const Divider(),
      ],
    );
  }
}
