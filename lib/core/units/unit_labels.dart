import '../../l10n/generated/app_localizations.dart';
import 'length_unit.dart';
import 'weight_unit.dart';

/// Локализованные названия единицы веса.
extension WeightUnitLabels on WeightUnit {
  /// Полное название для списка выбора.
  String label(AppLocalizations l10n) => switch (this) {
    WeightUnit.kilograms => l10n.unitKilograms,
    WeightUnit.pounds => l10n.unitPounds,
  };

  /// Короткое обозначение рядом с числом.
  String shortLabel(AppLocalizations l10n) => switch (this) {
    WeightUnit.kilograms => l10n.unitKilogramsShort,
    WeightUnit.pounds => l10n.unitPoundsShort,
  };
}

/// Локализованные названия единицы длины.
extension LengthUnitLabels on LengthUnit {
  /// Полное название для списка выбора.
  String label(AppLocalizations l10n) => switch (this) {
    LengthUnit.centimeters => l10n.unitCentimeters,
    LengthUnit.inches => l10n.unitInches,
  };

  /// Короткое обозначение рядом с числом.
  String shortLabel(AppLocalizations l10n) => switch (this) {
    LengthUnit.centimeters => l10n.unitCentimetersShort,
    LengthUnit.inches => l10n.unitInchesShort,
  };
}
