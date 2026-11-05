import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/paged_list_view.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../settings/presentation/app_settings_controller.dart';
import '../domain/gym_record.dart';
import 'leaderboard_controllers.dart';
import 'record_format.dart';
import 'record_tile.dart';

/// Очередь модератора: рекорды на проверке, старые сверху; свои помечены и не проверяются.
class ModerationQueueView extends ConsumerWidget {
  /// Создаёт очередь.
  const ModerationQueueView({super.key});

  /// Строит список с подгрузкой страниц.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(moderationQueueProvider);
    final controller = ref.read(moderationQueueProvider.notifier);
    final format = RecordFormat.of(
      context,
      ref.watch(appSettingsProvider.select((s) => s.weightUnit)),
    );
    return RefreshIndicator(
      onRefresh: () async => controller.refresh(),
      child: PagedListView<GymRecord>(
        state: state,
        errorTitle: l10n.moderationTab,
        empty: EmptyStateView(
          icon: Icons.fact_check_outlined,
          title: l10n.moderationEmptyTitle,
          message: l10n.moderationEmptyMessage,
        ),
        onLoadMore: controller.loadMore,
        onRetry: controller.refresh,
        itemBuilder: (context, record, index) => RecordTile(
          record: record,
          format: format,
          showAuthor: true,
          showStatus: false,
        ),
      ),
    );
  }
}
