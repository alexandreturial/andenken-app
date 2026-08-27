import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';

import '../../domain/auth/auth_exception.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({fb.FirebaseAuth? auth, GoogleSignIn? googleSignIn})
    : _auth = auth ?? fb.FirebaseAuth.instance,
      _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  final fb.FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  var _googleReady = false;

  @override
  User? get currentUser => _toDomainOrNull(_auth.currentUser);

  @override
  Stream<User?> watchCurrentUser() {
    return _auth.authStateChanges().map(_toDomainOrNull);
  }

  @override
  Future<User> signIn({required String email, required String password}) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _requireUser(credential.user);
    } on AuthException {
      rethrow;
    } on fb.FirebaseAuthException catch (error) {
      _throwMapped(error);
    } catch (_) {
      throw const AuthNetworkException();
    }
  }

  @override
  Future<User> signUp({required String email, required String password}) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _requireUser(credential.user);
    } on AuthException {
      rethrow;
    } on fb.FirebaseAuthException catch (error) {
      _throwMapped(error);
    } catch (_) {
      throw const AuthNetworkException();
    }
  }

  @override
  Future<User?> signInWithGoogle() async {
    print('signInWithGoogle');

    await _ensureGoogle();
    try {
      final account = await _googleSignIn.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw const AuthNetworkException();
      }
      final credential = fb.GoogleAuthProvider.credential(idToken: idToken);
      final result = await _auth.signInWithCredential(credential);
      return _requireUser(result.user);
    } on AuthException {
      rethrow;
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled ||
          error.code == GoogleSignInExceptionCode.interrupted) {
        return null;
      }
      throw const AuthNetworkException();
    } on fb.FirebaseAuthException catch (error) {
      _throwMapped(error);
    } catch (_) {
      throw const AuthNetworkException();
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
    try {
      await _ensureGoogle();
      await _googleSignIn.signOut();
    } catch (_) {
      // Email/senha ou Google ainda não inicializado: a sessão Firebase já saiu.
    }
  }

  Future<void> _ensureGoogle() async {
    if (_googleReady) {
      return;
    }

    const webClientId = String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');
    print('webClientId: $webClientId');

    await _googleSignIn.initialize(
      serverClientId: webClientId.isEmpty ? null : webClientId,
    );
    _googleReady = true;
  }

  User _requireUser(fb.User? user) {
    if (user == null) {
      throw const InvalidCredentialsException();
    }
    return _toDomain(user);
  }

  User? _toDomainOrNull(fb.User? user) {
    if (user == null) {
      return null;
    }
    return _toDomain(user);
  }

  User _toDomain(fb.User user) {
    return User(
      id: user.uid,
      email: user.email ?? '',
      createdAt:
          user.metadata.creationTime ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    );
  }

  Never _throwMapped(fb.FirebaseAuthException error) {
    switch (error.code) {
      case 'email-already-in-use':
        throw const EmailAlreadyInUseException();
      case 'invalid-email':
        throw const InvalidEmailException();
      case 'weak-password':
        throw const WeakPasswordException();
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
      case 'invalid-login-credentials':
      case 'user-disabled':
        throw const InvalidCredentialsException();
      case 'account-exists-with-different-credential':
        throw const AccountExistsWithDifferentCredentialException();
      case 'network-request-failed':
      case 'unavailable':
      case 'timeout':
        throw const AuthNetworkException();
      default:
        throw const AuthNetworkException();
    }
  }
}
