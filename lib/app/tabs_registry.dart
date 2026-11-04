import '../core/navigation/tab_definition.dart';
import '../features/home/presentation/home_tab.dart';
import '../features/profile/presentation/profile_tab.dart';
import '../features/rating/presentation/rating_tab.dart';
import '../features/settings/presentation/settings_tab.dart';
import '../features/workout/presentation/workout_tab.dart';

/// Вкладки нижней навигации по порядку; чтобы отключить вкладку, убери её из списка.
final List<TabDefinition> appTabs = [
  homeTab,
  ratingTab,
  workoutTab,
  profileTab,
  settingsTab,
];
