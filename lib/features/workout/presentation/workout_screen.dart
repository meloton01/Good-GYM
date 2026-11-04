import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../auth/data/auth_repository_provider.dart';
import 'active_workout_controller.dart';
import 'personal_records_list.dart';
import 'templates_list.dart';
import 'workout_history_list.dart';

/// Корень вкладки: история, шаблоны и личные рекорды; кнопка начала или продолжения тренировки.
class WorkoutScreen extends ConsumerWidget {
  /// Создаёт экран вкладки тренировок.
  const WorkoutScreen({super.key});

  /// Строит три раздела во вложенных вкладках.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final uid = ref.watch(authUserProvider).value?.uid;
    final hasActive = ref.watch(
      activeWorkoutProvider.select((workout) => workout != null),
    );
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.tabWorkout),
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.workoutHistoryTab),
              Tab(text: l10n.workoutTemplatesTab),
              Tab(text: l10n.workoutRecordsTab),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.push(
            hasActive ? AppRoutes.workoutSession : AppRoutes.workoutPlan,
          ),
          icon: Icon(hasActive ? Icons.play_arrow_rounded : Icons.add_rounded),
          label: Text(hasActive ? l10n.workoutResume : l10n.workoutNew),
        ),
        body: uid == null
            ? const LoadingView()
            : TabBarView(
                children: [
                  WorkoutHistoryList(uid: uid),
                  TemplatesList(uid: uid),
                  PersonalRecordsList(uid: uid),
                ],
              ),
      ),
    );
  }
}
