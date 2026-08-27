import '../auth/auth_credentials.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SignIn {
  const SignIn(this._auth);

  final AuthRepository _auth;

  Future<User> call({required String email, required String password}) {
    final normalized = normalizeEmail(email);
    ensureValidEmail(normalized);
    return _auth.signIn(email: normalized, password: password);
  }
}
