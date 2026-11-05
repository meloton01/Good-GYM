import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../../../app/theme/theme_context.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/errors/app_failure_message.dart';
import '../../../core/errors/result.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../data/record_repository_providers.dart';

/// Видео рекорда; ссылка и плеер загружаются только по нажатию.
class RecordVideoPlayer extends ConsumerStatefulWidget {
  /// Создаёт плеер для рекорда [recordId].
  const RecordVideoPlayer({super.key, required this.recordId});

  final String recordId;

  /// Создаёт состояние плеера.
  @override
  ConsumerState<RecordVideoPlayer> createState() => _RecordVideoPlayerState();
}

/// Хранит контроллер видео, флаг загрузки и ошибку.
class _RecordVideoPlayerState extends ConsumerState<RecordVideoPlayer> {
  VideoPlayerController? _controller;
  bool _loading = false;
  AppFailure? _failure;

  /// Освобождает плеер.
  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  /// Строит кнопку запуска, загрузку, ошибку или само видео.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = _controller;
    final failure = _failure;
    if (controller != null && controller.value.isInitialized) {
      return Column(
        children: [
          AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: VideoPlayer(controller),
          ),
          ValueListenableBuilder(
            valueListenable: controller,
            builder: (context, value, _) => IconButton(
              tooltip: value.isPlaying ? l10n.videoPause : l10n.videoPlay,
              icon: Icon(
                value.isPlaying
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
              ),
              onPressed: value.isPlaying ? controller.pause : controller.play,
            ),
          ),
        ],
      );
    }
    if (_loading) {
      return const LoadingView();
    }
    return Padding(
      padding: EdgeInsetsDirectional.all(context.spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (failure != null) ...[
            Text(
              failure.message(l10n),
              style: TextStyle(color: context.colors.error),
            ),
            SizedBox(height: context.spacing.sm),
          ],
          OutlinedButton.icon(
            onPressed: _open,
            icon: const Icon(Icons.play_circle_outline_rounded),
            label: Text(failure == null ? l10n.videoOpen : l10n.actionRetry),
          ),
        ],
      ),
    );
  }

  /// Получает временную ссылку и готовит плеер.
  Future<void> _open() async {
    setState(() {
      _loading = true;
      _failure = null;
    });
    final result = await ref
        .read(recordRepositoryProvider)
        .videoUrl(widget.recordId);
    if (!mounted) {
      return;
    }
    switch (result) {
      case Success(:final value):
        final controller = VideoPlayerController.networkUrl(value);
        try {
          await controller.initialize();
        } on Exception catch (_) {
          await controller.dispose();
          if (mounted) {
            setState(() {
              _loading = false;
              _failure = AppFailure.network;
            });
          }
          return;
        }
        if (!mounted) {
          await controller.dispose();
          return;
        }
        setState(() {
          _controller = controller;
          _loading = false;
        });
      case Failure(:final failure):
        setState(() {
          _loading = false;
          _failure = failure;
        });
    }
  }
}
