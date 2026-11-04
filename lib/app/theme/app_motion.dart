import 'package:flutter/widgets.dart';

/// Токены длительности анимаций; не больше 300 мс.
abstract final class AppMotion {
  static const Duration medium = Duration(milliseconds: 250);

  /// Возвращает длительность или ноль, если в системе включено «уменьшить анимацию».
  static Duration resolve(Duration duration) {
    final features =
        WidgetsBinding.instance.platformDispatcher.accessibilityFeatures;
    return features.disableAnimations ? Duration.zero : duration;
  }
}
