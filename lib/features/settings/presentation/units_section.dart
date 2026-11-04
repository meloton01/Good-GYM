import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/units/length_unit.dart';
import '../../../core/units/unit_labels.dart';
import '../../../core/units/weight_unit.dart';
import '../../../core/widgets/option_sheet.dart';
import '../../../core/widgets/section_header.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'app_settings_controller.dart';
import 'settings_save.dart';

/// Выбор единиц веса и роста.
class UnitsSection extends ConsumerWidget {
  /// Создаёт секцию единиц.
  const UnitsSection({super.key});

  /// Строит два пункта с текущими единицами; нажатие открывает выбор.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final (weightUnit, lengthUnit) = ref.watch(
      appSettingsProvider.select((s) => (s.weightUnit, s.lengthUnit)),
    );
    final controller = ref.read(appSettingsProvider.notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title: l10n.settingsUnits),
        ListTile(
          title: Text(l10n.unitWeight),
          subtitle: Text(weightUnit.label(l10n)),
          onTap: () async {
            final unit = await showOptionSheet(
              context,
              title: l10n.unitWeight,
              options: WeightUnit.values,
              selected: weightUnit,
              label: (unit) => unit.label(l10n),
            );
            if (unit != null && context.mounted) {
              await saveSetting(context, () => controller.setWeightUnit(unit));
            }
          },
        ),
        ListTile(
          title: Text(l10n.unitLength),
          subtitle: Text(lengthUnit.label(l10n)),
          onTap: () async {
            final unit = await showOptionSheet(
              context,
              title: l10n.unitLength,
              options: LengthUnit.values,
              selected: lengthUnit,
              label: (unit) => unit.label(l10n),
            );
            if (unit != null && context.mounted) {
              await saveSetting(context, () => controller.setLengthUnit(unit));
            }
          },
        ),
      ],
    );
  }
}
