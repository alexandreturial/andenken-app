import 'package:flutter/foundation.dart';

import '../../domain/auth/auth_exception.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/sign_in.dart';
import '../../domain/usecases/sign_in_with_google.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/sign_up.dart';

enum AuthStatus { idle, loading, success, error }

class AuthViewState {
  const AuthViewState({this.status = AuthStatus.idle, this.user, this.error});

  final AuthStatus status;
  final User? user;
  final AuthException? error;
}

class AuthNotifier extends ValueNotifier<AuthViewState> {
  AuthNotifier({
    required this._signIn,
    required this._signUp,
    required this._signOut,
    required this._signInWithGoogle,
  }) : super(const AuthViewState());

  final SignIn _signIn;
  final SignUp _signUp;
  final SignOut _signOut;
  final SignInWithGoogle _signInWithGoogle;

  Future<void> signIn({required String email, required String password}) {
    return _run(() => _signIn(email: email, password: password));
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String passwordConfirmation,
  }) {
    return _run(
      () => _signUp(
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      ),
    );
  }

  Future<void> signInWithGoogle() async {
    value = const AuthViewState(status: AuthStatus.loading);
    try {
      final user = await _signInWithGoogle();

      if (user == null) {
        value = const AuthViewState();
        return;
      }
      value = AuthViewState(status: AuthStatus.success, user: user);
    } on AuthException catch (error) {
      value = AuthViewState(status: AuthStatus.error, error: error);
    } catch (_) {
      value = const AuthViewState(
        status: AuthStatus.error,
        error: AuthNetworkException(),
      );
    }
  }

  Future<void> signOut() async {
    value = const AuthViewState(status: AuthStatus.loading);
    try {
      await _signOut();
      value = const AuthViewState();
    } on AuthException catch (error) {
      value = AuthViewState(status: AuthStatus.error, error: error);
    } catch (_) {
      value = const AuthViewState(
        status: AuthStatus.error,
        error: AuthNetworkException(),
      );
    }
  }

  Future<void> _run(Future<User> Function() action) async {
    value = const AuthViewState(status: AuthStatus.loading);
    try {
      final user = await action();
      value = AuthViewState(status: AuthStatus.success, user: user);
    } on AuthException catch (error) {
      value = AuthViewState(status: AuthStatus.error, error: error);
    } catch (_) {
      value = const AuthViewState(
        status: AuthStatus.error,
        error: AuthNetworkException(),
      );
    }
  }
}
