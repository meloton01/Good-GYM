import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/selectable_option_tile.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/app_theme_mode.dart';
import 'app_settings_controller.dart';
import 'settings_save.dart';

/// Выбор режима темы: системная, светлая, тёмная.
class ThemeSection extends ConsumerWidget {
  /// Создаёт секцию выбора темы.
  const ThemeSection({super.key});

  /// Строит список режимов темы с отметкой текущего.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final selectedMode = ref.watch(
      appSettingsProvider.select((settings) => settings.themeMode),
    );
    final controller = ref.read(appSettingsProvider.notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title: l10n.settingsTheme),
        for (final mode in AppThemeMode.values)
          SelectableOptionTile(
            title: _label(l10n, mode),
            selected: selectedMode == mode,
            onTap: () =>
                saveSetting(context, () => controller.setThemeMode(mode)),
          ),
      ],
    );
  }

  /// Возвращает подпись режима темы на языке интерфейса.
  String _label(AppLocalizations l10n, AppThemeMode mode) {
    return switch (mode) {
      AppThemeMode.system => l10n.themeSystem,
      AppThemeMode.light => l10n.themeLight,
      AppThemeMode.dark => l10n.themeDark,
    };
  }
}
