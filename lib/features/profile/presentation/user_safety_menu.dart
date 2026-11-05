import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../auth/data/auth_repository_provider.dart';
import '../data/safety_repository_provider.dart';
import '../domain/blocked_user.dart';
import 'safety_actions.dart';

/// Пункты меню жалоб и блокировки.
enum _SafetyAction { reportRecord, reportUser, block, unblock }

/// Меню в шапке экрана чужого пользователя или рекорда: жалоба и блокировка.
class UserSafetyMenu extends ConsumerWidget {
  /// Создаёт меню для пользователя [uid]; с [recordId] можно пожаловаться на рекорд.
  const UserSafetyMenu({
    super.key,
    required this.uid,
    required this.nickname,
    this.recordId,
  });

  final String uid;
  final String nickname;
  final String? recordId;

  /// Строит меню; для своего профиля и рекорда меню нет.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final me = ref.watch(authUserProvider.select((user) => user.value?.uid));
    if (me == null || me == uid) {
      return const SizedBox.shrink();
    }
    final blocked = ref.watch(isBlockedProvider(uid)).value ?? false;
    return PopupMenuButton<_SafetyAction>(
      onSelected: (action) => _run(context, ref, action),
      itemBuilder: (context) => [
        if (recordId != null)
          PopupMenuItem(
            value: _SafetyAction.reportRecord,
            child: Text(l10n.reportRecordAction),
          ),
        PopupMenuItem(
          value: _SafetyAction.reportUser,
          child: Text(l10n.reportUserAction),
        ),
        PopupMenuItem(
          value: blocked ? _SafetyAction.unblock : _SafetyAction.block,
          child: Text(blocked ? l10n.unblockUserAction : l10n.blockUserAction),
        ),
      ],
    );
  }

  /// Выполняет выбранный пункт меню.
  Future<void> _run(
    BuildContext context,
    WidgetRef ref,
    _SafetyAction action,
  ) async {
    switch (action) {
      case _SafetyAction.reportRecord:
        await reportContent(context, ref, targetUid: uid, recordId: recordId);
      case _SafetyAction.reportUser:
        await reportContent(context, ref, targetUid: uid);
      case _SafetyAction.block:
        await blockUser(
          context,
          ref,
          BlockedUser(uid: uid, nickname: nickname),
        );
      case _SafetyAction.unblock:
        await unblockUser(context, ref, uid);
    }
  }
}
