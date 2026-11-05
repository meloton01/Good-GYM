import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/theme_context.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'record_actions.dart';

/// Кнопки модератора: одобрить или отклонить с причиной; на время запроса блокируются.
class RecordReviewButtons extends ConsumerStatefulWidget {
  /// Создаёт кнопки для рекорда [recordId].
  const RecordReviewButtons({super.key, required this.recordId});

  final String recordId;

  /// Создаёт состояние кнопок.
  @override
  ConsumerState<RecordReviewButtons> createState() =>
      _RecordReviewButtonsState();
}

/// Хранит флаг идущего запроса.
class _RecordReviewButtonsState extends ConsumerState<RecordReviewButtons> {
  bool _busy = false;

  /// Строит две кнопки в строку, при крупном шрифте друг под другом.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final spacing = context.spacing;
    return Padding(
      padding: EdgeInsetsDirectional.all(spacing.md),
      child: Wrap(
        spacing: spacing.md,
        runSpacing: spacing.sm,
        alignment: WrapAlignment.end,
        children: [
          OutlinedButton(
            onPressed: _busy
                ? null
                : () => _run(() => rejectRecord(context, ref, widget.recordId)),
            child: Text(l10n.rejectRecordAction),
          ),
          FilledButton(
            onPressed: _busy
                ? null
                : () =>
                      _run(() => approveRecord(context, ref, widget.recordId)),
            child: Text(l10n.approveRecordAction),
          ),
        ],
      ),
    );
  }

  /// Выполняет действие, пока кнопки неактивны.
  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    await action();
    if (mounted) {
      setState(() => _busy = false);
    }
  }
}
