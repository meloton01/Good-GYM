import 'sex.dart';

/// Весовая категория IPF; [id] совпадает с полем weightClass, которое считает сервер.
class WeightClass {
  /// Создаёт категорию до [upperKg] включительно или тяжелее, если [open].
  const WeightClass._(this.sex, this.upperKg, {this.open = false});

  final Sex sex;
  final double upperKg;
  final bool open;

  static const List<double> _maleBounds = [59, 66, 74, 83, 93, 105, 120];
  static const List<double> _femaleBounds = [47, 52, 57, 63, 69, 76, 84];

  /// Категории пола [sex] от лёгкой к тяжёлой.
  static List<WeightClass> forSex(Sex sex) {
    final bounds = sex == Sex.male ? _maleBounds : _femaleBounds;
    return [
      for (final bound in bounds) WeightClass._(sex, bound),
      WeightClass._(sex, bounds.last, open: true),
    ];
  }

  /// Категория по id или null для неизвестного.
  static WeightClass? fromId(String? id) {
    for (final sex in Sex.values) {
      for (final weightClass in forSex(sex)) {
        if (weightClass.id == id) {
          return weightClass;
        }
      }
    }
    return null;
  }

  /// Id вида «m83» или «m120plus».
  String get id {
    final prefix = sex == Sex.male ? 'm' : 'f';
    return '$prefix${upperKg.toInt()}${open ? 'plus' : ''}';
  }

  /// Сравнение по id.
  @override
  bool operator ==(Object other) => other is WeightClass && other.id == id;

  /// Хеш по id.
  @override
  int get hashCode => id.hashCode;
}
