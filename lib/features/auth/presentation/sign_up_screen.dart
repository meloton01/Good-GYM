import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/theme_context.dart';
import '../../../core/errors/result.dart';
import '../../../core/widgets/failure_snack_bar.dart';
import '../../../core/widgets/form_screen_body.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../data/auth_repository_provider.dart';
import 'credential_validators.dart';
import 'email_field.dart';
import 'password_field.dart';

/// Экран регистрации по email и паролю.
class SignUpScreen extends ConsumerStatefulWidget {
  /// Создаёт экран регистрации.
  const SignUpScreen({super.key});

  /// Создаёт состояние экрана.
  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

/// Хранит поля формы и флаг отправки.
class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  bool _submitting = false;

  /// Освобождает контроллеры полей.
  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  /// Строит форму регистрации.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final spacing = context.spacing;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.authSignUpTitle)),
      body: Form(
        key: _formKey,
        child: AutofillGroup(
          child: FormScreenBody(
            children: [
              EmailField(controller: _email),
              SizedBox(height: spacing.md),
              PasswordField(
                controller: _password,
                label: l10n.authPasswordLabel,
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
                validator: (value) => value == _password.text
                    ? null
                    : l10n.validationPasswordsDoNotMatch,
                onSubmitted: _submit,
              ),
              SizedBox(height: spacing.lg),
              PrimaryButton(
                label: l10n.authSignUpAction,
                loading: _submitting,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Регистрирует пользователя; после входа роутер откроет подтверждение email.
  Future<void> _submit() async {
    if (_submitting || !_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _submitting = true);
    final result = await ref
        .read(authRepositoryProvider)
        .signUpWithEmail(
          email: _email.text.trim(),
          password: _password.text,
          languageCode: Localizations.localeOf(context).languageCode,
        );
    if (!mounted) {
      return;
    }
    setState(() => _submitting = false);
    if (result is Failure<void>) {
      showFailureSnackBar(context, result.failure);
    }
  }
}
