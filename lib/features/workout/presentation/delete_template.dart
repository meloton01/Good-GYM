import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/result.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/failure_snack_bar.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../auth/data/auth_repository_provider.dart';
import '../data/workout_template_repository_provider.dart';

/// Удаляет шаблон [templateId] после подтверждения и закрывает его экран.
Future<void> deleteTemplate(
  BuildContext context,
  WidgetRef ref,
  String templateId,
) async {
  final uid = ref.read(authUserProvider).value?.uid;
  final l10n = AppLocalizations.of(context);
  final confirmed = await showConfirmDialog(
    context,
    title: l10n.templateDelete,
    message: l10n.templateDeleteMessage,
    confirmLabel: l10n.actionDelete,
    destructive: true,
  );
  if (uid == null || !confirmed || !context.mounted) {
    return;
  }
  final result = await ref
      .read(workoutTemplateRepositoryProvider)
      .deleteTemplate(uid, templateId);
  if (!context.mounted) {
    return;
  }
  switch (result) {
    case Success():
      context.pop();
    case Failure(:final failure):
      showFailureSnackBar(context, failure);
  }
}
