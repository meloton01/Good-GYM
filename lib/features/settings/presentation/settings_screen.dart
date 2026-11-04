import 'package:flutter/material.dart';

import '../../../app/theme/theme_context.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'language_section.dart';
import 'theme_section.dart';

/// Экран настроек: язык и тема.
class SettingsScreen extends StatelessWidget {
  /// Создаёт экран настроек.
  const SettingsScreen({super.key});

  /// Строит один прокручиваемый список секций.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).tabSettings)),
      body: ListView(
        padding: EdgeInsetsDirectional.only(bottom: context.spacing.lg),
        children: const [LanguageSection(), ThemeSection()],
      ),
    );
  }
}
