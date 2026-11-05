import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/paged_list_view.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/blocked_user.dart';
import 'blocked_users_controller.dart';
import 'safety_actions.dart';

/// Список заблокированных пользователей с кнопкой разблокировки.
class BlockedUsersScreen extends ConsumerWidget {
  /// Создаёт экран заблокированных.
  const BlockedUsersScreen({super.key});

  /// Строит список страницами, пустое состояние и ошибку.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(blockedUsersProvider);
    final controller = ref.read(blockedUsersProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.privacyBlockedUsers)),
      body: PagedListView<BlockedUser>(
        state: state,
        errorTitle: l10n.privacyBlockedUsers,
        empty: EmptyStateView(
          icon: Icons.block_rounded,
          title: l10n.blockedUsersEmptyTitle,
          message: l10n.blockedUsersEmptyMessage,
        ),
        onLoadMore: controller.loadMore,
        onRetry: controller.refresh,
        itemBuilder: (context, user, index) => ListTile(
          title: Text(user.nickname),
          trailing: TextButton(
            onPressed: () async {
              if (await unblockUser(context, ref, user.uid)) {
                controller.refresh();
              }
            },
            child: Text(l10n.unblockUserAction),
          ),
        ),
      ),
    );
  }
}
