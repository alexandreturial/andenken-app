import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:andenken_app/app.dart';

import '../fakes/fake_auth_repository.dart';
import '../fakes/fake_deck_repository.dart';

void main() {
  testWidgets('senhas diferentes bloqueiam o submit', (tester) async {
    await tester.pumpWidget(
      MyApp(
        authRepository: FakeAuthRepository(),
        deckRepository: FakeDeckRepository(),
        initialLocation: '/register',
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'alex@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'secret1');
    await tester.enterText(find.byType(TextField).at(2), 'secret2');
    await tester.tap(find.text('Register'));
    await tester.pumpAndSettle();

    expect(find.text('As senhas não coincidem.'), findsOneWidget);
    expect(find.text('Create Account'), findsOneWidget);
    expect(find.text('Your Decks'), findsNothing);
  });

  testWidgets('email já cadastrado mostra erro inteligível', (tester) async {
    final auth = FakeAuthRepository();
    await auth.signUp(email: 'alex@example.com', password: 'secret1');
    await auth.signOut();

    await tester.pumpWidget(
      MyApp(
        authRepository: auth,
        deckRepository: FakeDeckRepository(),
        initialLocation: '/register',
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'alex@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'secret1');
    await tester.enterText(find.byType(TextField).at(2), 'secret1');
    await tester.tap(find.text('Register'));
    await tester.pumpAndSettle();

    expect(find.text('Este email já está em uso.'), findsOneWidget);
    expect(find.text('Create Account'), findsOneWidget);
    expect(find.text('Your Decks'), findsNothing);
  });

  testWidgets('cadastro válido abre /decks', (tester) async {
    await tester.pumpWidget(
      MyApp(
        authRepository: FakeAuthRepository(),
        deckRepository: FakeDeckRepository(),
        initialLocation: '/register',
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'alex@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'secret1');
    await tester.enterText(find.byType(TextField).at(2), 'secret1');
    await tester.tap(find.text('Register'));
    await tester.pumpAndSettle();

    expect(find.text('Your Decks'), findsOneWidget);
    expect(find.text('Create Account'), findsNothing);
  });

  testWidgets('Continue with Google no cadastro abre /decks', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MyApp(
        authRepository: FakeAuthRepository(),
        deckRepository: FakeDeckRepository(),
        initialLocation: '/register',
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Continue with Google'));
    await tester.tap(find.text('Continue with Google'));
    await tester.pumpAndSettle();

    expect(find.text('Your Decks'), findsOneWidget);
    expect(find.text('Create Account'), findsNothing);
  });

  testWidgets('cancelar o Google permanece no cadastro sem erro', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final auth = FakeAuthRepository()..cancelGoogleSignIn = true;

    await tester.pumpWidget(
      MyApp(
        authRepository: auth,
        deckRepository: FakeDeckRepository(),
        initialLocation: '/register',
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Continue with Google'));
    await tester.tap(find.text('Continue with Google'));
    await tester.pumpAndSettle();

    expect(find.text('Create Account'), findsOneWidget);
    expect(find.text('Your Decks'), findsNothing);
    expect(
      find.text('Não foi possível conectar. Verifique a rede.'),
      findsNothing,
    );
  });
}
