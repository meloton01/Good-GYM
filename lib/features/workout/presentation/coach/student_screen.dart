import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/firebase/firestore_failure_mapper.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../auth/data/auth_repository_provider.dart';
import '../../data/coach_repository_providers.dart';
import '../../domain/coach_link_status.dart';
import '../personal_records_list.dart';
import '../workout_history_list.dart';
import 'link_actions.dart';
import 'plans_list.dart';

/// Ученик глазами тренера: планы, тренировки и рекорды, пока связь активна.
class StudentScreen extends ConsumerWidget {
  /// Создаёт экран ученика [athleteId].
  const StudentScreen({super.key, required this.athleteId});

  final String athleteId;

  /// Строит загрузку, ошибку, неактивную связь или вкладки ученика.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final me = ref.watch(authUserProvider).value?.uid ?? '';
    final links = ref.watch(coachLinksProvider((me, true)));
    final link = links.value
        ?.where(
          (item) =>
              item.athleteId == athleteId &&
              item.status == CoachLinkStatus.active,
        )
        .firstOrNull;
    if (link == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.coachStudentTitle)),
        body: switch (links) {
          AsyncError(:final error) => ErrorView(
            title: l10n.coachStudentTitle,
            failure: failureFromError(error),
            onRetry: () => ref.invalidate(coachLinksProvider((me, true))),
          ),
          AsyncData() => EmptyStateView(
            icon: Icons.link_off_rounded,
            title: l10n.coachStudentTitle,
            message: l10n.coachLinkInactive,
          ),
          _ => const LoadingView(),
        },
      );
    }
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(link.athleteNickname),
          actions: [
            IconButton(
              tooltip: l10n.coachEndLink,
              icon: const Icon(Icons.link_off_rounded),
              onPressed: () async {
                if (await endLink(context, ref, link, me) && context.mounted) {
                  context.pop();
                }
              },
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.coachPlansTitle),
              Tab(text: l10n.workoutHistoryTab),
              Tab(text: l10n.workoutRecordsTab),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.push(AppRoutes.planEditor(athleteId)),
          icon: const Icon(Icons.add_rounded),
          label: Text(l10n.coachNewPlan),
        ),
        body: TabBarView(
          children: [
            PlansList(athleteId: athleteId, coachId: me),
            WorkoutHistoryList(uid: athleteId),
            PersonalRecordsList(uid: athleteId),
          ],
        ),
      ),
    );
  }
}
