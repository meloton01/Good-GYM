import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';

/// Состояние загрузки экрана: индикатор по центру с подписью для скринридера.
class LoadingView extends StatelessWidget {
  /// Создаёт состояние загрузки.
  const LoadingView({super.key});

  /// Строит индикатор прогресса.
  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        semanticsLabel: AppLocalizations.of(context).loadingLabel,
      ),
    );
  }
}
