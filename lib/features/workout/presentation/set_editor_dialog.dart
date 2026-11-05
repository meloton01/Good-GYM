import 'package:flutter/material.dart';

import '../../../app/theme/theme_context.dart';
import '../../../core/formatting/measurement_format.dart';
import '../../../core/units/unit_labels.dart';
import '../../../core/units/weight_unit.dart';
import '../../../core/validation/number_validators.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/workout_limits.dart';
import '../domain/workout_set.dart';

/// Открывает правку подхода: повторы, вес в единицах пользователя и отдых; null при отмене.
Future<WorkoutSet?> showSetEditor(
  BuildContext context, {
  required WorkoutSet initial,
  required WeightUnit unit,
}) {
  return showDialog<WorkoutSet>(
    context: context,
    builder: (context) => _SetEditorDialog(initial: initial, unit: unit),
  );
}

/// Диалог с тремя числовыми полями.
class _SetEditorDialog extends StatefulWidget {
  /// Создаёт диалог для подхода [initial].
  const _SetEditorDialog({required this.initial, required this.unit});

  final WorkoutSet initial;
  final WeightUnit unit;

  /// Создаёт состояние диалога.
  @override
  State<_SetEditorDialog> createState() => _SetEditorDialogState();
}

/// Хранит контроллеры полей и форму.
class _SetEditorDialogState extends State<_SetEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _reps;
  late final TextEditingController _weight;
  late final TextEditingController _rest;

  /// Заполняет поля значениями подхода.
  @override
  void initState() {
    super.initState();
    _reps = TextEditingController(text: '${widget.initial.reps}');
    _weight = TextEditingController();
    _rest = TextEditingController(text: '${widget.initial.restSeconds}');
  }

  /// Подставляет вес в формате локали, когда она известна.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final weight = widget.initial.weightKg;
    if (_weight.text.isEmpty && weight != null && weight > 0) {
      _weight.text = MeasurementFormat.format(
        widget.unit.fromKilograms(weight),
        Localizations.localeOf(context).toLanguageTag(),
      );
    }
  }

  /// Освобождает контроллеры полей.
  @override
  void dispose() {
    _reps.dispose();
    _weight.dispose();
    _rest.dispose();
    super.dispose();
  }

  /// Строит форму подхода.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final gap = SizedBox(height: context.spacing.md);
    return AlertDialog(
      title: Text(l10n.setEditTitle),
      scrollable: true,
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _reps,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: l10n.setRepsLabel),
              validator: (value) => NumberValidators.number(
                l10n,
                locale,
                value,
                min: WorkoutLimits.minReps.toDouble(),
                max: WorkoutLimits.maxReps.toDouble(),
                integer: true,
              ),
            ),
            gap,
            TextFormField(
              controller: _weight,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: l10n.setWeightLabel(widget.unit.shortLabel(l10n)),
                helperText: l10n.setWeightHelper,
              ),
              validator: (value) => NumberValidators.number(
                l10n,
                locale,
                value,
                min: 0,
                max: widget.unit.fromKilograms(WorkoutLimits.maxWeightKg),
                optional: true,
              ),
            ),
            gap,
            TextFormField(
              controller: _rest,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: l10n.setRestLabel),
              validator: (value) => NumberValidators.number(
                l10n,
                locale,
                value,
                min: 0,
                max: WorkoutLimits.maxRestSeconds.toDouble(),
                integer: true,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.actionCancel),
        ),
        TextButton(onPressed: _submit, child: Text(l10n.actionSave)),
      ],
    );
  }

  /// Проверяет поля и возвращает подход с весом в килограммах.
  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final weight = MeasurementFormat.parse(_weight.text);
    Navigator.of(context).pop(
      widget.initial.copyWith(
        reps: MeasurementFormat.parse(_reps.text)!.round(),
        restSeconds: MeasurementFormat.parse(_rest.text)!.round(),
        weightKg: weight == null || weight == 0
            ? null
            : widget.unit.toKilograms(weight),
      ),
    );
  }
}
