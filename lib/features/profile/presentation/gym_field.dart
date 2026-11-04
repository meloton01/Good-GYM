import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../rating/domain/gym.dart';

/// Поле зала в форме: открывает выбор зала и позволяет убрать выбранный.
class GymField extends StatelessWidget {
  /// Создаёт поле; [onChanged] получает выбранный зал или null при очистке.
  const GymField({super.key, required this.gymName, required this.onChanged});

  final String? gymName;
  final ValueChanged<Gym?> onChanged;

  /// Строит пункт с названием зала и кнопкой очистки.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final name = gymName;
    return ListTile(
      contentPadding: EdgeInsetsDirectional.zero,
      title: Text(l10n.profileGymLabel),
      subtitle: Text(name ?? l10n.profileGymNone),
      trailing: name == null
          ? const Icon(Icons.chevron_right_rounded)
          : IconButton(
              tooltip: l10n.gymRemove,
              icon: const Icon(Icons.close_rounded),
              onPressed: () => onChanged(null),
            ),
      onTap: () async {
        final gym = await context.push<Gym>(AppRoutes.gymPicker);
        if (gym != null) {
          onChanged(gym);
        }
      },
    );
  }
}
