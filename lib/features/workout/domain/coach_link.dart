import 'package:freezed_annotation/freezed_annotation.dart';

import 'coach_link_status.dart';

part 'coach_link.freezed.dart';

/// Связь тренера и ученика с двусторонним согласием.
@freezed
abstract class CoachLink with _$CoachLink {
  /// Создаёт данные связи; [invitedBy] равен uid стороны, отправившей приглашение.
  const factory CoachLink({
    required String id,
    required String coachId,
    required String athleteId,
    required CoachLinkStatus status,
    required String invitedBy,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _CoachLink;
}
