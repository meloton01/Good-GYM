import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Получает idToken Google для входа и повторного подтверждения в Firebase.
class GoogleIdTokenSource {
  /// Создаёт источник поверх экземпляра Google Sign-In.
  GoogleIdTokenSource(this._googleSignIn);

  final GoogleSignIn _googleSignIn;
  Future<void>? _initialization;

  /// Показывает выбор аккаунта Google и возвращает учётные данные для Firebase.
  Future<AuthCredential> credential() async {
    await (_initialization ??= _googleSignIn.initialize());
    final account = await _googleSignIn.authenticate();
    final idToken = account.authentication.idToken;
    if (idToken == null) {
      throw FirebaseAuthException(code: 'invalid-credential');
    }
    return GoogleAuthProvider.credential(idToken: idToken);
  }

  /// Выходит из Google, если вход через него уже был, чтобы в следующий раз был выбор аккаунта.
  Future<void> signOut() async {
    if (_initialization != null) {
      await _googleSignIn.signOut();
    }
  }
}
