import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/selectable_option_tile.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'app_settings_controller.dart';
import 'settings_save.dart';

/// Выбор языка: системный или один из языков, для которых есть ARB-файл.
class LanguageSection extends ConsumerWidget {
  /// Создаёт секцию выбора языка.
  const LanguageSection({super.key});

  /// Строит список языков; название каждого показано на нём самом.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final selectedCode = ref.watch(
      appSettingsProvider.select((settings) => settings.languageCode),
    );
    final controller = ref.read(appSettingsProvider.notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title: l10n.settingsLanguage),
        SelectableOptionTile(
          title: l10n.settingsLanguageSystem,
          selected: selectedCode == null,
          onTap: () =>
              saveSetting(context, () => controller.setLanguageCode(null)),
        ),
        for (final locale in AppLocalizations.supportedLocales)
          SelectableOptionTile(
            title: lookupAppLocalizations(locale).languageName,
            selected: selectedCode == locale.languageCode,
            onTap: () => saveSetting(
              context,
              () => controller.setLanguageCode(locale.languageCode),
            ),
          ),
      ],
    );
  }
}
