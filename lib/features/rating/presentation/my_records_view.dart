import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/theme_context.dart';
import '../../../core/firebase/firestore_failure_mapper.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../settings/presentation/app_settings_controller.dart';
import '../data/record_repository_providers.dart';
import 'record_format.dart';
import 'record_tile.dart';

/// Свои рекорды в любом статусе: на проверке, одобренные и отклонённые.
class MyRecordsView extends ConsumerWidget {
  /// Создаёт список рекордов пользователя [uid].
  const MyRecordsView({super.key, required this.uid});

  final String uid;

  /// Строит загрузку, ошибку, пустой список или рекорды.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final records = ref.watch(myRecordsProvider(uid));
    final format = RecordFormat.of(
      context,
      ref.watch(appSettingsProvider.select((s) => s.weightUnit)),
    );
    return switch (records) {
      AsyncData(:final value) when value.isEmpty => EmptyStateView(
        icon: Icons.videocam_outlined,
        title: l10n.myRecordsEmptyTitle,
        message: l10n.myRecordsEmptyMessage,
      ),
      AsyncData(:final value) => ListView.builder(
        padding: EdgeInsetsDirectional.only(bottom: context.sizes.fabClearance),
        itemCount: value.length,
        itemBuilder: (context, index) =>
            RecordTile(record: value[index], format: format),
      ),
      AsyncError(:final error) => ErrorView(
        title: l10n.myRecordsTab,
        failure: failureFromError(error),
        onRetry: () => ref.invalidate(myRecordsProvider(uid)),
      ),
      _ => const LoadingView(),
    };
  }
}
