import 'package:freezed_annotation/freezed_annotation.dart';

import 'coach_link_status.dart';

part 'coach_link.freezed.dart';

/// Связь тренера и ученика с двусторонним согласием.
@freezed
abstract class CoachLink with _$CoachLink {
  const CoachLink._();

  /// Создаёт данные связи; [invitedBy] равен uid стороны, отправившей приглашение.
  const factory CoachLink({
    required String id,
    required String coachId,
    required String athleteId,
    required String coachNickname,
    required String athleteNickname,
    required CoachLinkStatus status,
    required String invitedBy,
    DateTime? updatedAt,
  }) = _CoachLink;

  /// Id документа связи: одна пара тренер-ученик — один документ.
  static String idFor(String coachId, String athleteId) =>
      '${coachId}_$athleteId';

  /// Ждёт ли приглашение ответа пользователя [uid].
  bool isIncomingFor(String uid) =>
      status == CoachLinkStatus.pending && invitedBy != uid;

  /// uid второй стороны связи для пользователя [uid].
  String partnerId(String uid) => uid == coachId ? athleteId : coachId;

  /// Ник второй стороны связи для пользователя [uid].
  String partnerNickname(String uid) =>
      uid == coachId ? athleteNickname : coachNickname;
}
