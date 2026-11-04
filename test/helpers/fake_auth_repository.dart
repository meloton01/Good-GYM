import 'dart:async';

import 'package:good_gym/core/errors/result.dart';
import 'package:good_gym/features/auth/domain/auth_repository.dart';
import 'package:good_gym/features/auth/domain/auth_user.dart';

/// Тестовый репозиторий авторизации с управляемым состоянием в памяти.
class FakeAuthRepository implements AuthRepository {
  /// Создаёт репозиторий с начальной учётной записью [user].
  FakeAuthRepository({AuthUser? user}) {
    _user = user;
  }

  final _controller = StreamController<AuthUser?>.broadcast();
  AuthUser? _user;

  /// Результат, который вернут операции входа и регистрации.
  Result<void> nextResult = const Success(null);

  /// Учётная запись, под которой выполнит вход успешный signIn или signUp.
  AuthUser signedInUser = const AuthUser(
    uid: 'uid-1',
    email: 'athlete@example.com',
    emailVerified: true,
    usesPassword: true,
  );

  final List<String> calls = [];

  /// Меняет текущую учётную запись и оповещает подписчиков.
  void emit(AuthUser? user) {
    _user = user;
    _controller.add(user);
  }

  @override
  Stream<AuthUser?> watchAuthUser() async* {
    yield _user;
    yield* _controller.stream;
  }

  @override
  Future<Result<void>> signInWithEmail({
    required String email,
    required String password,
  }) => _signIn('signInWithEmail:$email');

  @override
  Future<Result<void>> signUpWithEmail({
    required String email,
    required String password,
    required String languageCode,
  }) => _signIn('signUpWithEmail:$email:$languageCode');

  @override
  Future<Result<void>> signInWithGoogle() => _signIn('signInWithGoogle');

  @override
  Future<Result<void>> signInWithApple() => _signIn('signInWithApple');

  @override
  Future<Result<void>> sendEmailVerification({
    required String languageCode,
  }) async {
    calls.add('sendEmailVerification:$languageCode');
    return const Success(null);
  }

  @override
  Future<Result<bool>> reloadEmailVerification() async {
    calls.add('reloadEmailVerification');
    return Success(_user?.emailVerified ?? false);
  }

  @override
  Future<Result<void>> sendPasswordReset(
    String email, {
    required String languageCode,
  }) async {
    calls.add('sendPasswordReset:$email:$languageCode');
    return nextResult;
  }

  @override
  Future<Result<void>> signOut() async {
    calls.add('signOut');
    emit(null);
    return const Success(null);
  }

  /// Записывает вызов и при успехе выполняет вход.
  Future<Result<void>> _signIn(String call) async {
    calls.add(call);
    if (nextResult is Success<void>) {
      emit(signedInUser);
    }
    return nextResult;
  }
}
