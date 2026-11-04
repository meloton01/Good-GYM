import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';

/// Поле ввода пароля с кнопкой показа символов.
class PasswordField extends StatefulWidget {
  /// Создаёт поле пароля с заданной подписью и валидатором.
  const PasswordField({
    super.key,
    required this.controller,
    required this.label,
    required this.validator,
    this.autofillHint = AutofillHints.password,
    this.textInputAction = TextInputAction.done,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final FormFieldValidator<String> validator;
  final String autofillHint;
  final TextInputAction textInputAction;
  final VoidCallback? onSubmitted;

  /// Создаёт состояние поля.
  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

/// Хранит, скрыт ли пароль.
class _PasswordFieldState extends State<PasswordField> {
  bool _obscured = true;

  /// Строит TextFormField с переключателем видимости.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscured,
      textInputAction: widget.textInputAction,
      autofillHints: [widget.autofillHint],
      autocorrect: false,
      enableSuggestions: false,
      decoration: InputDecoration(
        labelText: widget.label,
        suffixIcon: IconButton(
          tooltip: _obscured ? l10n.authShowPassword : l10n.authHidePassword,
          icon: Icon(
            _obscured
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
          onPressed: () => setState(() => _obscured = !_obscured),
        ),
      ),
      validator: widget.validator,
      onFieldSubmitted: (_) => widget.onSubmitted?.call(),
    );
  }
}
