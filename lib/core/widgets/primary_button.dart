import 'package:flutter/material.dart';

import '../../app/theme/theme_context.dart';
import '../../l10n/generated/app_localizations.dart';

/// Основная кнопка действия; во время операции показывает индикатор и не нажимается.
class PrimaryButton extends StatelessWidget {
  /// Создаёт основную кнопку.
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  /// Строит FilledButton на всю ширину.
  @override
  Widget build(BuildContext context) {
    final indicatorSize = DefaultTextStyle.of(context).style.fontSize;
    return FilledButton(
      onPressed: loading ? null : onPressed,
      child: loading
          ? SizedBox.square(
              dimension: indicatorSize,
              child: CircularProgressIndicator(
                strokeWidth: context.sizes.progressStrokeWidth,
                semanticsLabel: AppLocalizations.of(context).loadingLabel,
              ),
            )
          : Text(label, textAlign: TextAlign.center),
    );
  }
}
