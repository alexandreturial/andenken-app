import '../entities/user.dart';

abstract class AuthRepository {
  User? get currentUser;

  Stream<User?> watchCurrentUser();

  Future<User> signIn({required String email, required String password});

  Future<User> signUp({required String email, required String password});

  /// `null` se o User cancelou o seletor (RN-A05).
  Future<User?> signInWithGoogle();

  Future<void> signOut();
}
