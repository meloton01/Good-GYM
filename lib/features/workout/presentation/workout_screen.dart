import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../auth/data/auth_repository_provider.dart';
import '../../profile/data/user_profile_repository_provider.dart';
import '../../profile/domain/user_role.dart';
import 'active_workout_controller.dart';
import 'coach/coach_section.dart';
import 'coach/coach_tab_label.dart';
import 'personal_records_list.dart';
import 'templates_list.dart';
import 'workout_history_list.dart';

/// Корень вкладки: история, шаблоны, рекорды и у тренера или ученика раздел связи.
class WorkoutScreen extends ConsumerWidget {
  /// Создаёт экран вкладки тренировок.
  const WorkoutScreen({super.key});

  /// Строит разделы во вложенных вкладках; четыре вкладки прокручиваются на узком экране.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final uid = ref.watch(authUserProvider).value?.uid;
    final hasActive = ref.watch(
      activeWorkoutProvider.select((workout) => workout != null),
    );
    final profile = uid == null
        ? null
        : ref.watch(userProfileProvider(uid)).value;
    final linked =
        profile != null &&
        (profile.role == UserRole.coach || profile.role == UserRole.student);
    return DefaultTabController(
      key: ValueKey(linked),
      length: linked ? 4 : 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.tabWorkout),
          bottom: TabBar(
            isScrollable: linked,
            tabAlignment: linked ? TabAlignment.start : null,
            tabs: [
              Tab(text: l10n.workoutHistoryTab),
              Tab(text: l10n.workoutTemplatesTab),
              Tab(text: l10n.workoutRecordsTab),
              if (linked) Tab(child: CoachTabLabel(me: profile)),
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
                  if (linked) CoachSection(me: profile),
                ],
              ),
      ),
    );
  }
}
