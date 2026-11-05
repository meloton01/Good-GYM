import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/theme_context.dart';
import '../../../../core/firebase/firestore_failure_mapper.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../profile/domain/user_profile.dart';
import '../../../profile/domain/user_role.dart';
import '../../data/coach_repository_providers.dart';
import '../../domain/coach_limits.dart';
import '../../domain/coach_link.dart';
import '../../domain/coach_link_status.dart';
import 'coach_link_tile.dart';
import 'invite_dialog.dart';
import 'link_actions.dart';

/// Раздел связи во вкладке тренировок: приглашения и ученики тренера или тренер и планы ученика.
class CoachSection extends ConsumerWidget {
  /// Создаёт раздел для тренера или ученика [me].
  const CoachSection({super.key, required this.me});

  final UserProfile me;

  /// Строит загрузку, ошибку или список связей.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final key = (me.uid, me.role == UserRole.coach);
    return switch (ref.watch(coachLinksProvider(key))) {
      AsyncData(:final value) => _buildLinks(context, ref, value),
      AsyncError(:final error) => ErrorView(
        title: me.role == UserRole.coach
            ? l10n.coachTabStudents
            : l10n.coachTabCoach,
        failure: failureFromError(error),
        onRetry: () => ref.invalidate(coachLinksProvider(key)),
      ),
      _ => const LoadingView(),
    };
  }

  /// Строит действия, приглашения и активные связи.
  Widget _buildLinks(
    BuildContext context,
    WidgetRef ref,
    List<CoachLink> links,
  ) {
    final l10n = AppLocalizations.of(context);
    final spacing = context.spacing;
    final asCoach = me.role == UserRole.coach;
    final pending = links.where(
      (link) => link.status == CoachLinkStatus.pending,
    );
    final incoming = pending.where((link) => link.isIncomingFor(me.uid));
    final outgoing = pending.where((link) => !link.isIncomingFor(me.uid));
    final active = links
        .where((link) => link.status == CoachLinkStatus.active)
        .toList();
    final hint = TextStyle(color: context.colors.textSecondary);
    return ListView(
      padding: EdgeInsetsDirectional.only(bottom: context.sizes.fabClearance),
      children: [
        Padding(
          padding: EdgeInsetsDirectional.all(spacing.md),
          child: Wrap(
            spacing: spacing.sm,
            runSpacing: spacing.sm,
            children: [
              FilledButton.tonalIcon(
                icon: const Icon(Icons.person_add_alt_rounded),
                label: Text(
                  asCoach ? l10n.coachInviteStudent : l10n.coachInviteCoach,
                ),
                onPressed: () => showInviteDialog(context, me),
              ),
              OutlinedButton.icon(
                icon: const Icon(Icons.qr_code_rounded),
                label: Text(l10n.coachMyQr),
                onPressed: () => context.push(AppRoutes.coachQr),
              ),
            ],
          ),
        ),
        if (incoming.isNotEmpty) ...[
          SectionHeader(title: l10n.coachInvitesIncoming),
          for (final link in incoming) CoachLinkTile(link: link, uid: me.uid),
        ],
        if (outgoing.isNotEmpty) ...[
          SectionHeader(title: l10n.coachInvitesOutgoing),
          for (final link in outgoing) CoachLinkTile(link: link, uid: me.uid),
        ],
        if (asCoach) ...[
          SectionHeader(
            title: l10n.coachStudentsTitle(
              active.length,
              CoachLimits.maxStudents,
            ),
          ),
          if (active.isEmpty)
            ListTile(title: Text(l10n.coachNoStudents, style: hint)),
          for (final link in active)
            ListTile(
              leading: const Icon(Icons.person_outline_rounded),
              title: Text(link.athleteNickname),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.push(AppRoutes.student(link.athleteId)),
            ),
        ] else ...[
          SectionHeader(title: l10n.coachMyCoach),
          if (active.isEmpty)
            ListTile(title: Text(l10n.coachNoCoach, style: hint)),
          for (final link in active)
            ListTile(
              leading: const Icon(Icons.sports_rounded),
              title: Text(link.coachNickname),
              trailing: IconButton(
                tooltip: l10n.coachEndLink,
                icon: const Icon(Icons.link_off_rounded),
                onPressed: () => endLink(context, ref, link, me.uid),
              ),
            ),
          ListTile(
            leading: const Icon(Icons.assignment_outlined),
            title: Text(l10n.coachPlansTitle),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push(AppRoutes.myPlans),
          ),
        ],
      ],
    );
  }
}
