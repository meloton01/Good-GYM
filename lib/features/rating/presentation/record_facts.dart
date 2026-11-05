import 'package:flutter/material.dart';

import '../../../app/theme/theme_context.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/gym_record.dart';
import '../domain/record_status.dart';
import '../domain/weight_class.dart';
import 'rating_labels.dart';
import 'record_format.dart';

/// Результат рекорда, расчётный 1ПМ, дата, категория, статус и причина отказа.
class RecordFacts extends StatelessWidget {
  /// Создаёт блок фактов о [record].
  const RecordFacts({super.key, required this.record, required this.format});

  final GymRecord record;
  final RecordFormat format;

  /// Строит строки фактов; статус выделен цветом успеха или ошибки.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final weightClass = WeightClass.fromId(record.weightClassId);
    final status = record.appealed && record.status == RecordStatus.pending
        ? l10n.recordStatusAppealed
        : record.status.label(l10n);
    final statusColor = switch (record.status) {
      RecordStatus.approved => colors.success,
      RecordStatus.rejected => colors.error,
      RecordStatus.pending => colors.textSecondary,
    };
    final reason = record.rejectionReason;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          title: Text(record.exercise.label(l10n)),
          subtitle: Text(format.lift(record)),
        ),
        ListTile(
          title: Text(l10n.ratingMetricE1rm),
          subtitle: Text(format.weight(record.e1rmKg)),
        ),
        ListTile(
          title: Text(l10n.recordDateLabel),
          subtitle: Text(format.date(record.performedAt)),
        ),
        if (weightClass != null)
          ListTile(
            title: Text(l10n.recordWeightClassLabel),
            subtitle: Text(
              '${record.sex.label(l10n)} · ${weightClass.label(l10n)}',
            ),
          ),
        ListTile(
          title: Text(l10n.recordStatusLabel),
          subtitle: Text(status, style: TextStyle(color: statusColor)),
        ),
        if (reason != null)
          ListTile(
            title: Text(l10n.recordRejectionLabel),
            subtitle: Text(reason),
          ),
      ],
    );
  }
}
