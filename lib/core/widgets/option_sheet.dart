import 'package:flutter/material.dart';

import '../../app/theme/theme_context.dart';
import 'section_header.dart';
import 'selectable_option_tile.dart';

/// Открывает нижнюю панель выбора одного варианта и возвращает выбранный или null.
Future<T?> showOptionSheet<T>(
  BuildContext context, {
  required String title,
  required List<T> options,
  required T selected,
  required String Function(T option) label,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsetsDirectional.only(bottom: context.spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionHeader(title: title),
            for (final option in options)
              SelectableOptionTile(
                title: label(option),
                selected: option == selected,
                onTap: () => Navigator.of(context).pop(option),
              ),
          ],
        ),
      ),
    ),
  );
}
