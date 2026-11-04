import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/result.dart';
import '../../../core/widgets/failure_snack_bar.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/selectable_option_tile.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'app_settings_controller.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title: l10n.settingsLanguage),
        SelectableOptionTile(
          title: l10n.settingsLanguageSystem,
          selected: selectedCode == null,
          onTap: () => _select(context, ref, null),
        ),
        for (final locale in AppLocalizations.supportedLocales)
          SelectableOptionTile(
            title: lookupAppLocalizations(locale).languageName,
            selected: selectedCode == locale.languageCode,
            onTap: () => _select(context, ref, locale.languageCode),
          ),
      ],
    );
  }

  /// Применяет язык и показывает ошибку с повтором, если сохранить не удалось.
  Future<void> _select(
    BuildContext context,
    WidgetRef ref,
    String? languageCode,
  ) async {
    final result = await ref
        .read(appSettingsProvider.notifier)
        .setLanguageCode(languageCode);
    if (result is Failure<void> && context.mounted) {
      showFailureSnackBar(
        context,
        result.failure,
        onRetry: () => _select(context, ref, languageCode),
      );
    }
  }
}
