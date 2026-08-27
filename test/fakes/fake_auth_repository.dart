import 'dart:async';

import 'package:andenken_app/domain/auth/auth_exception.dart';
import 'package:andenken_app/domain/entities/user.dart';
import 'package:andenken_app/domain/repositories/auth_repository.dart';

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository();

  User? _current;
  final Map<String, _Account> _accounts = {};
  final StreamController<User?> _controller =
      StreamController<User?>.broadcast();

  @override
  User? get currentUser => _current;

  @override
  Stream<User?> watchCurrentUser() async* {
    yield _current;
    yield* _controller.stream;
  }

  AuthException? forcedSignInError;
  AuthException? forcedGoogleError;
  bool cancelGoogleSignIn = false;
  String googleEmail = 'alex.google@example.com';

  @override
  Future<User> signIn({required String email, required String password}) async {
    final forced = forcedSignInError;
    if (forced != null) {
      throw forced;
    }
    final account = _accounts[email];
    if (account == null ||
        account.provider != _AuthProvider.password ||
        account.password != password) {
      throw const InvalidCredentialsException();
    }
    _current = account.user;
    _controller.add(_current);
    return account.user;
  }

  @override
  Future<User> signUp({required String email, required String password}) async {
    if (_accounts.containsKey(email)) {
      throw const EmailAlreadyInUseException();
    }
    final user = User(
      id: 'uid-$email',
      email: email,
      createdAt: DateTime.utc(2026, 1, 1),
    );
    _accounts[email] = _Account(
      user: user,
      password: password,
      provider: _AuthProvider.password,
    );
    _current = user;
    _controller.add(_current);
    return user;
  }

  @override
  Future<User?> signInWithGoogle() async {
    final forced = forcedGoogleError;
    if (forced != null) {
      throw forced;
    }
    if (cancelGoogleSignIn) {
      return null;
    }
    final existing = _accounts[googleEmail];
    if (existing != null) {
      if (existing.provider == _AuthProvider.password) {
        throw const AccountExistsWithDifferentCredentialException();
      }
      _current = existing.user;
      _controller.add(_current);
      return existing.user;
    }
    final user = User(
      id: 'uid-$googleEmail',
      email: googleEmail,
      createdAt: DateTime.utc(2026, 1, 1),
    );
    _accounts[googleEmail] = _Account(
      user: user,
      provider: _AuthProvider.google,
    );
    _current = user;
    _controller.add(_current);
    return user;
  }

  @override
  Future<void> signOut() async {
    _current = null;
    _controller.add(null);
  }
}

enum _AuthProvider { password, google }

class _Account {
  const _Account({required this.user, this.password, required this.provider});

  final User user;
  final String? password;
  final _AuthProvider provider;
}
