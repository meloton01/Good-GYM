import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/theme_context.dart';
import '../../../core/errors/app_failure_message.dart';
import '../../../core/errors/result.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../rating/data/gym_repository_provider.dart';
import '../../rating/domain/gym.dart';
import '../../rating/domain/gym_policy.dart';

/// Показывает диалог создания зала; возвращает созданный зал или null.
Future<Gym?> showCreateGymDialog(
  BuildContext context, {
  required String initialName,
}) {
  return showDialog<Gym>(
    context: context,
    builder: (context) => _CreateGymDialog(initialName: initialName),
  );
}

/// Диалог с названием и городом зала.
class _CreateGymDialog extends ConsumerStatefulWidget {
  /// Создаёт диалог с предзаполненным названием.
  const _CreateGymDialog({required this.initialName});

  final String initialName;

  /// Создаёт состояние диалога.
  @override
  ConsumerState<_CreateGymDialog> createState() => _CreateGymDialogState();
}

/// Хранит поля, флаг отправки и текст ошибки.
class _CreateGymDialogState extends ConsumerState<_CreateGymDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.initialName.trim());
  final _city = TextEditingController();
  bool _submitting = false;
  String? _error;

  /// Освобождает контроллеры полей.
  @override
  void dispose() {
    _name.dispose();
    _city.dispose();
    super.dispose();
  }

  /// Строит поля названия и города и кнопки.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final error = _error;
    String? validate(String? value) => GymPolicy.isValidText(value ?? '')
        ? null
        : l10n.validationTextLength(GymPolicy.minLength, GymPolicy.maxLength);
    return AlertDialog(
      title: Text(l10n.gymCreate),
      scrollable: true,
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _name,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(labelText: l10n.gymNameLabel),
              validator: validate,
            ),
            SizedBox(height: context.spacing.md),
            TextFormField(
              controller: _city,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(labelText: l10n.gymCityLabel),
              validator: validate,
              onFieldSubmitted: (_) => _submit(),
            ),
            if (error != null) ...[
              SizedBox(height: context.spacing.md),
              Text(error, style: TextStyle(color: context.colors.error)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.actionCancel),
        ),
        TextButton(
          onPressed: _submitting ? null : _submit,
          child: Text(l10n.actionSave),
        ),
      ],
    );
  }

  /// Создаёт зал и закрывает диалог с ним; ошибку показывает в диалоге.
  Future<void> _submit() async {
    if (_submitting || !_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    final result = await ref
        .read(gymRepositoryProvider)
        .createGym(name: _name.text, city: _city.text);
    if (!mounted) {
      return;
    }
    switch (result) {
      case Success(:final value):
        Navigator.of(context).pop(value);
      case Failure(:final failure):
        setState(() {
          _submitting = false;
          _error = failure.message(AppLocalizations.of(context));
        });
    }
  }
}
