import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../core/navigation/tab_definition.dart';
import 'edit_profile_screen.dart';
import 'gym_picker_screen.dart';
import 'profile_screen.dart';
import 'public_profile_screen.dart';

/// Вкладка «Профиль» для реестра вкладок.
final profileTab = TabDefinition(
  path: '/profile',
  icon: Icons.person_outline_rounded,
  selectedIcon: Icons.person_rounded,
  label: (l10n) => l10n.tabProfile,
  builder: (context) => const ProfileScreen(),
  routes: [
    GoRoute(
      path: AppRoutes.profileEditSegment,
      builder: (context, state) => const EditProfileScreen(),
      routes: [
        GoRoute(
          path: AppRoutes.gymPickerSegment,
          builder: (context, state) => const GymPickerScreen(),
        ),
      ],
    ),
    GoRoute(
      path: AppRoutes.publicProfileSegment,
      builder: (context, state) =>
          PublicProfileScreen(uid: state.pathParameters['uid']!),
    ),
  ],
);
