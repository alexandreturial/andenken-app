import '../auth/auth_credentials.dart';
import '../auth/auth_exception.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SignUp {
  const SignUp(this._auth);

  final AuthRepository _auth;

  Future<User> call({
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final normalized = normalizeEmail(email);
    ensureValidEmail(normalized);
    ensureStrongPassword(password);
    if (password != passwordConfirmation) {
      throw const PasswordMismatchException();
    }
    return _auth.signUp(email: normalized, password: password);
  }
}
