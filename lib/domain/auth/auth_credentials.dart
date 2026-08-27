import 'auth_exception.dart';

final _emailPattern = RegExp(r'^[^@]+@[^@]+\.[^@]+$');

String normalizeEmail(String email) => email.trim();

void ensureValidEmail(String email) {
  if (!_emailPattern.hasMatch(email)) {
    throw const InvalidEmailException();
  }
}

void ensureStrongPassword(String password) {
  if (password.length < 6) {
    throw const WeakPasswordException();
  }
}
