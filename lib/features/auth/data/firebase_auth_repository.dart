import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/errors/app_failure.dart';
import '../../../core/errors/result.dart';
import '../domain/auth_repository.dart';
import '../domain/auth_user.dart';
import 'firebase_auth_failure_mapper.dart';
import 'google_id_token_source.dart';

/// Реализация входа, регистрации и управления аккаунтом на Firebase Auth.
class FirebaseAuthRepository implements AuthRepository {
  /// Создаёт репозиторий поверх Firebase Auth и источника токена Google.
  FirebaseAuthRepository(this._auth, this._google);

  static const String _passwordProviderId = 'password';
  static const String _appleProviderId = 'apple.com';

  final FirebaseAuth _auth;
  final GoogleIdTokenSource _google;

  /// Поток учётной записи; userChanges срабатывает и после reload.
  @override
  Stream<AuthUser?> watchAuthUser() =>
      _auth.userChanges().asyncMap(_syncVerifiedToken).map(_toAuthUser);

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

  /// Вход через Google: обменивает idToken на сессию Firebase.
  @override
  Future<Result<void>> signInWithGoogle() {
    return _guard(
      () async => _auth.signInWithCredential(await _google.credential()),
    );
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
      final user = _auth.currentUser;
      if (user == null || !user.emailVerified) {
        return false;
      }
      await user.getIdToken(true);
      return true;
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

  /// Выходит из Firebase и из Google.
  @override
  Future<Result<void>> signOut() {
    return _guard(() async {
      await _google.signOut();
      await _auth.signOut();
    });
  }

  /// Подтверждает личность паролем, а без пароля — повторным входом через Apple или Google.
  @override
  Future<Result<void>> reauthenticate({String? password}) {
    return _guard(() async {
      final user = _requireUser();
      final email = user.email;
      if (password != null && email != null) {
        await user.reauthenticateWithCredential(
          EmailAuthProvider.credential(email: email, password: password),
        );
      } else if (user.providerData.any(
        (info) => info.providerId == _appleProviderId,
      )) {
        await user.reauthenticateWithProvider(AppleAuthProvider());
      } else {
        await user.reauthenticateWithCredential(await _google.credential());
      }
    });
  }

  /// Меняет пароль текущего пользователя.
  @override
  Future<Result<void>> changePassword(String newPassword) {
    return _guard(() => _requireUser().updatePassword(newPassword));
  }

  /// Отправляет подтверждение на новый email на языке интерфейса.
  @override
  Future<Result<void>> changeEmail(
    String newEmail, {
    required String languageCode,
  }) {
    return _guard(() async {
      await _auth.setLanguageCode(languageCode);
      await _requireUser().verifyBeforeUpdateEmail(newEmail);
    });
  }

  /// Удаляет учётную запись и выходит из Google.
  @override
  Future<Result<void>> deleteAccount() {
    return _guard(() async {
      await _requireUser().delete();
      await _google.signOut();
    });
  }

  /// Текущий пользователь; без входа бросает ошибку, которая станет permissionDenied.
  User _requireUser() {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(code: 'user-disabled');
    }
    return user;
  }

  /// Обновляет токен, если email подтверждён, а в токене старый статус: правила Firestore читают токен.
  Future<User?> _syncVerifiedToken(User? user) async {
    if (user == null || !user.emailVerified) {
      return user;
    }
    final token = await user.getIdTokenResult();
    if (token.claims?['email_verified'] != true) {
      await user.getIdToken(true);
    }
    return user;
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
      return Failure(mapGoogleSignInFailure(error.code), cause: error);
    } on Exception catch (error) {
      return Failure(AppFailure.unknown, cause: error);
    }
  }
}
