import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
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
import 'social_sign_in_buttons.dart';

/// Экран входа по email и паролю, через Google и Apple.
class SignInScreen extends ConsumerStatefulWidget {
  /// Создаёт экран входа.
  const SignInScreen({super.key});

  /// Создаёт состояние экрана.
  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

/// Хранит поля формы и флаг отправки.
class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _submitting = false;

  /// Освобождает контроллеры полей.
  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  /// Строит форму входа и ссылки на регистрацию и сброс пароля.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final spacing = context.spacing;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.authSignInTitle)),
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
                validator: (value) =>
                    CredentialValidators.requiredPassword(l10n, value),
                onSubmitted: _submit,
              ),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton(
                  onPressed: () => context.push(AppRoutes.resetPassword),
                  child: Text(l10n.authForgotPassword),
                ),
              ),
              SizedBox(height: spacing.sm),
              PrimaryButton(
                label: l10n.authSignInAction,
                loading: _submitting,
                onPressed: _submit,
              ),
              SizedBox(height: spacing.sm),
              TextButton(
                onPressed: () => context.push(AppRoutes.signUp),
                child: Text(l10n.authSignUpAction),
              ),
              const SocialSignInButtons(),
            ],
          ),
        ),
      ),
    );
  }

  /// Проверяет форму и выполняет вход; переход дальше делает роутер по сессии.
  Future<void> _submit() async {
    if (_submitting || !_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _submitting = true);
    final result = await ref
        .read(authRepositoryProvider)
        .signInWithEmail(email: _email.text.trim(), password: _password.text);
    if (!mounted) {
      return;
    }
    setState(() => _submitting = false);
    if (result is Failure<void>) {
      showFailureSnackBar(context, result.failure);
    }
  }
}
