import 'package:flutter/material.dart';

import '../../app/theme/theme_context.dart';

/// Пустое состояние экрана: иконка, заголовок и пояснение.
class EmptyStateView extends StatelessWidget {
  /// Создаёт пустое состояние.
  const EmptyStateView({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  /// Строит прокручиваемый блок, чтобы крупный шрифт не вызывал overflow.
  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsetsDirectional.all(spacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: context.sizes.iconLarge,
              color: context.colors.textSecondary,
            ),
            SizedBox(height: spacing.md),
            Text(
              title,
              style: textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: spacing.sm),
            Text(
              message,
              style: textTheme.bodyMedium?.copyWith(
                color: context.colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
