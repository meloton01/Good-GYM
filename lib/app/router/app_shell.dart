import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/navigation/tab_definition.dart';
import '../../l10n/generated/app_localizations.dart';

/// Каркас с нижней навигацией; каждая вкладка хранит свой стек экранов.
class AppShell extends StatelessWidget {
  /// Создаёт каркас для переданных вкладок.
  const AppShell({
    super.key,
    required this.navigationShell,
    required this.tabs,
  });

  /// Максимальный масштаб шрифта подписей вкладок, чтобы пять подписей помещались на 360 dp.
  static const double _maxLabelTextScale = 1.3;

  final StatefulNavigationShell navigationShell;
  final List<TabDefinition> tabs;

  /// Строит Scaffold с NavigationBar и активной вкладкой.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: MediaQuery.withClampedTextScaling(
        maxScaleFactor: _maxLabelTextScale,
        child: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: _openTab,
          destinations: [
            for (final tab in tabs)
              NavigationDestination(
                icon: Icon(tab.icon),
                selectedIcon: Icon(tab.selectedIcon),
                label: tab.label(l10n),
              ),
          ],
        ),
      ),
    );
  }

  /// Открывает вкладку; повторное нажатие возвращает к её корневому экрану.
  void _openTab(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}
