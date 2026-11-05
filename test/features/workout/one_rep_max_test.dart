import 'package:flutter_test/flutter_test.dart';
import 'package:good_gym/features/workout/domain/one_rep_max.dart';

void main() {
  test('Epley formula matches weight × (1 + reps / 30)', () {
    expect(estimateOneRepMax(100, 5), closeTo(116.67, 0.01));
    expect(estimateOneRepMax(140, 3), closeTo(154, 0.001));
    expect(estimateOneRepMax(60, 30), 120);
  });

  test('a single rep equals the lifted weight', () {
    expect(estimateOneRepMax(180, 1), 180);
    expect(estimateOneRepMax(180, 0), 180);
  });

  test('more reps with the same weight give a higher estimate', () {
    final estimates = [
      for (var reps = 1; reps <= 12; reps++) estimateOneRepMax(100, reps),
    ];
    for (var index = 1; index < estimates.length; index++) {
      expect(estimates[index], greaterThan(estimates[index - 1]));
    }
  });

  test('bodyweight sets without added weight estimate zero', () {
    expect(estimateOneRepMax(0, 10), 0);
  });
}
