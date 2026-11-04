import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/theme_context.dart';
import '../../../core/errors/result.dart';
import '../../../core/widgets/failure_snack_bar.dart';
import '../../../core/widgets/form_screen_body.dart';
import '../../../core/widgets/info_snack_bar.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../data/auth_repository_provider.dart';
import 'credential_validators.dart';
import 'password_field.dart';

/// Смена пароля: текущий пароль, новый и его повтор.
class ChangePasswordScreen extends ConsumerStatefulWidget {
  /// Создаёт экран смены пароля.
  const ChangePasswordScreen({super.key});

  /// Создаёт состояние экрана.
  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

/// Хранит поля формы и флаг отправки.
class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirmation = TextEditingController();
  bool _submitting = false;

  /// Освобождает контроллеры полей.
  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  /// Строит форму смены пароля.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final spacing = context.spacing;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.accountChangePassword)),
      body: Form(
        key: _formKey,
        child: FormScreenBody(
          children: [
            PasswordField(
              controller: _current,
              label: l10n.accountCurrentPassword,
              textInputAction: TextInputAction.next,
              validator: (value) =>
                  CredentialValidators.requiredPassword(l10n, value),
            ),
            SizedBox(height: spacing.md),
            PasswordField(
              controller: _next,
              label: l10n.accountNewPassword,
              autofillHint: AutofillHints.newPassword,
              textInputAction: TextInputAction.next,
              validator: (value) =>
                  CredentialValidators.newPassword(l10n, value),
            ),
            SizedBox(height: spacing.md),
            PasswordField(
              controller: _confirmation,
              label: l10n.authConfirmPasswordLabel,
              autofillHint: AutofillHints.newPassword,
              validator: (value) => value == _next.text
                  ? null
                  : l10n.validationPasswordsDoNotMatch,
              onSubmitted: _submit,
            ),
            SizedBox(height: spacing.lg),
            PrimaryButton(
              label: l10n.actionSave,
              loading: _submitting,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }

  /// Подтверждает личность текущим паролем и ставит новый.
  Future<void> _submit() async {
    if (_submitting || !_formKey.currentState!.validate()) {
      return;
    }
    final auth = ref.read(authRepositoryProvider);
    setState(() => _submitting = true);
    var result = await auth.reauthenticate(password: _current.text);
    if (result is Success<void>) {
      result = await auth.changePassword(_next.text);
    }
    if (!mounted) {
      return;
    }
    setState(() => _submitting = false);
    switch (result) {
      case Success():
        showInfoSnackBar(
          context,
          AppLocalizations.of(context).accountPasswordChanged,
        );
        context.pop();
      case Failure(:final failure):
        showFailureSnackBar(context, failure);
    }
  }
}
