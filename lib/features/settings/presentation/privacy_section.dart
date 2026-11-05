import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../core/errors/result.dart';
import '../../../core/widgets/failure_snack_bar.dart';
import '../../../core/widgets/option_sheet.dart';
import '../../../core/widgets/section_header.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../auth/data/auth_repository_provider.dart';
import '../../profile/data/user_profile_repository_provider.dart';
import '../../profile/domain/profile_visibility.dart';
import '../../profile/domain/user_profile.dart';
import 'profile_visibility_labels.dart';

/// Секция приватности: кто видит профиль и рекорды, заблокированные; встраивается в настройки.
class PrivacySection extends ConsumerWidget {
  /// Создаёт секцию приватности.
  const PrivacySection({super.key});

  /// Строит пункты видимости и заблокированных; пока профиль не загружен, секции нет.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final uid = ref.watch(authUserProvider).value?.uid;
    final profile = uid == null
        ? null
        : ref.watch(userProfileProvider(uid)).value;
    if (profile == null) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title: l10n.settingsPrivacy),
        _tile(
          context,
          ref,
          title: l10n.privacyProfileVisibility,
          value: profile.profileVisibility,
          apply: (visibility) =>
              profile.copyWith(profileVisibility: visibility),
        ),
        _tile(
          context,
          ref,
          title: l10n.privacyRecordsVisibility,
          value: profile.recordsVisibility,
          apply: (visibility) =>
              profile.copyWith(recordsVisibility: visibility),
        ),
        ListTile(
          title: Text(l10n.privacyBlockedUsers),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => context.push(AppRoutes.blockedUsers),
        ),
      ],
    );
  }

  /// Пункт видимости, который открывает выбор и сохраняет профиль.
  Widget _tile(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required ProfileVisibility value,
    required UserProfile Function(ProfileVisibility visibility) apply,
  }) {
    final l10n = AppLocalizations.of(context);
    return ListTile(
      title: Text(title),
      subtitle: Text(value.label(l10n)),
      onTap: () async {
        final selected = await showOptionSheet(
          context,
          title: title,
          options: ProfileVisibility.values,
          selected: value,
          label: (option) => option.label(l10n),
        );
        if (selected == null || selected == value) {
          return;
        }
        final result = await ref
            .read(userProfileRepositoryProvider)
            .updateProfile(apply(selected));
        if (result is Failure<void> && context.mounted) {
          showFailureSnackBar(context, result.failure);
        }
      },
    );
  }
}
