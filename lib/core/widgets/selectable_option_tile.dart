import 'package:flutter/material.dart';

import '../../app/theme/theme_context.dart';

/// Пункт списка выбора одного варианта с отметкой выбранного.
class SelectableOptionTile extends StatelessWidget {
  /// Создаёт пункт выбора.
  const SelectableOptionTile({
    super.key,
    required this.title,
    required this.selected,
    required this.onTap,
    this.subtitle,
    this.leading,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;

  /// Пояснение под названием варианта.
  final String? subtitle;

  /// Виджет перед названием, например образец цвета.
  final Widget? leading;

  /// Строит ListTile с галочкой у выбранного варианта.
  @override
  Widget build(BuildContext context) {
    final subtitle = this.subtitle;
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      child: ListTile(
        minTileHeight: context.sizes.minTouchTarget,
        leading: leading,
        title: Text(title),
        subtitle: subtitle == null ? null : Text(subtitle),
        selected: selected,
        trailing: selected
            ? Icon(Icons.check_rounded, color: context.colors.accentContent)
            : null,
        onTap: onTap,
      ),
    );
  }
}
