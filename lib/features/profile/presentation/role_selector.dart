import 'package:flutter/material.dart';

import '../../../core/widgets/selectable_option_tile.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/user_role.dart';
import 'user_role_labels.dart';

/// Список ролей, доступных для самостоятельного выбора.
class RoleSelector extends StatelessWidget {
  /// Создаёт выбор роли с текущим значением [selected].
  const RoleSelector({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final UserRole? selected;
  final ValueChanged<UserRole> onSelected;

  /// Строит пункт на каждую роль из [UserRole.selectable].
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final role in UserRole.selectable)
          SelectableOptionTile(
            title: role.label(l10n),
            subtitle: role.description(l10n),
            selected: role == selected,
            onTap: () => onSelected(role),
          ),
      ],
    );
  }
}
