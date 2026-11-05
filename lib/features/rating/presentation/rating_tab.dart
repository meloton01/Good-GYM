import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../core/navigation/tab_definition.dart';
import 'rating_screen.dart';
import 'record_detail_screen.dart';
import 'record_holder_screen.dart';
import 'submit_record_screen.dart';

/// Вкладка «Рейтинг» для реестра вкладок.
final ratingTab = TabDefinition(
  path: '/rating',
  icon: Icons.leaderboard_outlined,
  selectedIcon: Icons.leaderboard_rounded,
  label: (l10n) => l10n.tabRating,
  builder: (context) => const RatingScreen(),
  routes: [
    GoRoute(
      path: AppRoutes.submitRecordSegment,
      builder: (context, state) => const SubmitRecordScreen(),
    ),
    GoRoute(
      path: AppRoutes.recordDetailSegment,
      builder: (context, state) =>
          RecordDetailScreen(recordId: state.pathParameters['recordId']!),
    ),
    GoRoute(
      path: AppRoutes.recordHolderSegment,
      builder: (context, state) =>
          RecordHolderScreen(uid: state.pathParameters['uid']!),
    ),
  ],
);
