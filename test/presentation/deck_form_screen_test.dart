import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:andenken_app/app.dart';
import 'package:andenken_app/domain/entities/deck.dart';

import '../fakes/fake_auth_repository.dart';
import '../fakes/fake_card_repository.dart';
import '../fakes/fake_deck_repository.dart';

void main() {
  final createdAt = DateTime.utc(2026, 8, 1);

  Future<FakeAuthRepository> signIn() async {
    final auth = FakeAuthRepository();
    await auth.signUp(email: 'alex@example.com', password: 'secret1');
    return auth;
  }

  testWidgets('nome vazio não salva e permanece no form', (tester) async {
    final auth = await signIn();
    await tester.pumpWidget(
      MyApp(
        authRepository: auth,
        deckRepository: FakeDeckRepository(),
        cardRepository: FakeCardRepository(),
        initialLocation: '/decks/new',
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save Deck'));
    await tester.pumpAndSettle();

    expect(
      find.text('O nome deve ter entre 1 e 80 caracteres.'),
      findsOneWidget,
    );
    expect(find.text('Novo deck'), findsOneWidget);
    expect(find.text('My Decks'), findsNothing);
  });

  testWidgets('criar deck válido volta à lista com o novo deck', (
    tester,
  ) async {
    final auth = await signIn();
    await tester.pumpWidget(
      MyApp(
        authRepository: auth,
        deckRepository: FakeDeckRepository(),
        cardRepository: FakeCardRepository(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Create New Deck'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '  Alemão A1  ');
    await tester.tap(find.text('Save Deck'));
    await tester.pumpAndSettle();

    expect(find.text('My Decks'), findsOneWidget);
    expect(find.text('Alemão A1'), findsOneWidget);
    expect(find.text('Lista de decks vazia'), findsNothing);
  });

  testWidgets('renomear preenche o nome e salva', (tester) async {
    final auth = await signIn();
    final decks = FakeDeckRepository();
    await decks.create(
      Deck(
        id: 'd1',
        userId: 'uid-alex@example.com',
        name: 'Antigo',
        createdAt: createdAt,
      ),
    );
    await tester.pumpWidget(
      MyApp(
        authRepository: auth,
        deckRepository: decks,
        cardRepository: FakeCardRepository(),
        initialLocation: '/decks/d1/edit',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Renomear deck'), findsOneWidget);
    expect(find.text('Antigo'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Novo nome');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Renomear deck'), findsNothing);
    expect(
      (await decks.getById(userId: 'uid-alex@example.com', deckId: 'd1')).name,
      'Novo nome',
    );
  });
}
