import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/generated/app_localizations.dart';

/// Описание вкладки нижней навигации; фича отдаёт его в реестр вкладок.
@immutable
class TabDefinition {
  /// Создаёт описание вкладки.
  const TabDefinition({
    required this.path,
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.builder,
    this.routes = const [],
  });

  /// Корневой путь вкладки в роутере, например `/home`.
  final String path;
  final IconData icon;
  final IconData selectedIcon;

  /// Подпись вкладки на текущем языке.
  final String Function(AppLocalizations l10n) label;

  /// Корневой экран вкладки.
  final WidgetBuilder builder;

  /// Вложенные экраны вкладки; открываются над ней, нижняя навигация остаётся.
  final List<RouteBase> routes;
}
