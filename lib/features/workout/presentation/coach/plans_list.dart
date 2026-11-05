import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/theme_context.dart';
import '../../../../core/constants/app_limits.dart';
import '../../../../core/firebase/firestore_failure_mapper.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../data/coach_repository_providers.dart';
import '../../domain/coach_plan.dart';
import '../../domain/plan_status.dart';

/// Планы ученика страницами по 20; [coachId] оставляет только планы этого тренера.
class PlansList extends ConsumerStatefulWidget {
  /// Создаёт список планов ученика [athleteId].
  const PlansList({super.key, required this.athleteId, this.coachId});

  final String athleteId;
  final String? coachId;

  /// Создаёт состояние списка.
  @override
  ConsumerState<PlansList> createState() => _PlansListState();
}

/// Хранит, сколько планов загружать.
class _PlansListState extends ConsumerState<PlansList> {
  int _limit = AppLimits.pageSize;

  /// Строит загрузку, ошибку, пустой список или планы с кнопкой «Показать ещё».
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final coachId = widget.coachId;
    final provider = coachId == null
        ? athletePlansProvider((widget.athleteId, _limit))
        : coachPlansProvider((coachId, widget.athleteId, _limit));
    final plans = ref.watch(provider);
    final items = plans.value;
    if (items == null) {
      return plans.hasError
          ? ErrorView(
              title: l10n.coachPlansTitle,
              failure: failureFromError(plans.error),
              onRetry: () => ref.invalidate(provider),
            )
          : const LoadingView();
    }
    if (items.isEmpty) {
      return EmptyStateView(
        icon: Icons.assignment_outlined,
        title: l10n.coachPlansEmptyTitle,
        message: coachId == null
            ? l10n.coachPlansEmptyStudent
            : l10n.coachPlansEmptyCoach,
      );
    }
    final hasMore = items.length >= _limit;
    return ListView.builder(
      padding: EdgeInsetsDirectional.only(bottom: context.sizes.fabClearance),
      itemCount: items.length + (hasMore ? 1 : 0),
      itemBuilder: (context, index) => index == items.length
          ? TextButton(
              onPressed: () => setState(() => _limit += AppLimits.pageSize),
              child: Text(l10n.actionShowMore),
            )
          : _PlanTile(plan: items[index], showCoach: coachId == null),
    );
  }
}

/// Пункт плана со статусом.
class _PlanTile extends StatelessWidget {
  /// Создаёт пункт плана; [showCoach] добавляет ник тренера.
  const _PlanTile({required this.plan, required this.showCoach});

  final CoachPlan plan;
  final bool showCoach;

  /// Строит название, статус и отметку выполнения.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final status = plan.status == PlanStatus.completed
        ? l10n.planStatusCompleted
        : l10n.planStatusAssigned;
    return ListTile(
      leading: Icon(
        plan.status == PlanStatus.completed
            ? Icons.check_circle_outline_rounded
            : Icons.assignment_outlined,
      ),
      title: Text(plan.title),
      subtitle: Text(
        showCoach
            ? l10n.planStatusWithCoach(status, plan.coachNickname)
            : status,
      ),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () => context.push(AppRoutes.planDetail(plan.athleteId, plan.id)),
    );
  }
}
