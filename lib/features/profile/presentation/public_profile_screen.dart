import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firestore_failure_mapper.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../data/user_profile_repository_provider.dart';
import 'profile_header.dart';

/// Публичный профиль пользователя так, как его видят другие.
class PublicProfileScreen extends ConsumerWidget {
  /// Создаёт экран для пользователя [uid].
  const PublicProfileScreen({super.key, required this.uid});

  final String uid;

  /// Строит профиль; закрытый правилами доступа профиль показывается как скрытый.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final profile = ref.watch(userProfileProvider(uid));
    final hidden = EmptyStateView(
      icon: Icons.visibility_off_outlined,
      title: l10n.profileHiddenTitle,
      message: l10n.profileHiddenMessage,
    );
    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabProfile)),
      body: switch (profile) {
        AsyncData(:final value?) => ListView(
          children: [ProfileHeader(profile: value)],
        ),
        AsyncData() => hidden,
        AsyncError(:final error)
            when error is FirebaseException &&
                error.code == 'permission-denied' =>
          hidden,
        AsyncError(:final error) => ErrorView(
          title: l10n.sessionErrorTitle,
          failure: failureFromError(error),
          onRetry: () => ref.invalidate(userProfileProvider(uid)),
        ),
        _ => const LoadingView(),
      },
    );
  }
}
