import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/theme_context.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/errors/result.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/paged_list_view.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../settings/presentation/app_settings_controller.dart';
import '../data/record_repository_providers.dart';
import '../domain/gym_record.dart';
import '../domain/record_badge.dart';
import 'leaderboard_controllers.dart';
import 'rating_labels.dart';
import 'record_format.dart';
import 'record_tile.dart';

/// Значки пользователя; пустой набор, если значков нет.
final recordBadgesProvider = FutureProvider.family<Set<RecordBadge>, String>((
  ref,
  uid,
) async {
  final result = await ref.watch(recordRepositoryProvider).fetchBadges(uid);
  return switch (result) {
    Success(:final value) => value,
    Failure(:final failure) => throw failure,
  };
});

/// Профиль рекордсмена: значки и история одобренных рекордов.
class RecordHolderScreen extends ConsumerWidget {
  /// Создаёт экран пользователя [uid].
  const RecordHolderScreen({super.key, required this.uid});

  final String uid;

  /// Строит значки над историей; скрытая настройками история показывается как скрытая.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(approvedRecordsProvider(uid));
    final controller = ref.read(approvedRecordsProvider(uid).notifier);
    final badges = ref.watch(recordBadgesProvider(uid)).value ?? const {};
    final format = RecordFormat.of(
      context,
      ref.watch(appSettingsProvider.select((s) => s.weightUnit)),
    );
    final nickname = state.items.firstOrNull?.nickname;
    final hidden = state.failure == AppFailure.permissionDenied;
    return Scaffold(
      appBar: AppBar(title: Text(nickname ?? l10n.recordHolderTitle)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (badges.isNotEmpty)
            Padding(
              padding: EdgeInsetsDirectional.all(context.spacing.md),
              child: Wrap(
                spacing: context.spacing.sm,
                runSpacing: context.spacing.sm,
                children: [
                  for (final badge in RecordBadge.values)
                    if (badges.contains(badge))
                      Chip(
                        avatar: const Icon(Icons.military_tech_rounded),
                        label: Text(badge.label(l10n)),
                      ),
                ],
              ),
            ),
          Expanded(
            child: hidden
                ? EmptyStateView(
                    icon: Icons.visibility_off_outlined,
                    title: l10n.recordHistoryHiddenTitle,
                    message: l10n.recordHistoryHiddenMessage,
                  )
                : PagedListView<GymRecord>(
                    state: state,
                    errorTitle: l10n.recordHolderTitle,
                    empty: EmptyStateView(
                      icon: Icons.emoji_events_outlined,
                      title: l10n.recordHistoryEmptyTitle,
                      message: l10n.recordHistoryEmptyMessage,
                    ),
                    onLoadMore: controller.loadMore,
                    onRetry: controller.refresh,
                    itemBuilder: (context, record, index) => RecordTile(
                      record: record,
                      format: format,
                      showStatus: false,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
