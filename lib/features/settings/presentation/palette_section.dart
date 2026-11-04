import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/appearance_colors.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/selectable_option_tile.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/palette_id.dart';
import 'app_settings_controller.dart';
import 'appearance_labels.dart';
import 'color_swatch_dot.dart';
import 'settings_save.dart';

/// Выбор готовой палитры; у каждой показан её акцент.
class PaletteSection extends ConsumerWidget {
  /// Создаёт секцию выбора палитры.
  const PaletteSection({super.key});

  /// Строит список палитр с отметкой текущей.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final selected = ref.watch(
      appSettingsProvider.select((settings) => settings.palette),
    );
    final controller = ref.read(appSettingsProvider.notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title: l10n.appearancePalette),
        for (final palette in PaletteId.values)
          SelectableOptionTile(
            leading: ColorSwatchDot(
              color: AppearanceColors.accentSwatch(
                AppearanceColors.defaultAccent(palette),
              ),
            ),
            title: palette.label(l10n),
            selected: palette == selected,
            onTap: () =>
                saveSetting(context, () => controller.setPalette(palette)),
          ),
      ],
    );
  }
}
