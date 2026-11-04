import 'package:flutter/material.dart';

import '../../../app/theme/theme_context.dart';
import '../../../core/widgets/section_header.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/user_role.dart';
import 'role_selector.dart';

/// Открывает нижнюю панель выбора роли и возвращает выбранную роль или null.
Future<UserRole?> showRoleChangeSheet(BuildContext context, UserRole current) {
  return showModalBottomSheet<UserRole>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsetsDirectional.only(bottom: context.spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionHeader(title: AppLocalizations.of(context).profileRoleLabel),
            RoleSelector(
              selected: current,
              onSelected: (role) => Navigator.of(context).pop(role),
            ),
          ],
        ),
      ),
    ),
  );
}
