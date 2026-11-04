import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/selectable_option_tile.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/corner_style.dart';
import 'app_settings_controller.dart';
import 'appearance_labels.dart';
import 'settings_save.dart';

/// Выбор стиля скруглений.
class CornerSection extends ConsumerWidget {
  /// Создаёт секцию выбора скруглений.
  const CornerSection({super.key});

  /// Строит список стилей с отметкой текущего.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final selected = ref.watch(
      appSettingsProvider.select((settings) => settings.cornerStyle),
    );
    final controller = ref.read(appSettingsProvider.notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title: l10n.appearanceCorners),
        for (final style in CornerStyle.values)
          SelectableOptionTile(
            title: style.label(l10n),
            selected: style == selected,
            onTap: () =>
                saveSetting(context, () => controller.setCornerStyle(style)),
          ),
      ],
    );
  }
}
