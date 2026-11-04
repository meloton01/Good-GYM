import 'package:flutter/material.dart';

import '../../../app/theme/theme_context.dart';
import '../../../core/widgets/user_avatar.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/user_profile.dart';
import 'user_role_labels.dart';

/// Шапка профиля: аватар, ник, роль, зал и описание.
class ProfileHeader extends StatelessWidget {
  /// Создаёт шапку для профиля.
  const ProfileHeader({super.key, required this.profile});

  final UserProfile profile;

  /// Строит шапку; пустое описание и зал не показываются.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final spacing = context.spacing;
    final textTheme = Theme.of(context).textTheme;
    final secondary = textTheme.bodyMedium?.copyWith(
      color: context.colors.textSecondary,
    );
    final gymName = profile.gymName;
    return Padding(
      padding: EdgeInsetsDirectional.all(spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              UserAvatar(nickname: profile.nickname),
              SizedBox(width: spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(profile.nickname, style: textTheme.titleLarge),
                    Text(profile.role.label(l10n), style: secondary),
                    if (gymName != null) Text(gymName, style: secondary),
                  ],
                ),
              ),
            ],
          ),
          if (profile.bio.isNotEmpty) ...[
            SizedBox(height: spacing.md),
            Text(profile.bio, style: textTheme.bodyLarge),
          ],
        ],
      ),
    );
  }
}
