import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:andenken_app/app.dart';
import 'package:andenken_app/domain/entities/card.dart' as domain;
import 'package:andenken_app/domain/entities/deck.dart';

import '../fakes/fake_auth_repository.dart';
import '../fakes/fake_card_repository.dart';
import '../fakes/fake_deck_repository.dart';

void main() {
  final createdAt = DateTime.utc(2026, 8, 1);

  Future<void> pumpLoggedIn(
    WidgetTester tester, {
    FakeDeckRepository? decks,
    FakeCardRepository? cards,
  }) async {
    final auth = FakeAuthRepository();
    await auth.signUp(email: 'alex@example.com', password: 'secret1');
    await tester.pumpWidget(
      MyApp(
        authRepository: auth,
        deckRepository: decks ?? FakeDeckRepository(),
        cardRepository: cards ?? FakeCardRepository(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('lista vazia mostra CTA e FAB', (tester) async {
    await pumpLoggedIn(tester);

    expect(find.text('My Decks'), findsOneWidget);
    expect(find.text('Lista de decks vazia'), findsOneWidget);
    expect(find.text('Criar deck'), findsOneWidget);
    expect(find.byTooltip('Create New Deck'), findsOneWidget);
  });

  testWidgets('lista com decks mostra nome e badge due placeholder', (
    tester,
  ) async {
    final decks = FakeDeckRepository();
    await decks.create(
      Deck(
        id: 'd1',
        userId: 'uid-alex@example.com',
        name: 'Alemão A1',
        createdAt: createdAt,
      ),
    );

    await pumpLoggedIn(tester, decks: decks);

    expect(find.text('Alemão A1'), findsOneWidget);
    expect(find.text('0 due'), findsOneWidget);
    expect(find.text('Lista de decks vazia'), findsNothing);
  });

  testWidgets('badge due conta cards com nextReviewAt de hoje (T067)', (
    tester,
  ) async {
    final decks = FakeDeckRepository();
    final cards = FakeCardRepository();
    await decks.create(
      Deck(
        id: 'd1',
        userId: 'uid-alex@example.com',
        name: 'Alemão A1',
        createdAt: createdAt,
      ),
    );
    await cards.create(
      domain.Card.newCard(
        id: 'c1',
        deckId: 'd1',
        frontText: 'Hallo',
        backText: 'Olá',
        createdAt: createdAt,
      ),
      userId: 'uid-alex@example.com',
    );

    await pumpLoggedIn(tester, decks: decks, cards: cards);

    expect(find.text('1 due'), findsOneWidget);
  });

  testWidgets('FAB abre o stub de novo deck', (tester) async {
    await pumpLoggedIn(tester);

    await tester.tap(find.byTooltip('Create New Deck'));
    await tester.pumpAndSettle();

    expect(find.text('Novo deck'), findsWidgets);
  });

  testWidgets('Criar deck no empty state abre o stub', (tester) async {
    await pumpLoggedIn(tester);

    await tester.tap(find.text('Criar deck'));
    await tester.pumpAndSettle();

    expect(find.text('Novo deck'), findsWidgets);
  });

  testWidgets('User A não vê decks do User B (RN-D02)', (tester) async {
    final decks = FakeDeckRepository();
    await decks.create(
      Deck(
        id: 'mine',
        userId: 'uid-alex@example.com',
        name: 'Meu deck',
        createdAt: createdAt,
      ),
    );
    await decks.create(
      Deck(
        id: 'theirs',
        userId: 'uid-bia@example.com',
        name: 'Deck da Bia',
        createdAt: createdAt,
      ),
    );

    await pumpLoggedIn(tester, decks: decks);

    expect(find.text('Meu deck'), findsOneWidget);
    expect(find.text('Deck da Bia'), findsNothing);
  });

  testWidgets('cancelar o dialog de exclusão mantém o deck (US-03)', (
    tester,
  ) async {
    final decks = FakeDeckRepository();
    await decks.create(
      Deck(
        id: 'd1',
        userId: 'uid-alex@example.com',
        name: 'Alemão A1',
        createdAt: createdAt,
      ),
    );
    await pumpLoggedIn(tester, decks: decks);

    await tester.tap(find.byTooltip('Ações do deck'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apagar'));
    await tester.pumpAndSettle();

    expect(find.text('Apagar deck?'), findsOneWidget);

    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    expect(find.text('Apagar deck?'), findsNothing);
    expect(find.text('Alemão A1'), findsOneWidget);
    expect(
      await decks.getById(userId: 'uid-alex@example.com', deckId: 'd1'),
      isNotNull,
    );
  });

  testWidgets('confirmar exclusão remove o deck e os cards (US-03, RN-D03)', (
    tester,
  ) async {
    final decks = FakeDeckRepository();
    final cards = FakeCardRepository();
    await decks.create(
      Deck(
        id: 'd1',
        userId: 'uid-alex@example.com',
        name: 'Alemão A1',
        createdAt: createdAt,
      ),
    );
    await decks.create(
      Deck(
        id: 'keep',
        userId: 'uid-alex@example.com',
        name: 'Francês',
        createdAt: createdAt,
      ),
    );
    await cards.create(
      domain.Card.newCard(
        id: 'c1',
        deckId: 'd1',
        frontText: 'Hallo',
        backText: 'Olá',
        createdAt: createdAt,
      ),
      userId: 'uid-alex@example.com',
    );

    await pumpLoggedIn(tester, decks: decks, cards: cards);

    final alvo = find.ancestor(
      of: find.text('Alemão A1'),
      matching: find.byType(Card),
    );
    await tester.tap(
      find.descendant(of: alvo, matching: find.byTooltip('Ações do deck')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apagar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apagar deck'));
    await tester.pumpAndSettle();

    expect(find.text('Alemão A1'), findsNothing);
    expect(find.text('Francês'), findsOneWidget);
    expect(find.text('Apagar deck?'), findsNothing);
    expect(
      await cards.listByDeck(userId: 'uid-alex@example.com', deckId: 'd1'),
      isEmpty,
    );
  });
}
