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

/// Смена email: текущий пароль для подтверждения и новый адрес.
class ChangeEmailScreen extends ConsumerStatefulWidget {
  /// Создаёт экран смены email.
  const ChangeEmailScreen({super.key});

  /// Создаёт состояние экрана.
  @override
  ConsumerState<ChangeEmailScreen> createState() => _ChangeEmailScreenState();
}

/// Хранит поля формы, флаг отправки и адрес, на который ушло письмо.
class _ChangeEmailScreenState extends ConsumerState<ChangeEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _email = TextEditingController();
  bool _submitting = false;
  String? _sentTo;

  /// Освобождает контроллеры полей.
  @override
  void dispose() {
    _password.dispose();
    _email.dispose();
    super.dispose();
  }

  /// Строит форму или подтверждение отправки письма.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final spacing = context.spacing;
    final sentTo = _sentTo;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.accountChangeEmail)),
      body: Form(
        key: _formKey,
        child: FormScreenBody(
          children: [
            PasswordField(
              controller: _password,
              label: l10n.accountCurrentPassword,
              textInputAction: TextInputAction.next,
              validator: (value) =>
                  CredentialValidators.requiredPassword(l10n, value),
            ),
            SizedBox(height: spacing.md),
            EmailField(
              controller: _email,
              label: l10n.accountNewEmail,
              textInputAction: TextInputAction.done,
              onSubmitted: _submit,
            ),
            if (sentTo != null) ...[
              SizedBox(height: spacing.md),
              Text(l10n.accountEmailChangeSent(sentTo)),
            ],
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

  /// Подтверждает личность паролем и отправляет письмо на новый адрес.
  Future<void> _submit() async {
    if (_submitting || !_formKey.currentState!.validate()) {
      return;
    }
    final email = _email.text.trim();
    final languageCode = Localizations.localeOf(context).languageCode;
    final auth = ref.read(authRepositoryProvider);
    setState(() => _submitting = true);
    var result = await auth.reauthenticate(password: _password.text);
    if (result is Success<void>) {
      result = await auth.changeEmail(email, languageCode: languageCode);
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _submitting = false;
      if (result is Success<void>) {
        _sentTo = email;
      }
    });
    if (result case Failure(:final failure)) {
      showFailureSnackBar(context, failure);
    }
  }
}
