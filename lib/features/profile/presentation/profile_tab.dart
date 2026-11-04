import 'package:flutter/material.dart';

import '../../../core/navigation/tab_definition.dart';
import 'profile_screen.dart';

/// Вкладка «Профиль» для реестра вкладок.
final profileTab = TabDefinition(
  path: '/profile',
  icon: Icons.person_outline_rounded,
  selectedIcon: Icons.person_rounded,
  label: (l10n) => l10n.tabProfile,
  builder: (context) => const ProfileScreen(),
);
