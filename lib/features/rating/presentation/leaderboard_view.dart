import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/theme/theme_context.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/paged_list_view.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../settings/presentation/app_settings_controller.dart';
import '../domain/leaderboard_entry.dart';
import '../domain/leaderboard_metric.dart';
import '../domain/leaderboard_query.dart';
import '../domain/weight_class.dart';
import 'leaderboard_controllers.dart';
import 'leaderboard_filter_bar.dart';
import 'rating_labels.dart';
import 'record_format.dart';

/// Таблица рейтинга с фильтрами; «мой зал» берётся из профиля пользователя.
class LeaderboardView extends ConsumerWidget {
  /// Создаёт таблицу для пользователя [uid] из зала [gymId].
  const LeaderboardView({super.key, required this.uid, required this.gymId});

  final String uid;
  final String? gymId;

  /// Строит фильтры и список или подсказку выбрать зал.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final filter = ref.watch(leaderboardFilterProvider);
    final gym = gymId;
    final needsGym = filter.gymId != null && gym == null;
    return Column(
      children: [
        LeaderboardFilterBar(gymId: gym),
        Expanded(
          child: needsGym
              ? EmptyStateView(
                  icon: Icons.location_city_rounded,
                  title: l10n.ratingNoGymTitle,
                  message: l10n.ratingNoGymMessage,
                )
              : _LeaderboardList(
                  uid: uid,
                  query: filter.gymId == null
                      ? filter
                      : filter.copyWith(gymId: gym),
                ),
        ),
      ],
    );
  }
}

/// Строки таблицы по готовому фильтру.
class _LeaderboardList extends ConsumerWidget {
  /// Создаёт список для фильтра [query].
  const _LeaderboardList({required this.uid, required this.query});

  final String uid;
  final LeaderboardQuery query;

  /// Строит список с местом, ником и результатом.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(leaderboardProvider(query));
    final controller = ref.read(leaderboardProvider(query).notifier);
    final format = RecordFormat.of(
      context,
      ref.watch(appSettingsProvider.select((s) => s.weightUnit)),
    );
    return PagedListView<LeaderboardEntry>(
      state: state,
      errorTitle: l10n.ratingTableTab,
      empty: EmptyStateView(
        icon: Icons.leaderboard_outlined,
        title: l10n.ratingEmptyTitle,
        message: l10n.ratingEmptyMessage,
      ),
      onLoadMore: controller.loadMore,
      onRetry: controller.refresh,
      itemBuilder: (context, entry, index) {
        final byWeight = query.metric == LeaderboardMetric.maxWeight;
        final weightClass = WeightClass.fromId(entry.weightClassId);
        final details = [
          if (query.gymId == null) entry.gymName,
          ?weightClass?.label(l10n),
        ];
        final rank = index + 1;
        return ListTile(
          selected: entry.uid == uid,
          leading: SizedBox(
            width: context.sizes.minTouchTarget,
            child: Center(
              child: Text(
                '$rank',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: rank <= 3 ? context.colors.accentContent : null,
                ),
              ),
            ),
          ),
          title: Text(entry.nickname),
          subtitle: details.isEmpty ? null : Text(details.join(' · ')),
          trailing: Text(
            format.weight(byWeight ? entry.bestWeightKg : entry.bestE1rmKg),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          onTap: () => context.push(
            AppRoutes.recordDetail(
              byWeight ? entry.bestWeightRecordId : entry.bestE1rmRecordId,
            ),
          ),
        );
      },
    );
  }
}
