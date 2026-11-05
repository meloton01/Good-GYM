import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/theme_context.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/firebase/firestore_failure_mapper.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/failure_snack_bar.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../auth/data/auth_repository_provider.dart';
import '../../../profile/data/user_profile_repository_provider.dart';
import '../../../profile/domain/user_profile.dart';
import '../../../settings/presentation/app_settings_controller.dart';
import '../../data/coach_repository_providers.dart';
import '../../domain/coach_plan.dart';
import '../../domain/plan_status.dart';
import '../exercise_labels.dart';
import '../start_workout.dart';
import '../workout_format.dart';
import 'plan_comments_section.dart';

/// План тренера: упражнения, статус, запуск у ученика, правка у тренера и комментарии.
class PlanDetailScreen extends ConsumerWidget {
  /// Создаёт экран плана [planId] ученика [athleteId].
  const PlanDetailScreen({
    super.key,
    required this.athleteId,
    required this.planId,
  });

  final String athleteId;
  final String planId;

  /// Строит загрузку, ошибку, удалённый план или план.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final uid = ref.watch(authUserProvider).value?.uid ?? '';
    final me = ref.watch(userProfileProvider(uid)).value;
    final key = (athleteId, planId);
    final loaded = ref.watch(coachPlanProvider(key));
    final plan = loaded.value;
    final canEdit =
        plan != null &&
        plan.coachId == uid &&
        plan.status == PlanStatus.assigned;
    return Scaffold(
      appBar: AppBar(
        title: Text(plan?.title ?? l10n.coachPlanTitle),
        actions: [
          if (canEdit)
            IconButton(
              tooltip: l10n.coachEditPlan,
              icon: const Icon(Icons.edit_outlined),
              onPressed: () =>
                  context.push(AppRoutes.planEditor(athleteId), extra: plan),
            ),
          if (plan != null && plan.coachId == uid)
            IconButton(
              tooltip: l10n.coachDeletePlan,
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: () => _delete(context, ref),
            ),
        ],
      ),
      body: switch (loaded) {
        AsyncData(:final value?) when me != null => _Plan(plan: value, me: me),
        AsyncData(value: null) => ErrorView(
          title: l10n.coachPlanTitle,
          failure: AppFailure.notFound,
          onRetry: () => ref.invalidate(coachPlanProvider(key)),
        ),
        AsyncError(:final error) => ErrorView(
          title: l10n.coachPlanTitle,
          failure: failureFromError(error),
          onRetry: () => ref.invalidate(coachPlanProvider(key)),
        ),
        _ => const LoadingView(),
      },
    );
  }

  /// Удаляет план после подтверждения и закрывает экран.
  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showConfirmDialog(
      context,
      title: l10n.coachDeletePlan,
      message: l10n.coachDeletePlanMessage,
      confirmLabel: l10n.actionDelete,
      destructive: true,
    );
    if (!confirmed || !context.mounted) {
      return;
    }
    final result = await ref
        .read(coachPlanRepositoryProvider)
        .deletePlan(athleteId, planId);
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
}

/// Содержимое плана.
class _Plan extends ConsumerWidget {
  /// Создаёт содержимое плана [plan] для пользователя [me].
  const _Plan({required this.plan, required this.me});

  final CoachPlan plan;
  final UserProfile me;

  /// Строит статус, заметку, подходы, действие и комментарии.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final format = WorkoutFormat.of(
      context,
      ref.watch(appSettingsProvider.select((s) => s.weightUnit)),
    );
    final completed = plan.status == PlanStatus.completed;
    final isStudent = me.uid == plan.athleteId;
    final workoutId = plan.workoutId;
    return ListView(
      padding: EdgeInsetsDirectional.only(bottom: context.spacing.lg),
      children: [
        ListTile(
          title: Text(
            completed ? l10n.planStatusCompleted : l10n.planStatusAssigned,
          ),
          subtitle: Text(l10n.coachPlanFrom(plan.coachNickname)),
        ),
        if (plan.note.isNotEmpty)
          ListTile(
            leading: const Icon(Icons.notes_rounded),
            title: Text(plan.note),
          ),
        for (final item in plan.exercises) ...[
          SectionHeader(title: item.exercise.name(l10n)),
          for (var index = 0; index < item.sets.length; index++)
            ListTile(
              title: Text(l10n.setNumber(index + 1)),
              subtitle: Text(
                l10n.setWithRest(
                  format.set(item.sets[index]),
                  format.rest(item.sets[index].restSeconds),
                ),
              ),
            ),
        ],
        if (isStudent && !completed)
          Padding(
            padding: EdgeInsetsDirectional.all(context.spacing.md),
            child: PrimaryButton(
              label: l10n.workoutStart,
              onPressed: () => startWorkout(
                context,
                ref,
                ownerId: me.uid,
                title: plan.title,
                exercises: plan.exercises,
                planId: plan.id,
              ),
            ),
          ),
        if (completed && workoutId != null)
          ListTile(
            leading: const Icon(Icons.fitness_center_outlined),
            title: Text(l10n.coachOpenWorkout),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push(
              AppRoutes.workoutDetail(
                workoutId,
                owner: isStudent ? null : plan.athleteId,
              ),
            ),
          ),
        PlanCommentsSection(
          athleteId: plan.athleteId,
          planId: plan.id,
          me: me,
          format: format,
        ),
      ],
    );
  }
}
