import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/section_header.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../data/workout_repository_provider.dart';
import '../domain/record_value.dart';
import 'workout_format.dart';

/// Личные рекорды упражнения за всё время с датами.
class RecordSummary extends ConsumerWidget {
  /// Создаёт блок рекордов упражнения [exerciseId].
  const RecordSummary({
    super.key,
    required this.uid,
    required this.exerciseId,
    required this.format,
  });

  /// Владелец рекордов.
  final String uid;
  final String exerciseId;
  final WorkoutFormat format;

  /// Строит пункты рекордов; пока рекорды не загружены или их нет, ничего не показывает.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final record = ref
        .watch(personalRecordsProvider(uid))
        .value
        ?.where((item) => item.exercise.id == exerciseId)
        .firstOrNull;
    if (record == null) {
      return const SizedBox.shrink();
    }
    final rows = <(String, RecordValue, String)>[
      if (record.bestE1rmKg case final value?)
        (l10n.metricE1rm, value, format.weight(value.value)),
      if (record.maxWeightKg case final value?)
        (l10n.metricMaxWeight, value, format.weight(value.value)),
      if (record.maxReps case final value?)
        (l10n.metricReps, value, l10n.setRepsOnly(value.value.round())),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title: l10n.recordsTitle),
        for (final (label, value, text) in rows)
          ListTile(
            title: Text(text, style: Theme.of(context).textTheme.titleMedium),
            subtitle: Text('$label\n${format.dateTime(value.achievedAt)}'),
            isThreeLine: true,
          ),
      ],
    );
  }
}
