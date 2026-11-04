import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../errors/app_failure.dart';
import '../errors/app_failure_message.dart';

/// Показывает понятное сообщение об ошибке; отмену пользователем не показывает.
void showFailureSnackBar(
  BuildContext context,
  AppFailure failure, {
  VoidCallback? onRetry,
}) {
  if (failure == AppFailure.cancelled) {
    return;
  }
  final l10n = AppLocalizations.of(context);
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(failure.message(l10n)),
        action: onRetry == null
            ? null
            : SnackBarAction(label: l10n.actionRetry, onPressed: onRetry),
      ),
    );
}
