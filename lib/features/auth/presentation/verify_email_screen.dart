import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/theme_context.dart';
import '../../../core/errors/result.dart';
import '../../../core/widgets/failure_snack_bar.dart';
import '../../../core/widgets/form_screen_body.dart';
import '../../../core/widgets/info_snack_bar.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../data/auth_repository_provider.dart';

/// Экран ожидания подтверждения email после регистрации.
class VerifyEmailScreen extends ConsumerStatefulWidget {
  /// Создаёт экран подтверждения email.
  const VerifyEmailScreen({super.key});

  /// Создаёт состояние экрана.
  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

/// Хранит, какое действие сейчас выполняется.
class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  bool _checking = false;
  bool _resending = false;

  /// Строит пояснение и кнопки проверки, повторной отправки и выхода.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final spacing = context.spacing;
    final email = ref.watch(authUserProvider).value?.email ?? '';
    return Scaffold(
      appBar: AppBar(title: Text(l10n.authVerifyEmailTitle)),
      body: FormScreenBody(
        children: [
          Text(
            l10n.authVerifyEmailMessage(email),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          SizedBox(height: spacing.lg),
          PrimaryButton(
            label: l10n.authVerifyEmailConfirmed,
            loading: _checking,
            onPressed: _check,
          ),
          SizedBox(height: spacing.sm),
          OutlinedButton(
            onPressed: _resending ? null : _resend,
            child: Text(
              l10n.authVerifyEmailResend,
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: spacing.sm),
          TextButton(onPressed: _signOut, child: Text(l10n.authSignOut)),
        ],
      ),
    );
  }

  /// Перечитывает статус; при подтверждении роутер сам откроет следующий шаг.
  Future<void> _check() async {
    setState(() => _checking = true);
    final result = await ref
        .read(authRepositoryProvider)
        .reloadEmailVerification();
    if (!mounted) {
      return;
    }
    setState(() => _checking = false);
    switch (result) {
      case Success(value: false):
        showInfoSnackBar(
          context,
          AppLocalizations.of(context).authVerifyEmailPending,
        );
      case Failure(:final failure):
        showFailureSnackBar(context, failure, onRetry: _check);
      case Success():
        break;
    }
  }

  /// Выходит из аккаунта, например чтобы зарегистрироваться с другим email.
  Future<void> _signOut() async {
    final result = await ref.read(authRepositoryProvider).signOut();
    if (result is Failure<void> && mounted) {
      showFailureSnackBar(context, result.failure, onRetry: _signOut);
    }
  }

  /// Отправляет письмо ещё раз.
  Future<void> _resend() async {
    setState(() => _resending = true);
    final result = await ref
        .read(authRepositoryProvider)
        .sendEmailVerification(
          languageCode: Localizations.localeOf(context).languageCode,
        );
    if (!mounted) {
      return;
    }
    setState(() => _resending = false);
    switch (result) {
      case Success():
        showInfoSnackBar(
          context,
          AppLocalizations.of(context).authVerifyEmailSent,
        );
      case Failure(:final failure):
        showFailureSnackBar(context, failure);
    }
  }
}
