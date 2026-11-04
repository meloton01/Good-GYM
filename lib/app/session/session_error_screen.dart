import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/app_failure.dart';
import '../../core/widgets/error_view.dart';
import '../../features/auth/data/auth_repository_provider.dart';
import '../../features/profile/data/user_profile_repository_provider.dart';
import '../../l10n/generated/app_localizations.dart';
import 'session_provider.dart';
import 'session_state.dart';

/// Экран ошибки загрузки сессии с повтором.
class SessionErrorScreen extends ConsumerWidget {
  /// Создаёт экран ошибки сессии.
  const SessionErrorScreen({super.key});

  /// Строит ErrorView с причиной из состояния сессии.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final failure = session is SessionError
        ? session.failure
        : AppFailure.unknown;
    return Scaffold(
      body: SafeArea(
        child: ErrorView(
          title: AppLocalizations.of(context).sessionErrorTitle,
          failure: failure,
          onRetry: () => _retry(ref),
        ),
      ),
    );
  }

  /// Переподписывается на учётную запись и профиль.
  void _retry(WidgetRef ref) {
    ref
      ..invalidate(authUserProvider)
      ..invalidate(userProfileProvider);
  }
}
