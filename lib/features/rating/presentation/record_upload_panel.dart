import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/theme_context.dart';
import '../../../core/errors/app_failure_message.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/video_source.dart';
import 'record_upload_controller.dart';
import 'record_upload_state.dart';

/// Выбор видео и ход загрузки: прогресс, пауза, продолжение и повтор.
class RecordUploadPanel extends ConsumerWidget {
  /// Создаёт панель видео рекорда.
  const RecordUploadPanel({super.key});

  /// Строит содержимое по этапу загрузки.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(recordUploadProvider);
    final controller = ref.read(recordUploadProvider.notifier);
    final spacing = context.spacing;
    final failure = state.failure;
    final percent = (state.progress * 100).round();

    final pickButtons = Wrap(
      spacing: spacing.sm,
      runSpacing: spacing.sm,
      children: [
        OutlinedButton.icon(
          onPressed: () => controller.pick(VideoOrigin.camera),
          icon: const Icon(Icons.videocam_outlined),
          label: Text(l10n.videoRecord),
        ),
        OutlinedButton.icon(
          onPressed: () => controller.pick(VideoOrigin.gallery),
          icon: const Icon(Icons.video_library_outlined),
          label: Text(l10n.videoChoose),
        ),
      ],
    );

    final children = switch (state.phase) {
      UploadPhase.idle => [Text(l10n.videoHint), pickButtons],
      UploadPhase.preparing => [
        Text(l10n.videoPreparing),
        LinearProgressIndicator(semanticsLabel: l10n.videoPreparing),
      ],
      UploadPhase.uploading || UploadPhase.paused => [
        Text(
          state.phase == UploadPhase.paused
              ? l10n.videoUploadPaused(percent)
              : l10n.videoUploading(percent),
        ),
        LinearProgressIndicator(value: state.progress),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: state.phase == UploadPhase.paused
              ? TextButton(
                  onPressed: controller.resume,
                  child: Text(l10n.videoResume),
                )
              : TextButton(
                  onPressed: controller.pause,
                  child: Text(l10n.videoPause),
                ),
        ),
      ],
      UploadPhase.failed => [
        Text(
          failure?.message(l10n) ?? l10n.errorUnknown,
          style: TextStyle(color: context.colors.error),
        ),
        Wrap(
          spacing: spacing.sm,
          runSpacing: spacing.sm,
          children: [
            if (state.videoPath != null)
              FilledButton(
                onPressed: controller.retry,
                child: Text(l10n.actionRetry),
              ),
            OutlinedButton(
              onPressed: () => controller.pick(VideoOrigin.gallery),
              child: Text(l10n.videoChoose),
            ),
          ],
        ),
      ],
      UploadPhase.done => [
        Row(
          children: [
            Icon(
              Icons.check_circle_outline_rounded,
              color: context.colors.success,
            ),
            SizedBox(width: spacing.sm),
            Expanded(child: Text(l10n.videoUploaded)),
          ],
        ),
        pickButtons,
      ],
    };
    return Padding(
      padding: EdgeInsetsDirectional.all(spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final child in children) ...[
            child,
            if (child != children.last) SizedBox(height: spacing.sm),
          ],
        ],
      ),
    );
  }
}
