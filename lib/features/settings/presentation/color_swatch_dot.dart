import 'package:flutter/material.dart';

import '../../../app/theme/theme_context.dart';

/// Круглый образец цвета с рамкой, видимой на любом фоне.
class ColorSwatchDot extends StatelessWidget {
  /// Создаёт образец; [selected] выделяет его толстой рамкой.
  const ColorSwatchDot({super.key, required this.color, this.selected = false});

  final Color color;
  final bool selected;

  /// Строит круг заданного цвета.
  @override
  Widget build(BuildContext context) {
    final sizes = context.sizes;
    final colors = context.colors;
    return Container(
      width: sizes.iconLarge / 2,
      height: sizes.iconLarge / 2,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: selected
            ? Border.all(
                color: colors.textPrimary,
                width: sizes.selectionBorderWidth,
              )
            : Border.all(color: colors.border),
      ),
    );
  }
}
