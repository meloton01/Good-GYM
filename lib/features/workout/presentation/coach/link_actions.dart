import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/result.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/failure_snack_bar.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../data/coach_repository_providers.dart';
import '../../domain/coach_link.dart';

/// Принимает приглашение и показывает ошибку, если связь стала недоступна.
Future<void> acceptLink(
  BuildContext context,
  WidgetRef ref,
  CoachLink link,
) async {
  final result = await ref.read(coachLinkRepositoryProvider).accept(link);
  if (context.mounted) {
    _report(context, result);
  }
}

/// Отклоняет входящее или отзывает своё приглашение.
Future<void> removeLink(
  BuildContext context,
  WidgetRef ref,
  CoachLink link,
) async {
  final result = await ref.read(coachLinkRepositoryProvider).remove(link);
  if (context.mounted) {
    _report(context, result);
  }
}

/// Разрывает активную связь после подтверждения; true, если связь разорвана.
Future<bool> endLink(
  BuildContext context,
  WidgetRef ref,
  CoachLink link,
  String uid,
) async {
  final l10n = AppLocalizations.of(context);
  final confirmed = await showConfirmDialog(
    context,
    title: l10n.coachEndLink,
    message: l10n.coachEndLinkMessage(link.partnerNickname(uid)),
    confirmLabel: l10n.coachEndLinkConfirm,
    destructive: true,
  );
  if (!confirmed || !context.mounted) {
    return false;
  }
  final result = await ref.read(coachLinkRepositoryProvider).end(link);
  if (context.mounted) {
    _report(context, result);
  }
  return result is Success<void>;
}

/// Показывает ошибку операции со связью.
void _report(BuildContext context, Result<void> result) {
  if (result case Failure(:final failure)) {
    showFailureSnackBar(context, failure);
  }
}
