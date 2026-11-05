import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../domain/record_limits.dart';

/// Спрашивает причину отказа; null, если модератор передумал.
Future<String?> showRejectDialog(BuildContext context) {
  return showDialog<String>(
    context: context,
    builder: (context) => const _RejectDialog(),
  );
}

/// Диалог с полем причины отказа.
class _RejectDialog extends StatefulWidget {
  /// Создаёт диалог.
  const _RejectDialog();

  /// Создаёт состояние диалога.
  @override
  State<_RejectDialog> createState() => _RejectDialogState();
}

/// Хранит поле причины и форму.
class _RejectDialogState extends State<_RejectDialog> {
  final _formKey = GlobalKey<FormState>();
  final _reason = TextEditingController();

  /// Освобождает контроллер поля.
  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  /// Строит поле причины и кнопки.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.rejectRecordTitle),
      scrollable: true,
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _reason,
          maxLength: RecordLimits.maxReasonLength,
          maxLines: null,
          decoration: InputDecoration(labelText: l10n.rejectReasonLabel),
          validator: (value) {
            final length = value?.trim().length ?? 0;
            return length < RecordLimits.minReasonLength
                ? l10n.rejectReasonTooShort(RecordLimits.minReasonLength)
                : null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.actionCancel),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.of(context).pop(_reason.text.trim());
            }
          },
          child: Text(l10n.rejectRecordAction),
        ),
      ],
    );
  }
}
