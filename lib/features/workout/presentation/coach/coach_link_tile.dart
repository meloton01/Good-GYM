import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/theme_context.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/coach_link.dart';
import 'link_actions.dart';

/// Ожидающее приглашение: входящее можно принять или отклонить, своё — отозвать.
class CoachLinkTile extends ConsumerWidget {
  /// Создаёт пункт приглашения [link] для пользователя [uid].
  const CoachLinkTile({super.key, required this.link, required this.uid});

  final CoachLink link;
  final String uid;

  /// Строит ник, пояснение и кнопки под ними, чтобы крупный шрифт не ломал строку.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final spacing = context.spacing;
    final incoming = link.isIncomingFor(uid);
    final asCoach = uid == link.coachId;
    return Padding(
      padding: EdgeInsetsDirectional.only(bottom: spacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            title: Text(link.partnerNickname(uid)),
            subtitle: Text(
              incoming
                  ? (asCoach
                        ? l10n.coachInviteFromStudent
                        : l10n.coachInviteFromCoach)
                  : l10n.coachInviteWaiting,
            ),
          ),
          Padding(
            padding: EdgeInsetsDirectional.symmetric(horizontal: spacing.md),
            child: Wrap(
              spacing: spacing.sm,
              runSpacing: spacing.sm,
              children: incoming
                  ? [
                      FilledButton(
                        onPressed: () => acceptLink(context, ref, link),
                        child: Text(l10n.coachAccept),
                      ),
                      TextButton(
                        onPressed: () => removeLink(context, ref, link),
                        child: Text(l10n.coachDecline),
                      ),
                    ]
                  : [
                      TextButton(
                        onPressed: () => removeLink(context, ref, link),
                        child: Text(l10n.coachCancelInvite),
                      ),
                    ],
            ),
          ),
        ],
      ),
    );
  }
}
