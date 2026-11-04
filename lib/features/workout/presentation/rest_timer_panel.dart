import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/theme_context.dart';
import '../../../core/time/clock_provider.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/workout_limits.dart';
import 'rest_timer_controller.dart';
import 'rest_timer_state.dart';
import 'workout_format.dart';

/// Обратный отсчёт отдыха с кнопками продления и пропуска; без отдыха ничего не показывает.
class RestTimerPanel extends ConsumerStatefulWidget {
  /// Создаёт панель; [onExtend] продлевает отдых, [onSkip] завершает его.
  const RestTimerPanel({
    super.key,
    required this.format,
    required this.onExtend,
    required this.onSkip,
  });

  final WorkoutFormat format;
  final VoidCallback onExtend;
  final VoidCallback onSkip;

  /// Создаёт состояние панели.
  @override
  ConsumerState<RestTimerPanel> createState() => _RestTimerPanelState();
}

/// Перерисовывает отсчёт раз в секунду, пока идёт отдых.
class _RestTimerPanelState extends ConsumerState<RestTimerPanel> {
  static const Duration _tick = Duration(seconds: 1);

  Timer? _ticker;

  /// Останавливает отсчёт.
  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  /// Строит отсчёт, шкалу и кнопки.
  @override
  Widget build(BuildContext context) {
    final rest = ref.watch(restTimerProvider);
    _syncTicker(rest);
    if (rest == null) {
      return const SizedBox.shrink();
    }
    final l10n = AppLocalizations.of(context);
    final spacing = context.spacing;
    final remaining = rest.remaining(ref.read(clockProvider)());
    final progress = rest.totalSeconds == 0
        ? 0.0
        : remaining.inSeconds / rest.totalSeconds;
    return Padding(
      padding: EdgeInsetsDirectional.only(bottom: spacing.md),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.colors.surfaceHigh,
          borderRadius: BorderRadius.circular(context.radii.medium),
        ),
        child: Padding(
          padding: EdgeInsetsDirectional.all(spacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.restTitle,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Semantics(
                liveRegion: true,
                child: Text(
                  widget.format.rest(remaining.inSeconds),
                  style: Theme.of(context).textTheme.displaySmall,
                ),
              ),
              SizedBox(height: spacing.sm),
              LinearProgressIndicator(value: progress.clamp(0, 1)),
              SizedBox(height: spacing.sm),
              Wrap(
                spacing: spacing.sm,
                runSpacing: spacing.sm,
                children: [
                  OutlinedButton(
                    onPressed: widget.onExtend,
                    child: Text(l10n.restExtend(WorkoutLimits.restStepSeconds)),
                  ),
                  TextButton(
                    onPressed: widget.onSkip,
                    child: Text(l10n.restSkip),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Запускает посекундную перерисовку на время отдыха и останавливает её после.
  void _syncTicker(RestTimerState? rest) {
    if (rest == null) {
      _ticker?.cancel();
      _ticker = null;
    } else {
      _ticker ??= Timer.periodic(_tick, (_) {
        if (mounted) {
          setState(() {});
        }
      });
    }
  }
}
