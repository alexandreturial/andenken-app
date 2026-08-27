/// Falhas de Auth no domínio. Login inválido não distingue email inexistente (RN-A02).
abstract class AuthException implements Exception {
  const AuthException();
}

class InvalidEmailException extends AuthException {
  const InvalidEmailException();
}

class WeakPasswordException extends AuthException {
  const WeakPasswordException();
}

class PasswordMismatchException extends AuthException {
  const PasswordMismatchException();
}

class InvalidCredentialsException extends AuthException {
  const InvalidCredentialsException();
}

class EmailAlreadyInUseException extends AuthException {
  const EmailAlreadyInUseException();
}

class AuthNetworkException extends AuthException {
  const AuthNetworkException();
}

class AccountExistsWithDifferentCredentialException extends AuthException {
  const AccountExistsWithDifferentCredentialException();
}
