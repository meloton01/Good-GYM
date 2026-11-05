import 'package:flutter/material.dart';

import '../../app/theme/theme_context.dart';

/// Пустое состояние экрана: иконка, заголовок, пояснение и необязательное действие.
class EmptyStateView extends StatelessWidget {
  /// Создаёт пустое состояние.
  const EmptyStateView({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String message;

  /// Кнопка под пояснением, если состояние можно исправить отсюда.
  final Widget? action;

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
            if (action case final action?) ...[
              SizedBox(height: spacing.md),
              action,
            ],
          ],
        ),
      ),
    );
  }
}
