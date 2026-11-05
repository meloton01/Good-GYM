import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/theme_context.dart';
import '../../../../core/constants/app_limits.dart';
import '../../../../core/errors/app_failure_message.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/firebase/firestore_failure_mapper.dart';
import '../../../../core/widgets/failure_snack_bar.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../profile/domain/user_profile.dart';
import '../../data/coach_repository_providers.dart';
import '../../domain/coach_limits.dart';
import '../workout_format.dart';

/// Комментарии тренера и ученика к плану с полем нового комментария.
class PlanCommentsSection extends ConsumerStatefulWidget {
  /// Создаёт комментарии к плану [planId] ученика [athleteId] от имени [me].
  const PlanCommentsSection({
    super.key,
    required this.athleteId,
    required this.planId,
    required this.me,
    required this.format,
  });

  final String athleteId;
  final String planId;
  final UserProfile me;
  final WorkoutFormat format;

  /// Создаёт состояние блока.
  @override
  ConsumerState<PlanCommentsSection> createState() =>
      _PlanCommentsSectionState();
}

/// Хранит поле ввода, лимит загрузки и флаг отправки.
class _PlanCommentsSectionState extends ConsumerState<PlanCommentsSection> {
  final _text = TextEditingController();
  int _limit = AppLimits.pageSize;
  bool _sending = false;

  /// Освобождает контроллер поля.
  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  /// Строит поле, комментарии и кнопку «Показать ещё».
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final comments = ref.watch(
      planCommentsProvider((widget.athleteId, widget.planId, _limit)),
    );
    final items = comments.value ?? const [];
    final secondary = TextStyle(color: context.colors.textSecondary);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title: l10n.coachCommentsTitle),
        Padding(
          padding: EdgeInsetsDirectional.symmetric(
            horizontal: context.spacing.md,
          ),
          child: TextField(
            controller: _text,
            minLines: 1,
            maxLines: 4,
            maxLength: CoachLimits.commentMaxLength,
            decoration: InputDecoration(
              labelText: l10n.coachCommentLabel,
              suffixIcon: IconButton(
                tooltip: l10n.coachCommentSend,
                icon: const Icon(Icons.send_rounded),
                onPressed: _sending ? null : _send,
              ),
            ),
          ),
        ),
        if (comments.hasError)
          ListTile(
            title: Text(
              failureFromError(comments.error).message(l10n),
              style: secondary,
            ),
          )
        else if (comments.hasValue && items.isEmpty)
          ListTile(title: Text(l10n.coachCommentsEmpty, style: secondary)),
        for (final comment in items)
          ListTile(
            title: Text(comment.text),
            subtitle: Text(
              comment.createdAt == null
                  ? comment.authorNickname
                  : l10n.coachCommentMeta(
                      comment.authorNickname,
                      widget.format.dateTime(comment.createdAt!),
                    ),
            ),
          ),
        if (items.length >= _limit)
          TextButton(
            onPressed: () => setState(() => _limit += AppLimits.pageSize),
            child: Text(l10n.actionShowMore),
          ),
      ],
    );
  }

  /// Отправляет комментарий и очищает поле.
  Future<void> _send() async {
    final text = _text.text.trim();
    if (text.isEmpty) {
      return;
    }
    setState(() => _sending = true);
    final result = await ref
        .read(coachPlanRepositoryProvider)
        .addComment(
          widget.athleteId,
          widget.planId,
          authorId: widget.me.uid,
          authorNickname: widget.me.nickname,
          text: text,
        );
    if (!mounted) {
      return;
    }
    setState(() => _sending = false);
    switch (result) {
      case Success():
        _text.clear();
      case Failure(:final failure):
        showFailureSnackBar(context, failure, onRetry: _send);
    }
  }
}
