import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/theme/theme_context.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/firebase/firestore_failure_mapper.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../auth/data/auth_repository_provider.dart';
import '../../profile/data/user_profile_repository_provider.dart';
import '../../profile/domain/user_role.dart';
import '../../profile/presentation/user_safety_menu.dart';
import '../../settings/presentation/app_settings_controller.dart';
import '../data/record_repository_providers.dart';
import '../domain/gym_record.dart';
import '../domain/record_status.dart';
import 'record_actions.dart';
import 'record_criteria.dart';
import 'record_facts.dart';
import 'record_format.dart';
import 'record_review_buttons.dart';
import 'record_video_player.dart';

/// Рекорд: автор, результат, статус, видео и действия автора или модератора.
class RecordDetailScreen extends ConsumerWidget {
  /// Создаёт экран рекорда [recordId].
  const RecordDetailScreen({super.key, required this.recordId});

  final String recordId;

  /// Строит загрузку, ошибку, скрытый рекорд или его данные.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final record = ref.watch(recordProvider(recordId));
    final hidden = EmptyStateView(
      icon: Icons.visibility_off_outlined,
      title: l10n.recordHiddenTitle,
      message: l10n.recordHiddenMessage,
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.recordTitle),
        actions: [
          if (record.value case final value?)
            UserSafetyMenu(
              uid: value.uid,
              nickname: value.nickname,
              recordId: value.id,
            ),
        ],
      ),
      body: switch (record) {
        AsyncData(:final value?) => _RecordBody(record: value),
        AsyncData() => hidden,
        AsyncError(:final error)
            when failureFromError(error) == AppFailure.permissionDenied =>
          hidden,
        AsyncError(:final error) => ErrorView(
          title: l10n.recordTitle,
          failure: failureFromError(error),
          onRetry: () => ref.invalidate(recordProvider(recordId)),
        ),
        _ => const LoadingView(),
      },
    );
  }
}

/// Содержимое рекорда.
class _RecordBody extends ConsumerWidget {
  /// Создаёт содержимое для [record].
  const _RecordBody({required this.record});

  final GymRecord record;

  /// Строит автора, факты, видео и доступные действия.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final uid = ref.watch(authUserProvider).value?.uid;
    final role = uid == null
        ? null
        : ref.watch(userProfileProvider(uid).select((p) => p.value?.role));
    final own = record.uid == uid;
    final reviewable =
        role == UserRole.moderator &&
        !own &&
        record.status == RecordStatus.pending;
    final format = RecordFormat.of(
      context,
      ref.watch(appSettingsProvider.select((s) => s.weightUnit)),
    );
    return ListView(
      padding: EdgeInsetsDirectional.only(bottom: context.spacing.xl),
      children: [
        ListTile(
          leading: const Icon(Icons.person_outline_rounded),
          title: Text(record.nickname),
          subtitle: Text(record.gymName),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () =>
              context.push(AppRoutes.recordHolder(record.uid, record.nickname)),
        ),
        RecordFacts(record: record, format: format),
        RecordVideoPlayer(recordId: record.id),
        if (own && record.canAppeal)
          Padding(
            padding: EdgeInsetsDirectional.all(context.spacing.md),
            child: FilledButton(
              onPressed: () => appealRecord(context, ref, record.id),
              child: Text(l10n.appealRecordAction),
            ),
          ),
        if (reviewable) ...[
          const RecordCriteria(),
          RecordReviewButtons(recordId: record.id),
        ],
        if (role == UserRole.moderator &&
            own &&
            record.status == RecordStatus.pending)
          Padding(
            padding: EdgeInsetsDirectional.all(context.spacing.md),
            child: Text(l10n.moderationOwnRecord),
          ),
      ],
    );
  }
}
