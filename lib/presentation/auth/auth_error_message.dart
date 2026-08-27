import '../../domain/auth/auth_exception.dart';

/// Mensagens de UI. Credencial inválida não revela se o email existe (RN-A02).
String messageForAuthException(AuthException error) {
  if (error is InvalidCredentialsException) {
    return 'Email ou senha incorretos.';
  }
  if (error is InvalidEmailException) {
    return 'Informe um email válido.';
  }
  if (error is WeakPasswordException) {
    return 'A senha deve ter pelo menos 6 caracteres.';
  }
  if (error is PasswordMismatchException) {
    return 'As senhas não coincidem.';
  }
  if (error is EmailAlreadyInUseException) {
    return 'Este email já está em uso.';
  }
  if (error is AuthNetworkException) {
    return 'Não foi possível conectar. Verifique a rede.';
  }
  if (error is AccountExistsWithDifferentCredentialException) {
    return 'Este email já tem conta com senha. Entre com email e senha.';
  }
  return 'Não foi possível continuar. Tente de novo.';
}
