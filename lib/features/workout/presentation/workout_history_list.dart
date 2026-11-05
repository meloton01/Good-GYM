import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/theme/theme_context.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../auth/data/auth_repository_provider.dart';
import '../../settings/presentation/app_settings_controller.dart';
import 'workout_format.dart';
import 'workout_history_controller.dart';

/// История завершённых тренировок с подгрузкой при прокрутке.
class WorkoutHistoryList extends ConsumerWidget {
  /// Создаёт список истории пользователя [uid].
  const WorkoutHistoryList({super.key, required this.uid});

  final String uid;

  /// Строит загрузку, ошибку, пустую историю или список.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(workoutHistoryProvider(uid));
    final controller = ref.read(workoutHistoryProvider(uid).notifier);
    final failure = state.failure;
    if (state.items.isEmpty) {
      if (failure != null) {
        return ErrorView(
          title: l10n.workoutHistoryTab,
          failure: failure,
          onRetry: controller.refresh,
        );
      }
      return state.loading
          ? const LoadingView()
          : EmptyStateView(
              icon: Icons.history_rounded,
              title: l10n.workoutHistoryEmptyTitle,
              message: l10n.workoutHistoryEmptyMessage,
            );
    }
    final format = WorkoutFormat.of(
      context,
      ref.watch(appSettingsProvider.select((s) => s.weightUnit)),
    );
    final showFooter = state.hasMore || failure != null;
    final owner = ref.watch(authUserProvider).value?.uid == uid ? null : uid;
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        final metrics = notification.metrics;
        if (failure == null &&
            metrics.extentAfter < metrics.viewportDimension / 2) {
          controller.loadMore();
        }
        return false;
      },
      child: ListView.builder(
        padding: EdgeInsetsDirectional.only(bottom: context.sizes.fabClearance),
        itemCount: state.items.length + (showFooter ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.items.length) {
            return failure == null
                ? Padding(
                    padding: EdgeInsetsDirectional.all(context.spacing.md),
                    child: const LoadingView(),
                  )
                : TextButton(
                    onPressed: controller.loadMore,
                    child: Text(l10n.actionRetry),
                  );
          }
          final workout = state.items[index];
          return ListTile(
            title: Text(workout.title),
            subtitle: Text(
              '${format.dateTime(workout.startedAt)}\n${format.summary(workout)}',
            ),
            isThreeLine: true,
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () =>
                context.push(AppRoutes.workoutDetail(workout.id, owner: owner)),
          );
        },
      ),
    );
  }
}
