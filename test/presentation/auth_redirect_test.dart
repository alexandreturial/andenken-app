import 'package:flutter_test/flutter_test.dart';

import 'package:andenken_app/app.dart';

import '../fakes/fake_auth_repository.dart';
import '../fakes/fake_deck_repository.dart';

void main() {
  testWidgets('visitante em rota autenticada vai para /login', (tester) async {
    await tester.pumpWidget(
      MyApp(
        authRepository: FakeAuthRepository(),
        deckRepository: FakeDeckRepository(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('ANDENKEN'), findsOneWidget);
    expect(find.text('LOGIN'), findsOneWidget);
    expect(find.text('My Decks'), findsNothing);
  });

  testWidgets('visitante permanece em /register', (tester) async {
    await tester.pumpWidget(
      MyApp(
        authRepository: FakeAuthRepository(),
        deckRepository: FakeDeckRepository(),
        initialLocation: '/register',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Create Account'), findsOneWidget);
    expect(find.text('Register'), findsOneWidget);
  });

  testWidgets('user autenticado em /login vai para /decks', (tester) async {
    final auth = FakeAuthRepository();
    await auth.signUp(email: 'alex@example.com', password: 'secret1');

    await tester.pumpWidget(
      MyApp(
        authRepository: auth,
        deckRepository: FakeDeckRepository(),
        initialLocation: '/login',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('My Decks'), findsOneWidget);
    expect(find.text('ANDENKEN'), findsNothing);
  });

  testWidgets('logout tira o user das rotas autenticadas', (tester) async {
    final auth = FakeAuthRepository();
    await auth.signUp(email: 'alex@example.com', password: 'secret1');

    await tester.pumpWidget(
      MyApp(authRepository: auth, deckRepository: FakeDeckRepository()),
    );
    await tester.pumpAndSettle();
    expect(find.text('My Decks'), findsOneWidget);

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();

    expect(find.text('ANDENKEN'), findsOneWidget);
    expect(find.text('LOGIN'), findsOneWidget);
    expect(find.text('My Decks'), findsNothing);

    expect(tester.takeException(), isNull);
  });
}
