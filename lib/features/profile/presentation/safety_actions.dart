import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/result.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/failure_snack_bar.dart';
import '../../../core/widgets/info_snack_bar.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../auth/data/auth_repository_provider.dart';
import '../data/safety_repository_provider.dart';
import '../domain/blocked_user.dart';
import '../domain/user_report.dart';
import 'report_dialog.dart';

/// Спрашивает причину и отправляет жалобу на пользователя или его рекорд [recordId].
Future<void> reportContent(
  BuildContext context,
  WidgetRef ref, {
  required String targetUid,
  String? recordId,
}) async {
  final uid = ref.read(authUserProvider).value?.uid;
  if (uid == null) {
    return;
  }
  final draft = await showReportDialog(context);
  if (draft == null || !context.mounted) {
    return;
  }
  final result = await ref
      .read(safetyRepositoryProvider)
      .report(
        UserReport(
          reporterId: uid,
          targetUid: targetUid,
          recordId: recordId,
          reason: draft.reason,
          comment: draft.comment,
        ),
      );
  if (!context.mounted) {
    return;
  }
  switch (result) {
    case Success():
      showInfoSnackBar(context, AppLocalizations.of(context).reportSent);
    case Failure(:final failure):
      showFailureSnackBar(context, failure);
  }
}

/// Подтверждает и блокирует пользователя [user].
Future<void> blockUser(
  BuildContext context,
  WidgetRef ref,
  BlockedUser user,
) async {
  final uid = ref.read(authUserProvider).value?.uid;
  if (uid == null) {
    return;
  }
  final l10n = AppLocalizations.of(context);
  final confirmed = await showConfirmDialog(
    context,
    title: l10n.blockConfirmTitle(user.nickname),
    message: l10n.blockConfirmMessage,
    confirmLabel: l10n.blockUserAction,
    destructive: true,
  );
  if (!confirmed || !context.mounted) {
    return;
  }
  final result = await ref.read(safetyRepositoryProvider).block(uid, user);
  if (result is Failure<void> && context.mounted) {
    showFailureSnackBar(context, result.failure);
  }
}

/// Снимает блокировку пользователя [otherUid]; true, если получилось.
Future<bool> unblockUser(
  BuildContext context,
  WidgetRef ref,
  String otherUid,
) async {
  final uid = ref.read(authUserProvider).value?.uid;
  if (uid == null) {
    return false;
  }
  final result = await ref
      .read(safetyRepositoryProvider)
      .unblock(uid: uid, otherUid: otherUid);
  if (result is Failure<void> && context.mounted) {
    showFailureSnackBar(context, result.failure);
  }
  return result is Success<void>;
}
