import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:andenken_app/app.dart';
import 'package:andenken_app/domain/auth/auth_exception.dart';

import '../fakes/fake_auth_repository.dart';
import '../fakes/fake_deck_repository.dart';

void main() {
  testWidgets('credencial inválida mostra erro e permanece no login', (
    tester,
  ) async {
    final auth = FakeAuthRepository();
    await auth.signUp(email: 'alex@example.com', password: 'secret1');
    await auth.signOut();

    await tester.pumpWidget(
      MyApp(authRepository: auth, deckRepository: FakeDeckRepository()),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'alex@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'wrong-password');
    await tester.tap(find.text('LOGIN'));
    await tester.pumpAndSettle();

    expect(find.text('Email ou senha incorretos.'), findsOneWidget);
    expect(find.text('ANDENKEN'), findsOneWidget);
    expect(find.text('Your Decks'), findsNothing);
  });

  testWidgets('email inexistente usa a mesma mensagem de credencial (RN-A02)', (
    tester,
  ) async {
    await tester.pumpWidget(
      MyApp(
        authRepository: FakeAuthRepository(),
        deckRepository: FakeDeckRepository(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'nobody@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'secret1');
    await tester.tap(find.text('LOGIN'));
    await tester.pumpAndSettle();

    expect(find.text('Email ou senha incorretos.'), findsOneWidget);
    expect(find.text('ANDENKEN'), findsOneWidget);
    expect(find.text('Your Decks'), findsNothing);
  });

  testWidgets('falha de rede mostra mensagem de conexão e não navega', (
    tester,
  ) async {
    final auth = FakeAuthRepository()
      ..forcedSignInError = const AuthNetworkException();

    await tester.pumpWidget(
      MyApp(authRepository: auth, deckRepository: FakeDeckRepository()),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'alex@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'secret1');
    await tester.tap(find.text('LOGIN'));
    await tester.pumpAndSettle();

    expect(
      find.text('Não foi possível conectar. Verifique a rede.'),
      findsOneWidget,
    );
    expect(find.text('ANDENKEN'), findsOneWidget);
    expect(find.text('Your Decks'), findsNothing);
  });

  testWidgets('login válido abre /decks', (tester) async {
    final auth = FakeAuthRepository();
    await auth.signUp(email: 'alex@example.com', password: 'secret1');
    await auth.signOut();

    await tester.pumpWidget(
      MyApp(authRepository: auth, deckRepository: FakeDeckRepository()),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'alex@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'secret1');
    await tester.tap(find.text('LOGIN'));
    await tester.pumpAndSettle();

    expect(find.text('Your Decks'), findsOneWidget);
    expect(find.text('LOGIN'), findsNothing);
  });

  testWidgets('Continue with Google cria a conta e abre /decks', (
    tester,
  ) async {
    await tester.pumpWidget(
      MyApp(
        authRepository: FakeAuthRepository(),
        deckRepository: FakeDeckRepository(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue with Google'));
    await tester.pumpAndSettle();

    expect(find.text('Your Decks'), findsOneWidget);
    expect(find.text('LOGIN'), findsNothing);
  });

  testWidgets('cancelar o Google permanece no login sem erro', (tester) async {
    final auth = FakeAuthRepository()..cancelGoogleSignIn = true;

    await tester.pumpWidget(
      MyApp(authRepository: auth, deckRepository: FakeDeckRepository()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue with Google'));
    await tester.pumpAndSettle();

    expect(find.text('ANDENKEN'), findsOneWidget);
    expect(find.text('Your Decks'), findsNothing);
    expect(
      find.text('Não foi possível conectar. Verifique a rede.'),
      findsNothing,
    );
    expect(find.text('Email ou senha incorretos.'), findsNothing);
  });

  testWidgets(
    'Google com email já cadastrado por senha mostra mensagem clara',
    (tester) async {
      final auth = FakeAuthRepository()..googleEmail = 'alex@example.com';
      await auth.signUp(email: 'alex@example.com', password: 'secret1');
      await auth.signOut();

      await tester.pumpWidget(
        MyApp(authRepository: auth, deckRepository: FakeDeckRepository()),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue with Google'));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Este email já tem conta com senha. Entre com email e senha.',
        ),
        findsOneWidget,
      );
      expect(find.text('ANDENKEN'), findsOneWidget);
      expect(find.text('Your Decks'), findsNothing);
    },
  );
}
