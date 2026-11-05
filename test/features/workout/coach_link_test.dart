import 'package:flutter_test/flutter_test.dart';
import 'package:good_gym/features/workout/data/coach_link_mapper.dart';
import 'package:good_gym/features/workout/domain/coach_link.dart';
import 'package:good_gym/features/workout/domain/coach_link_status.dart';

void main() {
  const invite = CoachLink(
    id: 'coach_student',
    coachId: 'coach',
    athleteId: 'student',
    coachNickname: 'coach.max',
    athleteNickname: 'stu.ann',
    status: CoachLinkStatus.pending,
    invitedBy: 'coach',
  );

  test('one document per coach and student pair', () {
    expect(CoachLink.idFor('coach', 'student'), 'coach_student');
    expect(
      CoachLink.idFor('coach', 'student'),
      isNot(CoachLink.idFor('student', 'coach')),
    );
  });

  test('invite waits for the other side only', () {
    expect(invite.isIncomingFor('student'), isTrue);
    expect(invite.isIncomingFor('coach'), isFalse);
    final fromStudent = invite.copyWith(invitedBy: 'student');
    expect(fromStudent.isIncomingFor('coach'), isTrue);
    expect(fromStudent.isIncomingFor('student'), isFalse);
  });

  test('active and ended links are not incoming invites', () {
    for (final status in [CoachLinkStatus.active, CoachLinkStatus.ended]) {
      expect(invite.copyWith(status: status).isIncomingFor('student'), isFalse);
    }
  });

  test('partner is the other side for both sides', () {
    expect(invite.partnerId('coach'), 'student');
    expect(invite.partnerId('student'), 'coach');
    expect(invite.partnerNickname('coach'), 'stu.ann');
    expect(invite.partnerNickname('student'), 'coach.max');
  });

  test('mapper reads every status and skips damaged links', () {
    Map<String, dynamic> stored(Object? status) => {
      'coachId': 'coach',
      'athleteId': 'student',
      'coachNickname': 'coach.max',
      'athleteNickname': 'stu.ann',
      'invitedBy': 'coach',
      'status': status,
    };
    for (final status in CoachLinkStatus.values) {
      final link = CoachLinkMapper.fromMap(
        'coach_student',
        stored(status.name),
      );
      expect(link?.status, status);
    }
    expect(
      CoachLinkMapper.fromMap('coach_student', stored('approved')),
      isNull,
    );
    expect(CoachLinkMapper.fromMap('coach_student', stored(null)), isNull);
    expect(
      CoachLinkMapper.fromMap('coach_student', {
        ...stored('active'),
        'coachId': 1,
      }),
      isNull,
    );
  });
}
