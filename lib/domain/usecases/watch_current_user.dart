import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class WatchCurrentUser {
  const WatchCurrentUser(this._auth);

  final AuthRepository _auth;

  Stream<User?> call() => _auth.watchCurrentUser();
}
