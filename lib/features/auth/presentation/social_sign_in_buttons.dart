import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/theme_context.dart';
import '../../../core/errors/result.dart';
import '../../../core/widgets/failure_snack_bar.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../data/auth_repository_provider.dart';

/// Кнопки входа через Google и Apple; Apple только на iOS, на вебе кнопок нет.
class SocialSignInButtons extends ConsumerStatefulWidget {
  /// Создаёт блок кнопок социального входа.
  const SocialSignInButtons({super.key});

  /// Создаёт состояние блока.
  @override
  ConsumerState<SocialSignInButtons> createState() =>
      _SocialSignInButtonsState();
}

/// Блокирует кнопки, пока идёт вход.
class _SocialSignInButtonsState extends ConsumerState<SocialSignInButtons> {
  bool _busy = false;

  /// Строит разделитель «или» и кнопки провайдеров; в веб-сборке для просмотра их нет.
  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return const SizedBox.shrink();
    }
    final l10n = AppLocalizations.of(context);
    final spacing = context.spacing;
    final repository = ref.read(authRepositoryProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.symmetric(vertical: spacing.md),
          child: Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: EdgeInsetsDirectional.symmetric(
                  horizontal: spacing.sm,
                ),
                child: Text(
                  l10n.authOrDivider,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              const Expanded(child: Divider()),
            ],
          ),
        ),
        OutlinedButton(
          onPressed: _busy ? null : () => _run(repository.signInWithGoogle),
          child: Text(l10n.authContinueWithGoogle, textAlign: TextAlign.center),
        ),
        if (defaultTargetPlatform == TargetPlatform.iOS) ...[
          SizedBox(height: spacing.sm),
          OutlinedButton(
            onPressed: _busy ? null : () => _run(repository.signInWithApple),
            child: Text(
              l10n.authContinueWithApple,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ],
    );
  }

  /// Запускает вход через провайдера и показывает ошибку, если он не удался.
  Future<void> _run(Future<Result<void>> Function() signIn) async {
    setState(() => _busy = true);
    final result = await signIn();
    if (!mounted) {
      return;
    }
    setState(() => _busy = false);
    if (result is Failure<void>) {
      showFailureSnackBar(context, result.failure);
    }
  }
}
