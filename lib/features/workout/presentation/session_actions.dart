import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/result.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../settings/domain/notification_type.dart';
import '../../settings/presentation/app_settings_controller.dart';
import '../domain/rest_alarm_text.dart';
import 'active_workout_controller.dart';
import 'rest_timer_controller.dart';

/// Запускает или продлевает отдых; уведомление ставится, если этот тип не выключен в настройках.
Future<Result<void>> requestRest(
  BuildContext context,
  WidgetRef ref,
  int seconds, {
  bool extend = false,
}) {
  final l10n = AppLocalizations.of(context);
  final text = RestAlarmText(
    title: l10n.restAlarmTitle,
    body: l10n.restAlarmBody,
    channelName: l10n.notificationRestTimer,
  );
  final notify = ref
      .read(appSettingsProvider)
      .isNotificationEnabled(NotificationType.restTimer);
  final timer = ref.read(restTimerProvider.notifier);
  return extend
      ? timer.extend(seconds, text: text, notify: notify)
      : timer.start(seconds, text: text, notify: notify);
}

/// Отменяет идущую тренировку после подтверждения и закрывает её экран.
Future<void> discardWorkout(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  final confirmed = await showConfirmDialog(
    context,
    title: l10n.workoutDiscard,
    message: l10n.workoutDiscardMessage,
    confirmLabel: l10n.workoutDiscardConfirm,
    destructive: true,
  );
  if (!confirmed || !context.mounted) {
    return;
  }
  await ref.read(activeWorkoutProvider.notifier).discard();
  if (context.mounted) {
    context.pop();
  }
}
