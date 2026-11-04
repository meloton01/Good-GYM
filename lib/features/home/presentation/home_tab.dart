import 'package:flutter/material.dart';

import '../../../core/navigation/tab_definition.dart';
import '../../../core/widgets/unavailable_section_screen.dart';
import '../../../l10n/generated/app_localizations.dart';

/// Вкладка «Главная» для реестра вкладок.
final homeTab = TabDefinition(
  path: '/home',
  icon: Icons.home_outlined,
  selectedIcon: Icons.home_rounded,
  label: (l10n) => l10n.tabHome,
  builder: (context) => UnavailableSectionScreen(
    title: AppLocalizations.of(context).tabHome,
    icon: Icons.home_outlined,
  ),
);
