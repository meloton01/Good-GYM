import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/settings/domain/app_theme_mode.dart';
import '../features/settings/presentation/app_settings_controller.dart';
import '../l10n/generated/app_localizations.dart';
import 'router/app_router.dart';
import 'theme/app_motion.dart';
import 'theme/app_themes_provider.dart';

/// Корневой виджет: тема, язык и роутер из текущих настроек.
class GoodGymApp extends ConsumerWidget {
  /// Создаёт корневой виджет приложения.
  const GoodGymApp({super.key});

  /// Строит MaterialApp.router и перестраивает его при смене темы или языка.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final themes = ref.watch(appThemesProvider);
    final languageCode = settings.languageCode;
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      routerConfig: ref.watch(appRouterProvider),
      theme: themes.light,
      darkTheme: themes.dark,
      themeMode: _themeMode(settings.themeMode),
      themeAnimationDuration: AppMotion.resolve(AppMotion.medium),
      locale: languageCode == null ? null : Locale(languageCode),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }

  /// Переводит режим темы из настроек в ThemeMode Flutter.
  ThemeMode _themeMode(AppThemeMode mode) {
    return switch (mode) {
      AppThemeMode.system => ThemeMode.system,
      AppThemeMode.light => ThemeMode.light,
      AppThemeMode.dark => ThemeMode.dark,
    };
  }
}
