import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../core/navigation/tab_definition.dart';
import '../../auth/presentation/change_email_screen.dart';
import '../../auth/presentation/change_password_screen.dart';
import 'appearance_screen.dart';
import 'settings_screen.dart';

/// Вкладка «Настройки» для реестра вкладок.
final settingsTab = TabDefinition(
  path: '/settings',
  icon: Icons.settings_outlined,
  selectedIcon: Icons.settings_rounded,
  label: (l10n) => l10n.tabSettings,
  builder: (context) => const SettingsScreen(),
  routes: [
    GoRoute(
      path: AppRoutes.appearanceSegment,
      builder: (context, state) => const AppearanceScreen(),
    ),
    GoRoute(
      path: AppRoutes.changeEmailSegment,
      builder: (context, state) => const ChangeEmailScreen(),
    ),
    GoRoute(
      path: AppRoutes.changePasswordSegment,
      builder: (context, state) => const ChangePasswordScreen(),
    ),
  ],
);
