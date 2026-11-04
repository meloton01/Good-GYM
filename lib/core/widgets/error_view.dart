import 'package:flutter/material.dart';

import '../../app/theme/theme_context.dart';
import '../../l10n/generated/app_localizations.dart';
import '../errors/app_failure.dart';
import '../errors/app_failure_message.dart';

/// Состояние ошибки экрана: что случилось и кнопка повтора.
class ErrorView extends StatelessWidget {
  /// Создаёт состояние ошибки.
  const ErrorView({
    super.key,
    required this.title,
    required this.failure,
    required this.onRetry,
    this.secondaryLabel,
    this.onSecondary,
  });

  final String title;
  final AppFailure failure;
  final VoidCallback onRetry;

  /// Подпись и действие второй кнопки, например выхода из аккаунта.
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  /// Строит прокручиваемый блок с текстом ошибки и кнопкой.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final spacing = context.spacing;
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsetsDirectional.all(spacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: context.sizes.iconLarge,
              color: context.colors.error,
            ),
            SizedBox(height: spacing.md),
            Text(
              title,
              style: textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: spacing.sm),
            Text(
              failure.message(l10n),
              style: textTheme.bodyMedium?.copyWith(
                color: context.colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: spacing.lg),
            FilledButton(onPressed: onRetry, child: Text(l10n.actionRetry)),
            if (secondaryLabel != null && onSecondary != null) ...[
              SizedBox(height: spacing.sm),
              TextButton(onPressed: onSecondary, child: Text(secondaryLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
