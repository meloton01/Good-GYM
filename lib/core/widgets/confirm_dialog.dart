import 'package:flutter/material.dart';

import '../../app/theme/theme_context.dart';
import '../../l10n/generated/app_localizations.dart';

/// Спрашивает подтверждение действия; true, если пользователь подтвердил.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  bool destructive = false,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) {
      final colors = context.colors;
      return AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(child: Text(message)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context).actionCancel),
          ),
          TextButton(
            style: destructive
                ? TextButton.styleFrom(foregroundColor: colors.error)
                : null,
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      );
    },
  );
  return confirmed ?? false;
}
