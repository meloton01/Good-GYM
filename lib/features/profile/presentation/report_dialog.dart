import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../domain/profile_limits.dart';
import '../domain/report_reason.dart';
import 'report_reason_labels.dart';

/// Причина и комментарий, выбранные в диалоге жалобы.
typedef ReportDraft = ({ReportReason reason, String comment});

/// Спрашивает причину жалобы; null, если пользователь передумал.
Future<ReportDraft?> showReportDialog(BuildContext context) {
  return showDialog<ReportDraft>(
    context: context,
    builder: (context) => const _ReportDialog(),
  );
}

/// Диалог жалобы: причина из списка и необязательный комментарий.
class _ReportDialog extends StatefulWidget {
  /// Создаёт диалог жалобы.
  const _ReportDialog();

  /// Создаёт состояние диалога.
  @override
  State<_ReportDialog> createState() => _ReportDialogState();
}

/// Хранит выбранную причину и текст комментария.
class _ReportDialogState extends State<_ReportDialog> {
  final _comment = TextEditingController();
  ReportReason? _reason;

  /// Освобождает контроллер комментария.
  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  /// Строит список причин, поле комментария и кнопки.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final reason = _reason;
    return AlertDialog(
      title: Text(l10n.reportDialogTitle),
      content: SingleChildScrollView(
        child: RadioGroup<ReportReason>(
          groupValue: reason,
          onChanged: (value) => setState(() => _reason = value),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final option in ReportReason.values)
                RadioListTile<ReportReason>(
                  value: option,
                  contentPadding: EdgeInsetsDirectional.zero,
                  title: Text(option.label(l10n)),
                ),
              TextField(
                controller: _comment,
                maxLength: ProfileLimits.reportCommentMaxLength,
                minLines: 1,
                maxLines: 4,
                decoration: InputDecoration(labelText: l10n.reportCommentLabel),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.actionCancel),
        ),
        TextButton(
          onPressed: reason == null
              ? null
              : () =>
                    Navigator.of(context)
                        .pop((reason: reason, comment: _comment.text.trim())),
          child: Text(l10n.reportSendAction),
        ),
      ],
    );
  }
}
