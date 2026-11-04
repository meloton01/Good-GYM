import 'package:flutter/material.dart';

import '../../../core/navigation/tab_definition.dart';
import 'settings_screen.dart';

/// Вкладка «Настройки» для реестра вкладок.
final settingsTab = TabDefinition(
  path: '/settings',
  icon: Icons.settings_outlined,
  selectedIcon: Icons.settings_rounded,
  label: (l10n) => l10n.tabSettings,
  builder: (context) => const SettingsScreen(),
);
