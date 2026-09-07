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

  Future<void> pumpDetail(
    WidgetTester tester, {
    required FakeDeckRepository decks,
    FakeCardRepository? cards,
  }) async {
    final auth = FakeAuthRepository();
    await auth.signUp(email: 'alex@example.com', password: 'secret1');
    await tester.pumpWidget(
      MyApp(
        authRepository: auth,
        deckRepository: decks,
        cardRepository: cards ?? FakeCardRepository(),
        initialLocation: '/decks/d1',
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<FakeDeckRepository> seedDeck() async {
    final decks = FakeDeckRepository();
    await decks.create(
      Deck(
        id: 'd1',
        userId: 'uid-alex@example.com',
        name: 'Alemão A1',
        createdAt: createdAt,
      ),
    );
    return decks;
  }

  testWidgets('empty state mostra CTA e Estudar desabilitado (T057)', (
    tester,
  ) async {
    await pumpDetail(tester, decks: await seedDeck());

    expect(find.text('Alemão A1'), findsOneWidget);
    expect(find.text('Nenhum card neste deck'), findsOneWidget);
    expect(find.text('Adicionar card'), findsOneWidget);
    expect(find.byTooltip('Create New Card'), findsOneWidget);

    final estudar = find.ancestor(
      of: find.text('Estudar'),
      matching: find.byType(FilledButton),
    );
    expect(tester.widget<FilledButton>(estudar).onPressed, isNull);
  });

  testWidgets('lista mostra frontText e permite estudar (US-04, T054)', (
    tester,
  ) async {
    final decks = await seedDeck();
    final cards = FakeCardRepository();
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

    await pumpDetail(tester, decks: decks, cards: cards);

    expect(find.text('Hallo'), findsOneWidget);
    expect(find.text('Nenhum card neste deck'), findsNothing);

    await tester.tap(find.text('Estudar'));
    await tester.pumpAndSettle();

    expect(find.text('FLIP CARD'), findsOneWidget);
    expect(find.text('Hallo'), findsOneWidget);
  });

  testWidgets('criar vários cards no form do deck e salvar (T122)', (
    tester,
  ) async {
    await pumpDetail(tester, decks: await seedDeck());

    await tester.tap(find.byTooltip('Create New Card'));
    await tester.pumpAndSettle();
    expect(find.text('Editar deck'), findsOneWidget);
    expect(find.text('CARD 1'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(1), '  Hallo  ');
    await tester.enterText(find.byType(TextField).at(2), '  Olá  ');
    await tester.ensureVisible(find.text('ADD ANOTHER CARD'));
    await tester.tap(find.text('ADD ANOTHER CARD'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(3), 'Danke');
    await tester.enterText(find.byType(TextField).at(4), 'Obrigado');
    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Hallo'), findsOneWidget);
    expect(find.text('Danke'), findsOneWidget);
    expect(find.text('Nenhum card neste deck'), findsNothing);
  });

  testWidgets('adicionar e remover rascunho no form do deck (T122)', (
    tester,
  ) async {
    await pumpDetail(tester, decks: await seedDeck());

    await tester.tap(find.byTooltip('Create New Card'));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsNWidgets(3));

    await tester.ensureVisible(find.text('ADD ANOTHER CARD'));
    await tester.tap(find.text('ADD ANOTHER CARD'));
    await tester.pumpAndSettle();
    expect(find.text('CARD 2'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(5));

    await tester.ensureVisible(find.byTooltip('Remove card').last);
    await tester.tap(find.byTooltip('Remove card').last);
    await tester.pumpAndSettle();
    expect(find.text('CARD 2'), findsNothing);
    expect(find.byType(TextField), findsNWidgets(3));
  });

  testWidgets('frente vazia não salva e permanece no form', (tester) async {
    await pumpDetail(tester, decks: await seedDeck());

    await tester.tap(find.text('Adicionar card'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(2), 'Olá');
    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(
      find.text('Frente (1–500) e verso (1–2000) são obrigatórios.'),
      findsOneWidget,
    );
    expect(find.text('Editar deck'), findsOneWidget);
  });

  testWidgets('editar persiste frente/verso (T122)', (tester) async {
    final decks = await seedDeck();
    final cards = FakeCardRepository();
    await cards.create(
      domain.Card(
        id: 'c1',
        deckId: 'd1',
        frontText: 'Antigo',
        backText: 'Old',
        repetitions: 3,
        intervalDays: 6,
        easeFactor: 2.6,
        nextReviewAt: DateTime.utc(2026, 8, 10),
        lastReviewedAt: DateTime.utc(2026, 8, 4),
        createdAt: createdAt,
        updatedAt: createdAt,
      ),
      userId: 'uid-alex@example.com',
    );

    await pumpDetail(tester, decks: decks, cards: cards);

    await tester.tap(find.byTooltip('Ações do card'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Editar'));
    await tester.pumpAndSettle();

    expect(find.text('Editar deck'), findsOneWidget);
    expect(find.text('Antigo'), findsOneWidget);
    expect(find.text('Old'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(1), 'Hallo');
    await tester.enterText(find.byType(TextField).at(2), 'Olá');
    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Hallo'), findsOneWidget);
    final updated = await cards.getById(
      userId: 'uid-alex@example.com',
      deckId: 'd1',
      cardId: 'c1',
    );
    expect(updated.frontText, 'Hallo');
    expect(updated.repetitions, 3);
    expect(updated.easeFactor, 2.6);
  });

  testWidgets('cancelar exclusão do card mantém o card (T056)', (tester) async {
    final decks = await seedDeck();
    final cards = FakeCardRepository();
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

    await pumpDetail(tester, decks: decks, cards: cards);

    await tester.tap(find.byTooltip('Ações do card'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apagar'));
    await tester.pumpAndSettle();
    expect(find.text('Apagar card?'), findsOneWidget);

    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    expect(find.text('Hallo'), findsOneWidget);
    expect(
      await cards.getById(
        userId: 'uid-alex@example.com',
        deckId: 'd1',
        cardId: 'c1',
      ),
      isNotNull,
    );
  });

  testWidgets('confirmar exclusão remove só aquele card (T056, RN-C04)', (
    tester,
  ) async {
    final decks = await seedDeck();
    final cards = FakeCardRepository();
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
    await cards.create(
      domain.Card.newCard(
        id: 'keep',
        deckId: 'd1',
        frontText: 'Danke',
        backText: 'Obrigado',
        createdAt: createdAt,
      ),
      userId: 'uid-alex@example.com',
    );

    await pumpDetail(tester, decks: decks, cards: cards);

    final alvo = find.ancestor(
      of: find.text('Hallo'),
      matching: find.byType(Card),
    );
    await tester.tap(
      find.descendant(of: alvo, matching: find.byTooltip('Ações do card')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apagar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apagar card'));
    await tester.pumpAndSettle();

    expect(find.text('Hallo'), findsNothing);
    expect(find.text('Danke'), findsOneWidget);
  });
}
