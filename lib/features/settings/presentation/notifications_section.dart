import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/section_header.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/notification_type.dart';
import 'app_settings_controller.dart';
import 'appearance_labels.dart';
import 'settings_save.dart';

/// Включение и выключение уведомлений по типам.
class NotificationsSection extends ConsumerWidget {
  /// Создаёт секцию уведомлений.
  const NotificationsSection({super.key});

  /// Строит переключатель на каждый тип уведомлений.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(appSettingsProvider);
    final controller = ref.read(appSettingsProvider.notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title: l10n.settingsNotifications),
        for (final type in NotificationType.values)
          SwitchListTile(
            title: Text(type.label(l10n)),
            value: settings.isNotificationEnabled(type),
            onChanged: (enabled) => saveSetting(
              context,
              () => controller.setNotificationEnabled(type, enabled: enabled),
            ),
          ),
      ],
    );
  }
}
