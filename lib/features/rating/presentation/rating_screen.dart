import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../auth/data/auth_repository_provider.dart';
import '../../profile/data/user_profile_repository_provider.dart';
import '../../profile/domain/user_role.dart';
import 'leaderboard_view.dart';
import 'moderation_queue_view.dart';
import 'my_records_view.dart';

/// Корень вкладки: таблица, свои рекорды и у модератора очередь проверки.
class RatingScreen extends ConsumerWidget {
  /// Создаёт экран вкладки рейтинга.
  const RatingScreen({super.key});

  /// Строит вложенные вкладки и кнопку подачи рекорда.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final uid = ref.watch(authUserProvider).value?.uid;
    final profile = uid == null
        ? null
        : ref.watch(userProfileProvider(uid)).value;
    if (uid == null || profile == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.tabRating)),
        body: const LoadingView(),
      );
    }
    final moderator = profile.role == UserRole.moderator;
    return DefaultTabController(
      key: ValueKey(moderator),
      length: moderator ? 3 : 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.tabRating),
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.ratingTableTab),
              Tab(text: l10n.myRecordsTab),
              if (moderator) Tab(text: l10n.moderationTab),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.push(AppRoutes.submitRecord),
          icon: const Icon(Icons.videocam_rounded),
          label: Text(l10n.submitRecordAction),
        ),
        body: TabBarView(
          children: [
            LeaderboardView(uid: uid, gymId: profile.gymId),
            MyRecordsView(uid: uid),
            if (moderator) const ModerationQueueView(),
          ],
        ),
      ),
    );
  }
}
