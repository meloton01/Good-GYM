import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/theme/theme_context.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/gym_record.dart';
import '../domain/record_status.dart';
import 'rating_labels.dart';
import 'record_format.dart';

/// Строка рекорда: упражнение, подход, дата и статус проверки; открывает рекорд.
class RecordTile extends StatelessWidget {
  /// Создаёт строку; [showAuthor] добавляет ник автора для очереди модератора.
  const RecordTile({
    super.key,
    required this.record,
    required this.format,
    this.showAuthor = false,
    this.showStatus = true,
  });

  final GymRecord record;
  final RecordFormat format;
  final bool showAuthor;
  final bool showStatus;

  /// Строит ListTile со статусом цветом ошибки или успеха.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final statusColor = switch (record.status) {
      RecordStatus.approved => colors.success,
      RecordStatus.rejected => colors.error,
      RecordStatus.pending => colors.textSecondary,
    };
    final lines = [
      if (showAuthor) record.nickname,
      '${format.lift(record)} · ${format.date(record.performedAt)}',
    ];
    return ListTile(
      title: Text(record.exercise.label(l10n)),
      subtitle: Text(lines.join('\n')),
      isThreeLine: showAuthor,
      trailing: showStatus
          ? Text(
              record.appealed && record.status == RecordStatus.pending
                  ? l10n.recordStatusAppealed
                  : record.status.label(l10n),
              style: Theme.of(context).textTheme.labelLarge
                  ?.copyWith(color: statusColor),
            )
          : const Icon(Icons.chevron_right_rounded),
      onTap: () => context.push(AppRoutes.recordDetail(record.id)),
    );
  }
}
