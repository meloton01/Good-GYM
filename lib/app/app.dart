import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/settings/domain/app_theme_mode.dart';
import '../features/settings/presentation/app_settings_controller.dart';
import '../l10n/generated/app_localizations.dart';
import 'router/app_router.dart';
import 'theme/app_colors.dart';
import 'theme/app_motion.dart';
import 'theme/app_theme.dart';

/// Корневой виджет: тема, язык и роутер из текущих настроек.
class GoodGymApp extends ConsumerWidget {
  /// Создаёт корневой виджет приложения.
  const GoodGymApp({super.key});

  static final ThemeData _darkTheme = buildAppTheme(AppColors.dark);
  static final ThemeData _lightTheme = buildAppTheme(AppColors.light);

  /// Строит MaterialApp.router и перестраивает его при смене темы или языка.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final languageCode = settings.languageCode;
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      routerConfig: ref.watch(appRouterProvider),
      theme: _lightTheme,
      darkTheme: _darkTheme,
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
