import 'package:flutter/material.dart';

import '../../app/theme/theme_context.dart';

/// Заголовок группы элементов в списке.
class SectionHeader extends StatelessWidget {
  /// Создаёт заголовок группы.
  const SectionHeader({super.key, required this.title});

  final String title;

  /// Строит заголовок с отступами из токенов темы.
  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
        spacing.md,
        spacing.lg,
        spacing.md,
        spacing.sm,
      ),
      child: Semantics(
        header: true,
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleSmall
              ?.copyWith(color: context.colors.textSecondary),
        ),
      ),
    );
  }
}
