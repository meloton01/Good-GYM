import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../profile/domain/user_profile.dart';
import '../../../profile/domain/user_role.dart';
import '../../data/coach_repository_providers.dart';
import '../../domain/coach_link_status.dart';

/// Подпись вкладки связи с числом входящих приглашений.
class CoachTabLabel extends ConsumerWidget {
  /// Создаёт подпись для тренера или ученика [me].
  const CoachTabLabel({super.key, required this.me});

  final UserProfile me;

  /// Строит подпись и значок, если есть входящие приглашения.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final asCoach = me.role == UserRole.coach;
    final incoming =
        ref
            .watch(coachLinksProvider((me.uid, asCoach)))
            .value
            ?.where(
              (link) =>
                  link.status == CoachLinkStatus.pending &&
                  link.isIncomingFor(me.uid),
            )
            .length ??
        0;
    return Badge(
      isLabelVisible: incoming > 0,
      label: Text('$incoming'),
      child: Text(asCoach ? l10n.coachTabStudents : l10n.coachTabCoach),
    );
  }
}
