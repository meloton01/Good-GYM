import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Источник текущего времени; в тестах подменяется, чтобы управлять таймерами.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);
