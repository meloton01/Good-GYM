import 'package:flutter/widgets.dart';

import '../../../core/errors/result.dart';
import '../../../core/widgets/failure_snack_bar.dart';

/// Сохраняет настройку и показывает ошибку с повтором, если запись не удалась.
Future<void> saveSetting(
  BuildContext context,
  Future<Result<void>> Function() save,
) async {
  final result = await save();
  if (result is Failure<void> && context.mounted) {
    showFailureSnackBar(
      context,
      result.failure,
      onRetry: () => saveSetting(context, save),
    );
  }
}
