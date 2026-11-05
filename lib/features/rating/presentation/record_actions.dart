import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/result.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/failure_snack_bar.dart';
import '../../../core/widgets/info_snack_bar.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../data/record_repository_providers.dart';
import 'leaderboard_controllers.dart';
import 'reject_dialog.dart';

/// Обжалует отказ после подтверждения.
Future<void> appealRecord(
  BuildContext context,
  WidgetRef ref,
  String recordId,
) async {
  final l10n = AppLocalizations.of(context);
  final confirmed = await showConfirmDialog(
    context,
    title: l10n.appealRecordTitle,
    message: l10n.appealRecordMessage,
    confirmLabel: l10n.appealRecordAction,
  );
  if (!confirmed || !context.mounted) {
    return;
  }
  final result = await ref
      .read(recordRepositoryProvider)
      .appealRecord(recordId);
  if (context.mounted) {
    _report(context, result, l10n.appealRecordSent);
  }
}

/// Одобряет рекорд и обновляет очередь и таблицы.
Future<void> approveRecord(
  BuildContext context,
  WidgetRef ref,
  String recordId,
) async {
  final l10n = AppLocalizations.of(context);
  final result = await ref
      .read(recordRepositoryProvider)
      .approveRecord(recordId);
  if (result is Success<void>) {
    ref
      ..invalidate(moderationQueueProvider)
      ..invalidate(leaderboardProvider);
  }
  if (context.mounted) {
    _report(context, result, l10n.recordApproved);
  }
}

/// Спрашивает причину и отклоняет рекорд.
Future<void> rejectRecord(
  BuildContext context,
  WidgetRef ref,
  String recordId,
) async {
  final l10n = AppLocalizations.of(context);
  final reason = await showRejectDialog(context);
  if (reason == null || !context.mounted) {
    return;
  }
  final result = await ref
      .read(recordRepositoryProvider)
      .rejectRecord(recordId, reason: reason);
  if (result is Success<void>) {
    ref.invalidate(moderationQueueProvider);
  }
  if (context.mounted) {
    _report(context, result, l10n.recordRejected);
  }
}

/// Показывает итог операции.
void _report(BuildContext context, Result<void> result, String success) {
  switch (result) {
    case Success():
      showInfoSnackBar(context, success);
    case Failure(:final failure):
      showFailureSnackBar(context, failure);
  }
}
