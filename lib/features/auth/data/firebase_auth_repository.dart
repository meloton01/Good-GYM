import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/errors/app_failure.dart';
import '../../../core/errors/result.dart';
import '../domain/auth_repository.dart';
import '../domain/auth_user.dart';
import 'firebase_auth_failure_mapper.dart';

/// Реализация входа и регистрации на Firebase Auth.
class FirebaseAuthRepository implements AuthRepository {
  /// Создаёт репозиторий поверх экземпляров Firebase Auth и Google Sign-In.
  FirebaseAuthRepository(this._auth, this._googleSignIn);

  static const String _passwordProviderId = 'password';

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  Future<void>? _googleInitialization;

  /// Поток учётной записи; userChanges срабатывает и после reload.
  @override
  Stream<AuthUser?> watchAuthUser() => _auth.userChanges().map(_toAuthUser);

  /// Вход по email и паролю.
  @override
  Future<Result<void>> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _guard(
      () => _auth.signInWithEmailAndPassword(email: email, password: password),
    );
  }

  /// Регистрация и отправка письма для подтверждения на языке интерфейса.
  @override
  Future<Result<void>> signUpWithEmail({
    required String email,
    required String password,
    required String languageCode,
  }) {
    return _guard(() async {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _auth.setLanguageCode(languageCode);
      await credential.user?.sendEmailVerification();
    });
  }

  /// Вход через Google: получает idToken и обменивает его на сессию Firebase.
  @override
  Future<Result<void>> signInWithGoogle() {
    return _guard(() async {
      await (_googleInitialization ??= _googleSignIn.initialize());
      final account = await _googleSignIn.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) {
        throw FirebaseAuthException(code: 'invalid-credential');
      }
      await _auth.signInWithCredential(
        GoogleAuthProvider.credential(idToken: idToken),
      );
    });
  }

  /// Вход через Apple средствами Firebase Auth.
  @override
  Future<Result<void>> signInWithApple() {
    final provider = AppleAuthProvider()..addScope('email');
    return _guard(() => _auth.signInWithProvider(provider));
  }

  /// Повторно отправляет письмо для подтверждения email.
  @override
  Future<Result<void>> sendEmailVerification({required String languageCode}) {
    return _guard(() async {
      await _auth.setLanguageCode(languageCode);
      await _auth.currentUser?.sendEmailVerification();
    });
  }

  /// Перечитывает пользователя и возвращает статус подтверждения email.
  @override
  Future<Result<bool>> reloadEmailVerification() {
    return _guard(() async {
      await _auth.currentUser?.reload();
      return _auth.currentUser?.emailVerified ?? false;
    });
  }

  /// Отправляет письмо для сброса пароля на языке интерфейса.
  @override
  Future<Result<void>> sendPasswordReset(
    String email, {
    required String languageCode,
  }) {
    return _guard(() async {
      await _auth.setLanguageCode(languageCode);
      await _auth.sendPasswordResetEmail(email: email);
    });
  }

  /// Выходит из Firebase и из Google, чтобы при следующем входе был выбор аккаунта.
  @override
  Future<Result<void>> signOut() {
    return _guard(() async {
      if (_googleInitialization != null) {
        await _googleSignIn.signOut();
      }
      await _auth.signOut();
    });
  }

  /// Переводит пользователя Firebase в модель приложения.
  AuthUser? _toAuthUser(User? user) {
    if (user == null) {
      return null;
    }
    return AuthUser(
      uid: user.uid,
      email: user.email,
      emailVerified: user.emailVerified,
      usesPassword: user.providerData.any(
        (info) => info.providerId == _passwordProviderId,
      ),
    );
  }

  /// Выполняет операцию и переводит исключения Firebase и Google в [AppFailure].
  Future<Result<T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Success(await action());
    } on FirebaseAuthException catch (error) {
      return Failure(mapFirebaseAuthFailure(error), cause: error);
    } on GoogleSignInException catch (error) {
      return Failure(_mapGoogleFailure(error.code), cause: error);
    } on Exception catch (error) {
      return Failure(AppFailure.unknown, cause: error);
    }
  }

  /// Переводит код ошибки Google Sign-In в ошибку приложения.
  AppFailure _mapGoogleFailure(GoogleSignInExceptionCode code) {
    return switch (code) {
      GoogleSignInExceptionCode.canceled ||
      GoogleSignInExceptionCode.interrupted => AppFailure.cancelled,
      GoogleSignInExceptionCode.clientConfigurationError ||
      GoogleSignInExceptionCode.providerConfigurationError ||
      GoogleSignInExceptionCode.uiUnavailable => AppFailure.providerUnavailable,
      _ => AppFailure.unknown,
    };
  }
}
