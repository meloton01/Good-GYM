import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../../../core/formatting/measurement_format.dart';
import '../../../core/units/unit_labels.dart';
import '../../../core/units/weight_unit.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/gym_record.dart';

/// Форматирование рекордов по языку и единицам пользователя.
class RecordFormat {
  /// Создаёт форматтер для языка интерфейса из [context] и единицы [unit].
  RecordFormat.of(BuildContext context, this.unit)
    : l10n = AppLocalizations.of(context),
      locale = Localizations.localeOf(context).toLanguageTag();

  final AppLocalizations l10n;
  final String locale;
  final WeightUnit unit;

  /// Вес из килограммов в единицах пользователя, например «140 kg».
  String weight(double kilograms) {
    final value = MeasurementFormat.format(
      unit.fromKilograms(kilograms),
      locale,
    );
    return l10n.valueWithUnit(value, unit.shortLabel(l10n));
  }

  /// Подход рекорда: «3 × 140 kg».
  String lift(GymRecord record) =>
      l10n.setRepsWeight(record.reps, weight(record.weightKg));

  /// Дата по локали.
  String date(DateTime value) =>
      DateFormat.yMMMd(locale).format(value.toLocal());
}
