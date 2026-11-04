import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_failure.dart';
import '../../../core/firebase/firestore_failure_mapper.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../auth/data/auth_repository_provider.dart';
import '../data/workout_template_repository_provider.dart';
import 'workout_editor_screen.dart';

/// Открывает сохранённый шаблон в редакторе, когда шаблоны загрузились.
class TemplateEditorScreen extends ConsumerWidget {
  /// Создаёт экран шаблона [templateId].
  const TemplateEditorScreen({super.key, required this.templateId});

  final String templateId;

  /// Строит загрузку, ошибку, отсутствие шаблона или редактор.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final uid = ref.watch(authUserProvider).value?.uid;
    if (uid == null) {
      return const Scaffold(body: LoadingView());
    }
    final templates = ref.watch(workoutTemplatesProvider(uid));
    final template = templates.value
        ?.where((item) => item.id == templateId)
        .firstOrNull;
    if (template != null) {
      return WorkoutEditorScreen(
        key: ValueKey(template.id),
        initial: template,
        savedTemplate: true,
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(l10n.templateEditTitle)),
      body: switch (templates) {
        AsyncError(:final error) => ErrorView(
          title: l10n.templateEditTitle,
          failure: failureFromError(error),
          onRetry: () => ref.invalidate(workoutTemplatesProvider(uid)),
        ),
        AsyncData() => ErrorView(
          title: l10n.templateEditTitle,
          failure: AppFailure.notFound,
          onRetry: () => ref.invalidate(workoutTemplatesProvider(uid)),
        ),
        _ => const LoadingView(),
      },
    );
  }
}
