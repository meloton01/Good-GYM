import 'package:flutter/material.dart';

import '../../../app/theme/theme_context.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../auth/presentation/password_field.dart';

/// Подтверждение удаления; [password] null, если вход был через Google или Apple.
typedef DeleteAccountConfirmation = ({String? password});

/// Показывает диалог удаления аккаунта; null, если пользователь отменил.
Future<DeleteAccountConfirmation?> showDeleteAccountDialog(
  BuildContext context, {
  required bool askPassword,
}) {
  return showDialog<DeleteAccountConfirmation>(
    context: context,
    builder: (context) => _DeleteAccountDialog(askPassword: askPassword),
  );
}

/// Диалог с предупреждением и, для входа по паролю, полем текущего пароля.
class _DeleteAccountDialog extends StatefulWidget {
  /// Создаёт диалог удаления.
  const _DeleteAccountDialog({required this.askPassword});

  final bool askPassword;

  /// Создаёт состояние диалога.
  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

/// Хранит введённый пароль.
class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  final _formKey = GlobalKey<FormState>();
  final _password = TextEditingController();

  /// Освобождает контроллер поля.
  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  /// Строит предупреждение, поле пароля и кнопки отмены и удаления.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.accountDeleteTitle),
      scrollable: true,
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.accountDeleteMessage),
            SizedBox(height: context.spacing.md),
            if (widget.askPassword)
              PasswordField(
                controller: _password,
                label: l10n.accountCurrentPassword,
                validator: (value) =>
                    (value ?? '').isEmpty ? l10n.validationRequired : null,
                onSubmitted: _confirm,
              )
            else
              Text(l10n.accountDeleteSocialHint),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.actionCancel),
        ),
        TextButton(
          style: TextButton.styleFrom(foregroundColor: context.colors.error),
          onPressed: _confirm,
          child: Text(l10n.accountDeleteConfirm),
        ),
      ],
    );
  }

  /// Закрывает диалог с паролем, если форма заполнена.
  void _confirm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    Navigator.of(context)
        .pop((password: widget.askPassword ? _password.text : null));
  }
}
