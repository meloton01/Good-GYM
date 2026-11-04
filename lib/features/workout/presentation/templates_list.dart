import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/theme/theme_context.dart';
import '../../../core/firebase/firestore_failure_mapper.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../data/workout_template_repository_provider.dart';
import '../domain/workout_template.dart';
import 'start_workout.dart';

/// Шаблоны тренировок: запуск в одно касание и переход к редактированию.
class TemplatesList extends ConsumerWidget {
  /// Создаёт список шаблонов пользователя [uid].
  const TemplatesList({super.key, required this.uid});

  final String uid;

  /// Строит загрузку, ошибку, пустой список или шаблоны.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return switch (ref.watch(workoutTemplatesProvider(uid))) {
      AsyncData(:final value) when value.isEmpty => EmptyStateView(
        icon: Icons.content_copy_rounded,
        title: l10n.templatesEmptyTitle,
        message: l10n.templatesEmptyMessage,
      ),
      AsyncData(:final value) => ListView.builder(
        padding: EdgeInsetsDirectional.only(bottom: context.sizes.fabClearance),
        itemCount: value.length,
        itemBuilder: (context, index) =>
            _TemplateTile(uid: uid, template: value[index]),
      ),
      AsyncError(:final error) => ErrorView(
        title: l10n.workoutTemplatesTab,
        failure: failureFromError(error),
        onRetry: () => ref.invalidate(workoutTemplatesProvider(uid)),
      ),
      _ => const LoadingView(),
    };
  }
}

/// Пункт шаблона с кнопкой запуска.
class _TemplateTile extends ConsumerWidget {
  /// Создаёт пункт шаблона.
  const _TemplateTile({required this.uid, required this.template});

  final String uid;
  final WorkoutTemplate template;

  /// Строит название, число упражнений и кнопку «Начать».
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return ListTile(
      title: Text(template.title),
      subtitle: Text(l10n.exerciseCount(template.exercises.length)),
      onTap: () => context.push(AppRoutes.workoutTemplate(template.id)),
      trailing: IconButton(
        tooltip: l10n.workoutStart,
        icon: const Icon(Icons.play_arrow_rounded),
        onPressed: () => startWorkout(
          context,
          ref,
          ownerId: uid,
          title: template.title,
          exercises: template.exercises,
        ),
      ),
    );
  }
}
