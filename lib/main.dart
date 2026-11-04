import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'features/settings/data/settings_repository_provider.dart';
import 'features/settings/data/shared_preferences_settings_repository.dart';

/// Точка входа: загружает локальные настройки до первого кадра и запускает приложение.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(
          SharedPreferencesSettingsRepository(preferences),
        ),
      ],
      child: const GoodGymApp(),
    ),
  );
}
