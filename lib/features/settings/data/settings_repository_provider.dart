import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/settings_repository.dart';

/// Репозиторий настроек; реализация подставляется в main через overrides.
final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => throw StateError(
    'settingsRepositoryProvider must be overridden in ProviderScope',
  ),
);
