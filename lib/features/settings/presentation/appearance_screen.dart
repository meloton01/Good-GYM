import 'package:flutter/material.dart';

import '../../../app/theme/theme_context.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'accent_section.dart';
import 'appearance_preview.dart';
import 'corner_section.dart';
import 'palette_section.dart';
import 'theme_section.dart';

/// Экран внешнего вида: тема, палитра, акцент, скругления и предпросмотр.
class AppearanceScreen extends StatelessWidget {
  /// Создаёт экран внешнего вида.
  const AppearanceScreen({super.key});

  /// Строит один прокручиваемый список секций; изменения применяются сразу.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).settingsAppearance),
      ),
      body: ListView(
        padding: EdgeInsetsDirectional.only(bottom: context.spacing.lg),
        children: const [
          AppearancePreview(),
          ThemeSection(),
          PaletteSection(),
          AccentSection(),
          CornerSection(),
        ],
      ),
    );
  }
}
