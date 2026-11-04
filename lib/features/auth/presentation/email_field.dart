import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import 'credential_validators.dart';

/// Поле ввода email с проверкой формата и автозаполнением.
class EmailField extends StatelessWidget {
  /// Создаёт поле email.
  const EmailField({
    super.key,
    required this.controller,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final TextInputAction textInputAction;
  final VoidCallback? onSubmitted;

  /// Строит TextFormField для email.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      textInputAction: textInputAction,
      autofillHints: const [AutofillHints.email],
      autocorrect: false,
      decoration: InputDecoration(labelText: l10n.authEmailLabel),
      validator: (value) => CredentialValidators.email(l10n, value),
      onFieldSubmitted: (_) => onSubmitted?.call(),
    );
  }
}
