import 'package:flutter/material.dart';

import '../../../core/navigation/tab_definition.dart';
import '../../../core/widgets/unavailable_section_screen.dart';
import '../../../l10n/generated/app_localizations.dart';

/// Вкладка «Профиль» для реестра вкладок.
final profileTab = TabDefinition(
  path: '/profile',
  icon: Icons.person_outline_rounded,
  selectedIcon: Icons.person_rounded,
  label: (l10n) => l10n.tabProfile,
  builder: (context) => UnavailableSectionScreen(
    title: AppLocalizations.of(context).tabProfile,
    icon: Icons.person_outline_rounded,
  ),
);
