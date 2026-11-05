import 'package:freezed_annotation/freezed_annotation.dart';

part 'plan_comment.freezed.dart';

/// Комментарий тренера или ученика к плану.
@freezed
abstract class PlanComment with _$PlanComment {
  /// Создаёт комментарий; [createdAt] null, пока сервер не поставил время.
  const factory PlanComment({
    required String id,
    required String authorId,
    required String authorNickname,
    required String text,
    DateTime? createdAt,
  }) = _PlanComment;
}
