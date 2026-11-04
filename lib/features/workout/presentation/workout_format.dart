import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../../../core/formatting/measurement_format.dart';
import '../../../core/units/unit_labels.dart';
import '../../../core/units/weight_unit.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/workout.dart';
import '../domain/workout_set.dart';

/// Форматирование тренировочных значений по языку и единицам пользователя.
class WorkoutFormat {
  /// Создаёт форматтер для языка [locale] и единицы веса [unit].
  const WorkoutFormat(this.l10n, this.locale, this.unit);

  static const int _secondsPerMinute = 60;

  /// Создаёт форматтер для языка интерфейса из [context].
  factory WorkoutFormat.of(BuildContext context, WeightUnit unit) {
    return WorkoutFormat(
      AppLocalizations.of(context),
      Localizations.localeOf(context).toLanguageTag(),
      unit,
    );
  }

  final AppLocalizations l10n;
  final String locale;
  final WeightUnit unit;

  /// Вес из килограммов в единицах пользователя, например «62,5 kg».
  String weight(double kilograms) {
    final value = MeasurementFormat.format(
      unit.fromKilograms(kilograms),
      locale,
    );
    return l10n.valueWithUnit(value, unit.shortLabel(l10n));
  }

  /// Подход: «10 × 60 kg» или «10 повторений» без отягощения.
  String set(WorkoutSet set) {
    final weightKg = set.weightKg;
    return weightKg == null || weightKg == 0
        ? l10n.setRepsOnly(set.reps)
        : l10n.setRepsWeight(set.reps, weight(weightKg));
  }

  /// Время отдыха в виде «1:30».
  String rest(int seconds) {
    final minutes = seconds ~/ _secondsPerMinute;
    final rest = (seconds % _secondsPerMinute).toString().padLeft(2, '0');
    return '$minutes:$rest';
  }

  /// Длительность тренировки в минутах или часах и минутах.
  String duration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(Duration.minutesPerHour);
    return hours == 0
        ? l10n.durationMinutes(minutes)
        : l10n.durationHoursMinutes(hours, minutes);
  }

  /// Дата и время по локали.
  String dateTime(DateTime value) {
    return DateFormat.yMMMd(locale).add_Hm().format(value.toLocal());
  }

  /// Короткая дата для подписей графика.
  String shortDate(DateTime value) {
    return DateFormat.Md(locale).format(value.toLocal());
  }

  /// Сводка тренировки: число упражнений и длительность.
  String summary(Workout workout) {
    final finishedAt = workout.finishedAt;
    final count = l10n.exerciseCount(workout.exercises.length);
    return finishedAt == null
        ? count
        : l10n.workoutSummary(
            count,
            duration(finishedAt.difference(workout.startedAt)),
          );
  }
}
