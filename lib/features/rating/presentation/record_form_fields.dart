import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/theme_context.dart';
import '../../../core/formatting/measurement_format.dart';
import '../../../core/time/clock_provider.dart';
import '../../../core/units/unit_labels.dart';
import '../../../core/validation/number_validators.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../settings/presentation/app_settings_controller.dart';
import '../domain/rating_exercise.dart';
import '../domain/record_limits.dart';
import '../domain/sex.dart';
import 'rating_labels.dart';
import 'record_format.dart';

/// Значения формы рекорда; дата хранится без времени.
class RecordFormValues {
  final weight = TextEditingController();
  final reps = TextEditingController();
  final bodyWeight = TextEditingController();
  RatingExercise exercise = RatingExercise.squat;
  Sex? sex;
  DateTime? date;

  /// Момент подхода: сейчас для сегодняшней даты, иначе полдень выбранного дня.
  DateTime performedAt(DateTime now) {
    final day = date;
    if (day == null || DateUtils.isSameDay(day, now)) {
      return now;
    }
    return DateTime(day.year, day.month, day.day, _noon);
  }

  /// Освобождает контроллеры полей.
  void dispose() {
    weight.dispose();
    reps.dispose();
    bodyWeight.dispose();
  }

  static const int _noon = 12;
}

/// Поля рекорда: упражнение, вес, повторы, дата, пол и вес тела в единицах пользователя.
class RecordFormFields extends ConsumerStatefulWidget {
  /// Создаёт поля; [bodyWeightKg] из профиля подставляется в вес тела.
  const RecordFormFields({
    super.key,
    required this.values,
    required this.bodyWeightKg,
  });

  final RecordFormValues values;
  final double? bodyWeightKg;

  /// Создаёт состояние полей.
  @override
  ConsumerState<RecordFormFields> createState() => _RecordFormFieldsState();
}

/// Перерисовывает поля при выборе упражнения, пола и даты.
class _RecordFormFieldsState extends ConsumerState<RecordFormFields> {
  /// Подставляет вес тела из профиля, пока поле пустое.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _prefillBodyWeight();
  }

  /// Подставляет вес тела, когда он загрузился.
  @override
  void didUpdateWidget(RecordFormFields oldWidget) {
    super.didUpdateWidget(oldWidget);
    _prefillBodyWeight();
  }

  /// Строит поля формы.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final unit = ref.watch(appSettingsProvider.select((s) => s.weightUnit));
    final values = widget.values;
    final now = ref.watch(clockProvider)();
    final gap = SizedBox(height: context.spacing.md);
    final unitLabel = unit.shortLabel(l10n);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<RatingExercise>(
          initialValue: values.exercise,
          isExpanded: true,
          decoration: InputDecoration(labelText: l10n.ratingExerciseTitle),
          items: [
            for (final exercise in RatingExercise.values)
              DropdownMenuItem(
                value: exercise,
                child: Text(
                  exercise.label(l10n),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
          onChanged: (value) =>
              setState(() => values.exercise = value ?? values.exercise),
        ),
        gap,
        TextFormField(
          controller: values.weight,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: l10n.recordWeightLabel(unitLabel),
            helperText: values.exercise.allowsZeroWeight
                ? l10n.recordAddedWeightHint
                : null,
          ),
          validator: (value) => NumberValidators.number(
            l10n,
            locale,
            value,
            min: values.exercise.allowsZeroWeight ? 0 : 1,
            max: unit.fromKilograms(RecordLimits.maxWeightKg).floorToDouble(),
          ),
        ),
        gap,
        TextFormField(
          controller: values.reps,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: l10n.recordRepsLabel),
          validator: (value) => NumberValidators.number(
            l10n,
            locale,
            value,
            min: RecordLimits.minReps.toDouble(),
            max: RecordLimits.maxReps.toDouble(),
            integer: true,
          ),
        ),
        gap,
        ListTile(
          contentPadding: EdgeInsetsDirectional.zero,
          title: Text(l10n.recordDateLabel),
          subtitle: Text(
            RecordFormat.of(context, unit).date(values.date ?? now),
          ),
          trailing: const Icon(Icons.calendar_today_rounded),
          onTap: () => _pickDate(now),
        ),
        DropdownButtonFormField<Sex>(
          initialValue: values.sex,
          isExpanded: true,
          decoration: InputDecoration(labelText: l10n.ratingSexTitle),
          items: [
            for (final sex in Sex.values)
              DropdownMenuItem(
                value: sex,
                child: Text(sex.label(l10n), overflow: TextOverflow.ellipsis),
              ),
          ],
          validator: (value) => value == null ? l10n.validationRequired : null,
          onChanged: (value) => setState(() => values.sex = value),
        ),
        gap,
        TextFormField(
          controller: values.bodyWeight,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: l10n.recordBodyWeightLabel(unitLabel),
            helperText: l10n.recordBodyWeightHint,
            helperMaxLines: 3,
          ),
          validator: (value) => NumberValidators.number(
            l10n,
            locale,
            value,
            min: unit
                .fromKilograms(RecordLimits.minBodyWeightKg)
                .ceilToDouble(),
            max: unit
                .fromKilograms(RecordLimits.maxBodyWeightKg)
                .floorToDouble(),
          ),
        ),
      ],
    );
  }

  /// Открывает выбор даты за последний год.
  Future<void> _pickDate(DateTime now) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.values.date ?? now,
      firstDate: now.subtract(
        const Duration(days: RecordLimits.maxPerformedAgeDays),
      ),
      lastDate: now,
    );
    if (picked != null && mounted) {
      setState(() => widget.values.date = picked);
    }
  }

  /// Подставляет вес тела в единицах пользователя.
  void _prefillBodyWeight() {
    final kilograms = widget.bodyWeightKg;
    if (kilograms == null || widget.values.bodyWeight.text.isNotEmpty) {
      return;
    }
    final unit = ref.read(appSettingsProvider).weightUnit;
    widget.values.bodyWeight.text = MeasurementFormat.format(
      unit.fromKilograms(kilograms),
      Localizations.localeOf(context).toLanguageTag(),
    );
  }
}
