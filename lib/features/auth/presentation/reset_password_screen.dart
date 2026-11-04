import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/theme_context.dart';
import '../../../core/errors/result.dart';
import '../../../core/widgets/failure_snack_bar.dart';
import '../../../core/widgets/form_screen_body.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../data/auth_repository_provider.dart';
import 'email_field.dart';

/// Экран сброса пароля по email.
class ResetPasswordScreen extends ConsumerStatefulWidget {
  /// Создаёт экран сброса пароля.
  const ResetPasswordScreen({super.key});

  /// Создаёт состояние экрана.
  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

/// Хранит email, флаг отправки и адрес, на который письмо уже ушло.
class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _submitting = false;
  String? _sentTo;

  /// Освобождает контроллер поля.
  @override
  void dispose() {
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
      appBar: AppBar(title: Text(l10n.authResetPasswordTitle)),
      body: Form(
        key: _formKey,
        child: FormScreenBody(
          children: [
            EmailField(
              controller: _email,
              textInputAction: TextInputAction.done,
              onSubmitted: _submit,
            ),
            if (sentTo != null) ...[
              SizedBox(height: spacing.md),
              Text(
                l10n.authResetLinkSent(sentTo),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            SizedBox(height: spacing.lg),
            PrimaryButton(
              label: l10n.authSendResetLink,
              loading: _submitting,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }

  /// Отправляет письмо; одинаковый ответ для любого email, чтобы не раскрывать аккаунты.
  Future<void> _submit() async {
    if (_submitting || !_formKey.currentState!.validate()) {
      return;
    }
    final email = _email.text.trim();
    setState(() => _submitting = true);
    final result = await ref
        .read(authRepositoryProvider)
        .sendPasswordReset(
          email,
          languageCode: Localizations.localeOf(context).languageCode,
        );
    if (!mounted) {
      return;
    }
    setState(() {
      _submitting = false;
      if (result is Success<void>) {
        _sentTo = email;
      }
    });
    if (result is Failure<void>) {
      showFailureSnackBar(context, result.failure);
    }
  }
}
