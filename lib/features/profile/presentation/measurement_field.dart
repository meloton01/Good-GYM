import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import 'profile_validators.dart';

/// Необязательное числовое поле с проверкой диапазона в единицах пользователя.
class MeasurementField extends StatelessWidget {
  /// Создаёт поле с подписью [label] и диапазоном [min]..[max].
  const MeasurementField({
    super.key,
    required this.controller,
    required this.label,
    required this.min,
    required this.max,
    this.helperText,
  });

  final TextEditingController controller;
  final String label;
  final double min;
  final double max;
  final String? helperText;

  /// Строит TextFormField с цифровой клавиатурой.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: label, helperText: helperText),
      validator: (value) => ProfileValidators.optionalNumber(
        l10n,
        locale,
        value,
        min: min,
        max: max,
      ),
    );
  }
}
