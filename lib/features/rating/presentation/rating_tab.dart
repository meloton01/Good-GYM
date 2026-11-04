import 'package:flutter/material.dart';

import '../../../core/navigation/tab_definition.dart';
import '../../../core/widgets/unavailable_section_screen.dart';
import '../../../l10n/generated/app_localizations.dart';

/// Вкладка «Рейтинг» для реестра вкладок.
final ratingTab = TabDefinition(
  path: '/rating',
  icon: Icons.leaderboard_outlined,
  selectedIcon: Icons.leaderboard_rounded,
  label: (l10n) => l10n.tabRating,
  builder: (context) => UnavailableSectionScreen(
    title: AppLocalizations.of(context).tabRating,
    icon: Icons.leaderboard_outlined,
  ),
);
