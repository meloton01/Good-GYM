import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../errors/app_failure.dart';
import '../errors/app_failure_message.dart';

/// Показывает понятное сообщение об ошибке с кнопкой повтора.
void showFailureSnackBar(
  BuildContext context,
  AppFailure failure, {
  required VoidCallback onRetry,
}) {
  final l10n = AppLocalizations.of(context);
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(failure.message(l10n)),
        action: SnackBarAction(label: l10n.actionRetry, onPressed: onRetry),
      ),
    );
}
