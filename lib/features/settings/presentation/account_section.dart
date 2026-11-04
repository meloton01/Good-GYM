import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/result.dart';
import '../../../core/widgets/failure_snack_bar.dart';
import '../../../core/widgets/section_header.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../auth/data/auth_repository_provider.dart';

/// Секция аккаунта: email и выход.
class AccountSection extends ConsumerWidget {
  /// Создаёт секцию аккаунта.
  const AccountSection({super.key});

  /// Строит email текущей учётной записи и пункт выхода.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final email = ref.watch(
      authUserProvider.select((user) => user.value?.email),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title: l10n.settingsAccount),
        if (email != null)
          ListTile(
            leading: const Icon(Icons.mail_outline_rounded),
            title: Text(email),
          ),
        ListTile(
          leading: const Icon(Icons.logout_rounded),
          title: Text(l10n.authSignOut),
          onTap: () => _signOut(context, ref),
        ),
      ],
    );
  }

  /// Выходит из аккаунта; роутер откроет экран входа.
  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final result = await ref.read(authRepositoryProvider).signOut();
    if (result is Failure<void> && context.mounted) {
      showFailureSnackBar(
        context,
        result.failure,
        onRetry: () => _signOut(context, ref),
      );
    }
  }
}
