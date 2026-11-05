import 'package:flutter/material.dart';

import '../../../app/theme/theme_context.dart';
import '../../../l10n/generated/app_localizations.dart';

/// Обязательная отметка: возраст 16+ и согласие на обработку данных.
class ConsentField extends StatelessWidget {
  /// Создаёт поле согласия для формы.
  const ConsentField({super.key});

  /// Строит отметку с текстом согласия и ошибкой, если отметки нет.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return FormField<bool>(
      initialValue: false,
      validator: (value) =>
          value == true ? null : l10n.validationConsentRequired,
      builder: (field) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CheckboxListTile(
            value: field.value ?? false,
            onChanged: field.didChange,
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsetsDirectional.zero,
            title: Text(l10n.profileConsentLabel),
          ),
          if (field.errorText case final error?)
            Text(
              error,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: context.colors.error),
            ),
        ],
      ),
    );
  }
}
