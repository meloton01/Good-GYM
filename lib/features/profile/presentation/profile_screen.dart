import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/theme/theme_context.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/errors/result.dart';
import '../../../core/firebase/firestore_failure_mapper.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/failure_snack_bar.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../auth/data/auth_repository_provider.dart';
import '../data/user_profile_repository_provider.dart';
import '../domain/user_profile.dart';
import '../domain/user_role.dart';
import 'body_metrics_section.dart';
import 'profile_header.dart';
import 'role_change_sheet.dart';
import 'user_role_labels.dart';

/// Вкладка профиля: данные, роль, тело и переходы к редактированию.
class ProfileScreen extends ConsumerWidget {
  /// Создаёт экран профиля.
  const ProfileScreen({super.key});

  /// Строит экран по состоянию загрузки профиля текущего пользователя.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final uid = ref.watch(authUserProvider).value?.uid;
    final profile = uid == null
        ? const AsyncValue<UserProfile?>.loading()
        : ref.watch(userProfileProvider(uid));
    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabProfile)),
      body: switch (profile) {
        AsyncData(:final value?) => _ProfileDetails(profile: value),
        AsyncError(:final error) => ErrorView(
          title: l10n.sessionErrorTitle,
          failure: failureFromError(error),
          onRetry: () => ref.invalidate(userProfileProvider),
        ),
        _ => const LoadingView(),
      },
    );
  }
}

/// Список данных профиля с действиями.
class _ProfileDetails extends ConsumerWidget {
  /// Создаёт блок данных профиля.
  const _ProfileDetails({required this.profile});

  final UserProfile profile;

  /// Строит шапку, роль, данные о теле и переходы.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final canChangeRole = UserRole.selectable.contains(profile.role);
    return ListView(
      padding: EdgeInsetsDirectional.only(bottom: context.spacing.lg),
      children: [
        ProfileHeader(profile: profile),
        ListTile(
          leading: const Icon(Icons.edit_outlined),
          title: Text(l10n.profileEdit),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => context.push(AppRoutes.profileEdit),
        ),
        ListTile(
          title: Text(l10n.profileRoleLabel),
          subtitle: Text(profile.role.label(l10n)),
          trailing: canChangeRole
              ? const Icon(Icons.chevron_right_rounded)
              : null,
          onTap: canChangeRole ? () => _changeRole(context, ref) : null,
        ),
        ListTile(
          leading: const Icon(Icons.visibility_outlined),
          title: Text(l10n.profilePublicPreview),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => context.push(AppRoutes.publicProfile(profile.uid)),
        ),
        ListTile(
          leading: const Icon(Icons.palette_outlined),
          title: Text(l10n.settingsAppearance),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => context.push(AppRoutes.appearance),
        ),
        BodyMetricsSection(uid: profile.uid),
      ],
    );
  }

  /// Открывает выбор роли и сохраняет новую роль.
  Future<void> _changeRole(BuildContext context, WidgetRef ref) async {
    final role = await showRoleChangeSheet(context, profile.role);
    if (role == null || role == profile.role || !context.mounted) {
      return;
    }
    final result = await ref
        .read(userProfileRepositoryProvider)
        .updateRole(uid: profile.uid, role: role);
    if (result is Failure<void> && context.mounted) {
      final locked =
          result.failure == AppFailure.permissionDenied &&
          profile.role == UserRole.student;
      showFailureSnackBar(
        context,
        locked ? AppFailure.roleLocked : result.failure,
      );
    }
  }
}
