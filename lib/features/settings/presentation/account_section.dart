import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/theme/theme_context.dart';
import '../../../core/errors/result.dart';
import '../../../core/widgets/failure_snack_bar.dart';
import '../../../core/widgets/section_header.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../auth/data/auth_repository_provider.dart';
import 'account_deletion.dart';
import 'data_export.dart';
import 'delete_account_dialog.dart';

/// Секция аккаунта: email, смена email и пароля, экспорт, выход и удаление.
class AccountSection extends ConsumerStatefulWidget {
  /// Создаёт секцию аккаунта.
  const AccountSection({super.key});

  /// Создаёт состояние секции.
  @override
  ConsumerState<AccountSection> createState() => _AccountSectionState();
}

/// Хранит, какое долгое действие сейчас выполняется.
class _AccountSectionState extends ConsumerState<AccountSection> {
  bool _exporting = false;
  bool _deleting = false;

  /// Строит пункты аккаунта; смена email и пароля только для входа по паролю.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(authUserProvider).value;
    final email = user?.email;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title: l10n.settingsAccount),
        if (email != null)
          ListTile(
            leading: const Icon(Icons.mail_outline_rounded),
            title: Text(email),
          ),
        if (user?.usesPassword ?? false) ...[
          ListTile(
            title: Text(l10n.accountChangeEmail),
            onTap: () => context.push(AppRoutes.changeEmail),
          ),
          ListTile(
            title: Text(l10n.accountChangePassword),
            onTap: () => context.push(AppRoutes.changePassword),
          ),
        ],
        ListTile(
          title: Text(l10n.accountExportData),
          trailing: _exporting ? const _TileProgress() : null,
          onTap: _exporting ? null : _export,
        ),
        ListTile(
          leading: const Icon(Icons.logout_rounded),
          title: Text(l10n.authSignOut),
          onTap: _signOut,
        ),
        ListTile(
          title: Text(
            l10n.accountDelete,
            style: TextStyle(color: context.colors.error),
          ),
          trailing: _deleting ? const _TileProgress() : null,
          onTap: _deleting ? null : _delete,
        ),
      ],
    );
  }

  /// Выгружает данные в JSON-файл и сообщает, куда он сохранён.
  Future<void> _export() async {
    setState(() => _exporting = true);
    await exportUserData(context, ref);
    if (mounted) {
      setState(() => _exporting = false);
    }
  }

  /// Удаляет аккаунт после подтверждения; роутер затем откроет вход.
  Future<void> _delete() async {
    final usesPassword = ref.read(authUserProvider).value?.usesPassword;
    final confirmation = await showDeleteAccountDialog(
      context,
      askPassword: usesPassword ?? false,
    );
    if (confirmation == null || !mounted) {
      return;
    }
    setState(() => _deleting = true);
    await deleteAccount(context, ref, confirmation);
    if (mounted) {
      setState(() => _deleting = false);
    }
  }

  /// Выходит из аккаунта; роутер откроет экран входа.
  Future<void> _signOut() async {
    final result = await ref.read(authRepositoryProvider).signOut();
    if (result is Failure<void> && mounted) {
      showFailureSnackBar(context, result.failure, onRetry: _signOut);
    }
  }
}

/// Индикатор долгого действия справа в пункте списка.
class _TileProgress extends StatelessWidget {
  /// Создаёт индикатор.
  const _TileProgress();

  /// Строит маленький круговой индикатор.
  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: context.sizes.iconLarge / 2,
      child: CircularProgressIndicator(
        strokeWidth: context.sizes.progressStrokeWidth,
        semanticsLabel: AppLocalizations.of(context).loadingLabel,
      ),
    );
  }
}
