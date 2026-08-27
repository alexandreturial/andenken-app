import 'package:andenken_app/domain/auth/auth_exception.dart';
import 'package:andenken_app/domain/usecases/sign_in.dart';
import 'package:andenken_app/domain/usecases/sign_out.dart';
import 'package:andenken_app/domain/usecases/sign_in_with_google.dart';
import 'package:andenken_app/domain/usecases/sign_up.dart';
import 'package:andenken_app/domain/usecases/watch_current_user.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/fake_auth_repository.dart';

void main() {
  late FakeAuthRepository auth;

  setUp(() {
    auth = FakeAuthRepository();
  });

  group('SignUp (US-01, RN-A01)', () {
    test('email válido, senha >= 6 e confirmação igual autenticam', () async {
      final signUp = SignUp(auth);

      final user = await signUp(
        email: '  alex@example.com  ',
        password: 'secret1',
        passwordConfirmation: 'secret1',
      );

      expect(user.email, 'alex@example.com');
      expect(await auth.watchCurrentUser().first, same(user));
    });

    test('email inválido não chama o repositório', () async {
      final signUp = SignUp(auth);

      await expectLater(
        () => signUp(
          email: 'nao-e-email',
          password: 'secret1',
          passwordConfirmation: 'secret1',
        ),
        throwsA(isA<InvalidEmailException>()),
      );
      expect(await auth.watchCurrentUser().first, isNull);
    });

    test('senha com menos de 6 caracteres é rejeitada', () async {
      final signUp = SignUp(auth);

      await expectLater(
        () => signUp(
          email: 'alex@example.com',
          password: '12345',
          passwordConfirmation: '12345',
        ),
        throwsA(isA<WeakPasswordException>()),
      );
    });

    test('confirmação diferente bloqueia o cadastro', () async {
      final signUp = SignUp(auth);

      await expectLater(
        () => signUp(
          email: 'alex@example.com',
          password: 'secret1',
          passwordConfirmation: 'secret2',
        ),
        throwsA(isA<PasswordMismatchException>()),
      );
    });

    test('email já cadastrado mostra erro inteligível', () async {
      await auth.signUp(email: 'alex@example.com', password: 'secret1');
      await auth.signOut();
      final signUp = SignUp(auth);

      await expectLater(
        () => signUp(
          email: 'alex@example.com',
          password: 'secret1',
          passwordConfirmation: 'secret1',
        ),
        throwsA(isA<EmailAlreadyInUseException>()),
      );
    });
  });

  group('SignIn (US-02, RN-A02)', () {
    test('credencial válida autentica', () async {
      await auth.signUp(email: 'alex@example.com', password: 'secret1');
      await auth.signOut();
      final signIn = SignIn(auth);

      final user = await signIn(email: 'alex@example.com', password: 'secret1');

      expect(user.email, 'alex@example.com');
      expect(await auth.watchCurrentUser().first, same(user));
    });

    test('senha errada e email inexistente usam o mesmo erro', () async {
      await auth.signUp(email: 'alex@example.com', password: 'secret1');
      await auth.signOut();
      final signIn = SignIn(auth);

      await expectLater(
        () => signIn(email: 'alex@example.com', password: 'wrong-password'),
        throwsA(isA<InvalidCredentialsException>()),
      );
      await expectLater(
        () => signIn(email: 'outro@example.com', password: 'secret1'),
        throwsA(isA<InvalidCredentialsException>()),
      );
      expect(await auth.watchCurrentUser().first, isNull);
    });
  });

  group('SignOut (US-02)', () {
    test('encerra a sessão', () async {
      await auth.signUp(email: 'alex@example.com', password: 'secret1');
      final signOut = SignOut(auth);

      await signOut();

      expect(await auth.watchCurrentUser().first, isNull);
    });
  });

  group('SignInWithGoogle (RN-A05)', () {
    test('primeira vez cria a conta e autentica', () async {
      final signInWithGoogle = SignInWithGoogle(auth);

      final user = await signInWithGoogle();

      expect(user?.email, 'alex.google@example.com');
      expect(await auth.watchCurrentUser().first, same(user));
    });

    test('segunda vez entra na mesma conta', () async {
      final signInWithGoogle = SignInWithGoogle(auth);
      final first = await signInWithGoogle();
      await auth.signOut();

      final second = await signInWithGoogle();

      expect(second?.id, first?.id);
      expect(await auth.watchCurrentUser().first, same(second));
    });

    test('cancelar o seletor devolve null e não autentica', () async {
      auth.cancelGoogleSignIn = true;
      final signInWithGoogle = SignInWithGoogle(auth);

      final user = await signInWithGoogle();

      expect(user, isNull);
      expect(await auth.watchCurrentUser().first, isNull);
    });

    test('email já cadastrado com senha bloqueia o Google', () async {
      auth.googleEmail = 'alex@example.com';
      await auth.signUp(email: 'alex@example.com', password: 'secret1');
      await auth.signOut();
      final signInWithGoogle = SignInWithGoogle(auth);

      await expectLater(
        signInWithGoogle(),
        throwsA(isA<AccountExistsWithDifferentCredentialException>()),
      );
      expect(await auth.watchCurrentUser().first, isNull);
    });
  });

  group('WatchCurrentUser (RN-A03)', () {
    test('emite o User até o logout explícito', () async {
      await auth.signUp(email: 'alex@example.com', password: 'secret1');
      final watch = WatchCurrentUser(auth);

      expect((await watch().first)?.email, 'alex@example.com');

      await auth.signOut();

      expect(await watch().first, isNull);
    });
  });
}
