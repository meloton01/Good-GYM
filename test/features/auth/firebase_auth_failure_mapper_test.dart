import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:good_gym/core/errors/app_failure.dart';
import 'package:good_gym/features/auth/data/firebase_auth_failure_mapper.dart';

void main() {
  AppFailure map(String code) =>
      mapFirebaseAuthFailure(FirebaseAuthException(code: code));

  test('does not reveal whether the email or the password was wrong', () {
    expect(map('wrong-password'), AppFailure.invalidCredentials);
    expect(map('user-not-found'), AppFailure.invalidCredentials);
    expect(map('invalid-credential'), AppFailure.invalidCredentials);
  });

  test('maps registration and rate limit errors', () {
    expect(map('email-already-in-use'), AppFailure.emailAlreadyInUse);
    expect(map('weak-password'), AppFailure.weakPassword);
    expect(map('too-many-requests'), AppFailure.tooManyRequests);
    expect(map('network-request-failed'), AppFailure.network);
  });

  test('treats unknown codes as unknown', () {
    expect(map('something-new'), AppFailure.unknown);
  });
}
