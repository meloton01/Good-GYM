import 'package:flutter/material.dart';

import '../../../core/navigation/tab_definition.dart';
import '../../../core/widgets/unavailable_section_screen.dart';
import '../../../l10n/generated/app_localizations.dart';

/// Вкладка «Тренировки» для реестра вкладок.
final workoutTab = TabDefinition(
  path: '/workout',
  icon: Icons.fitness_center_outlined,
  selectedIcon: Icons.fitness_center_rounded,
  label: (l10n) => l10n.tabWorkout,
  builder: (context) => UnavailableSectionScreen(
    title: AppLocalizations.of(context).tabWorkout,
    icon: Icons.fitness_center_outlined,
  ),
);
