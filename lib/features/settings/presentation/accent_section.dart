import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/appearance_colors.dart';
import '../../../app/theme/theme_context.dart';
import '../../../core/widgets/section_header.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/accent_id.dart';
import 'app_settings_controller.dart';
import 'appearance_labels.dart';
import 'color_swatch_dot.dart';
import 'settings_save.dart';

/// Выбор акцентного цвета поверх палитры: ряд круглых образцов.
class AccentSection extends ConsumerWidget {
  /// Создаёт секцию выбора акцента.
  const AccentSection({super.key});

  /// Строит образцы с зоной нажатия 48 dp и подписью для скринридера.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(appSettingsProvider);
    final selected =
        settings.accent ?? AppearanceColors.defaultAccent(settings.palette);
    final controller = ref.read(appSettingsProvider.notifier);
    final spacing = context.spacing;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title: l10n.appearanceAccent),
        Padding(
          padding: EdgeInsetsDirectional.symmetric(horizontal: spacing.sm),
          child: Wrap(
            children: [
              for (final accent in AccentId.values)
                Semantics(
                  label: accent.label(l10n),
                  selected: accent == selected,
                  button: true,
                  child: InkResponse(
                    onTap: () => saveSetting(
                      context,
                      () => controller.setAccent(accent),
                    ),
                    child: SizedBox.square(
                      dimension: context.sizes.minTouchTarget,
                      child: Center(
                        child: ColorSwatchDot(
                          color: AppearanceColors.accentSwatch(accent),
                          selected: accent == selected,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
