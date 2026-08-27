import '../repositories/auth_repository.dart';

class SignOut {
  const SignOut(this._auth);

  final AuthRepository _auth;

  Future<void> call() => _auth.signOut();
}
