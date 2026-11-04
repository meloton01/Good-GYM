import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firestore_failure_mapper.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../auth/data/auth_repository_provider.dart';
import '../data/user_profile_repository_provider.dart';
import 'edit_profile_form.dart';

/// Экран редактирования профиля; ждёт загрузки профиля и данных о теле.
class EditProfileScreen extends ConsumerWidget {
  /// Создаёт экран редактирования.
  const EditProfileScreen({super.key});

  /// Строит загрузку, ошибку или форму с текущими данными.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final uid = ref.watch(authUserProvider).value?.uid;
    if (uid == null) {
      return const Scaffold(body: LoadingView());
    }
    final profile = ref.watch(userProfileProvider(uid));
    final body = ref.watch(bodyMetricsProvider(uid));
    final error = profile.error ?? body.error;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileEdit)),
      body: switch ((profile.value, body.value)) {
        _ when error != null => ErrorView(
          title: l10n.sessionErrorTitle,
          failure: failureFromError(error),
          onRetry: () => ref
            ..invalidate(userProfileProvider(uid))
            ..invalidate(bodyMetricsProvider(uid)),
        ),
        (final current?, final metrics?) => EditProfileForm(
          profile: current,
          metrics: metrics,
        ),
        _ => const LoadingView(),
      },
    );
  }
}
