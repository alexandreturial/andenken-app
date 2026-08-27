import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SignInWithGoogle {
  const SignInWithGoogle(this._auth);

  final AuthRepository _auth;

  /// `null` = seletor cancelado (RN-A05).
  Future<User?> call() => _auth.signInWithGoogle();
}
