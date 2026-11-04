import 'package:flutter_test/flutter_test.dart';
import 'package:good_gym/core/formatting/measurement_format.dart';
import 'package:good_gym/core/units/length_unit.dart';
import 'package:good_gym/core/units/weight_unit.dart';

void main() {
  test('weight converts between kilograms and pounds both ways', () {
    expect(WeightUnit.pounds.fromKilograms(100), closeTo(220.46, 0.01));
    expect(WeightUnit.pounds.toKilograms(220.46), closeTo(100, 0.01));
    expect(WeightUnit.kilograms.fromKilograms(82.5), 82.5);
  });

  test('length converts between centimeters and inches both ways', () {
    expect(LengthUnit.inches.fromCentimeters(254), closeTo(100, 0.001));
    expect(LengthUnit.inches.toCentimeters(72), closeTo(182.88, 0.001));
    expect(LengthUnit.centimeters.toCentimeters(180), 180);
  });

  test('measurement input accepts comma and dot, rejects text', () {
    expect(MeasurementFormat.parse('82,5'), 82.5);
    expect(MeasurementFormat.parse(' 82.5 '), 82.5);
    expect(MeasurementFormat.parse('abc'), isNull);
  });

  test('measurement output follows the locale decimal separator', () {
    expect(MeasurementFormat.format(82.5, 'en'), '82.5');
    expect(MeasurementFormat.format(82.5, 'uk'), '82,5');
    expect(MeasurementFormat.format(80, 'en'), '80');
  });
}
