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
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;

  /// Строит ListTile с галочкой у выбранного варианта.
  @override
  Widget build(BuildContext context) {
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      child: ListTile(
        minTileHeight: context.sizes.minTouchTarget,
        title: Text(title),
        selected: selected,
        trailing: selected
            ? Icon(Icons.check_rounded, color: context.colors.accentContent)
            : null,
        onTap: onTap,
      ),
    );
  }
}
