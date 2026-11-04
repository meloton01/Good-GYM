import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'features/settings/data/settings_repository_provider.dart';
import 'features/settings/data/shared_preferences_settings_repository.dart';
import 'firebase_options.dart';

/// Точка входа: подключает Firebase и локальные настройки до первого кадра.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final (_, preferences) = await (
    Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
    SharedPreferences.getInstance(),
  ).wait;
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
