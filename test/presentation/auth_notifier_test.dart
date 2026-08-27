import 'package:andenken_app/domain/auth/auth_exception.dart';
import 'package:andenken_app/presentation/auth/auth_notifier.dart';
import 'package:andenken_app/domain/usecases/sign_in.dart';
import 'package:andenken_app/domain/usecases/sign_in_with_google.dart';
import 'package:andenken_app/domain/usecases/sign_out.dart';
import 'package:andenken_app/domain/usecases/sign_up.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_auth_repository.dart';

void main() {
  late FakeAuthRepository auth;
  late AuthNotifier notifier;

  setUp(() {
    auth = FakeAuthRepository();
    notifier = AuthNotifier(
      signIn: SignIn(auth),
      signUp: SignUp(auth),
      signOut: SignOut(auth),
      signInWithGoogle: SignInWithGoogle(auth),
    );
  });

  tearDown(() => notifier.dispose());

  List<AuthStatus> captureStatuses() {
    final statuses = <AuthStatus>[];
    notifier.addListener(() => statuses.add(notifier.value.status));
    return statuses;
  }

  test('começa em idle', () {
    expect(notifier.value.status, AuthStatus.idle);
    expect(notifier.value.user, isNull);
    expect(notifier.value.error, isNull);
  });

  test('signIn sucesso passa por loading e termina em success', () async {
    await auth.signUp(email: 'alex@example.com', password: 'secret1');
    await auth.signOut();
    final statuses = captureStatuses();

    await notifier.signIn(email: 'alex@example.com', password: 'secret1');

    expect(statuses, [AuthStatus.loading, AuthStatus.success]);
    expect(notifier.value.user?.email, 'alex@example.com');
    expect(notifier.value.error, isNull);
  });

  test('signIn com credencial inválida vai para error', () async {
    await auth.signUp(email: 'alex@example.com', password: 'secret1');
    await auth.signOut();
    final statuses = captureStatuses();

    await notifier.signIn(
      email: 'alex@example.com',
      password: 'wrong-password',
    );

    expect(statuses, [AuthStatus.loading, AuthStatus.error]);
    expect(notifier.value.error, isA<InvalidCredentialsException>());
    expect(notifier.value.user, isNull);
  });

  test('signUp sucesso autentica', () async {
    await notifier.signUp(
      email: 'alex@example.com',
      password: 'secret1',
      passwordConfirmation: 'secret1',
    );

    expect(notifier.value.status, AuthStatus.success);
    expect(notifier.value.user?.email, 'alex@example.com');
  });

  test('signUp com senhas diferentes vai para error', () async {
    await notifier.signUp(
      email: 'alex@example.com',
      password: 'secret1',
      passwordConfirmation: 'secret2',
    );

    expect(notifier.value.status, AuthStatus.error);
    expect(notifier.value.error, isA<PasswordMismatchException>());
  });

  test('signIn com falha de rede vai para error', () async {
    auth.forcedSignInError = const AuthNetworkException();
    final statuses = captureStatuses();

    await notifier.signIn(email: 'alex@example.com', password: 'secret1');

    expect(statuses, [AuthStatus.loading, AuthStatus.error]);
    expect(notifier.value.error, isA<AuthNetworkException>());
    expect(notifier.value.user, isNull);
  });

  test('signOut volta para idle', () async {
    await notifier.signUp(
      email: 'alex@example.com',
      password: 'secret1',
      passwordConfirmation: 'secret1',
    );

    await notifier.signOut();

    expect(notifier.value.status, AuthStatus.idle);
    expect(notifier.value.user, isNull);
    expect(notifier.value.error, isNull);
  });

  test(
    'signInWithGoogle sucesso passa por loading e termina em success',
    () async {
      final statuses = captureStatuses();

      await notifier.signInWithGoogle();

      expect(statuses, [AuthStatus.loading, AuthStatus.success]);
      expect(notifier.value.user?.email, 'alex.google@example.com');
      expect(notifier.value.error, isNull);
    },
  );

  test('signInWithGoogle cancelado volta para idle sem erro', () async {
    auth.cancelGoogleSignIn = true;
    final statuses = captureStatuses();

    await notifier.signInWithGoogle();

    expect(statuses, [AuthStatus.loading, AuthStatus.idle]);
    expect(notifier.value.user, isNull);
    expect(notifier.value.error, isNull);
  });
}
