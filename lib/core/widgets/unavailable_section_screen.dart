import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import 'empty_state_view.dart';

/// Экран раздела, функциональность которого ещё не выпущена.
class UnavailableSectionScreen extends StatelessWidget {
  /// Создаёт экран с заголовком раздела и пустым состоянием.
  const UnavailableSectionScreen({
    super.key,
    required this.title,
    required this.icon,
  });

  final String title;
  final IconData icon;

  /// Строит AppBar с названием раздела и пустое состояние.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: EmptyStateView(
        icon: icon,
        title: l10n.emptySectionTitle,
        message: l10n.emptySectionMessage,
      ),
    );
  }
}
