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

  Future<void> pumpStudy(
    WidgetTester tester, {
    required FakeCardRepository cards,
  }) async {
    final auth = FakeAuthRepository();
    await auth.signUp(email: 'alex@example.com', password: 'secret1');
    final decks = FakeDeckRepository();
    await decks.create(
      Deck(
        id: 'd1',
        userId: 'uid-alex@example.com',
        name: 'Alemão A1',
        createdAt: createdAt,
      ),
    );
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MyApp(
        authRepository: auth,
        deckRepository: decks,
        cardRepository: cards,
        initialLocation: '/decks/d1/study',
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('frente, revelar, nota 5 e resumo (T064, T065)', (tester) async {
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

    await pumpStudy(tester, cards: cards);

    expect(find.text('CURRENT DECK'), findsOneWidget);
    expect(find.text('Hallo'), findsOneWidget);
    expect(find.text('Olá'), findsNothing);
    expect(find.text('FLIP CARD'), findsOneWidget);
    expect(find.text('New Card'), findsOneWidget);

    await tester.tap(find.text('FLIP CARD'));
    await tester.pumpAndSettle();

    expect(find.text('Olá'), findsOneWidget);
    expect(find.text('Não lembro'), findsOneWidget);
    expect(find.text('Lembrei com dificuldade'), findsOneWidget);
    expect(find.text('Lembrei'), findsOneWidget);
    expect(find.text('Conheço'), findsOneWidget);

    await tester.tap(find.text('Conheço'));
    await tester.pumpAndSettle();

    expect(find.text('Sessão concluída'), findsOneWidget);
    expect(find.text('1 card revisado.'), findsOneWidget);

    await tester.tap(find.text('Voltar ao deck'));
    await tester.pumpAndSettle();

    expect(find.text('Alemão A1'), findsOneWidget);
  });

  testWidgets('deck sem due mostra empty state (T066, RN-S10)', (tester) async {
    final cards = FakeCardRepository();
    await cards.create(
      domain.Card(
        id: 'later',
        deckId: 'd1',
        frontText: 'Später',
        backText: 'Depois',
        nextReviewAt: createdAt.add(const Duration(days: 30)),
        createdAt: createdAt,
        updatedAt: createdAt,
      ),
      userId: 'uid-alex@example.com',
    );

    await pumpStudy(tester, cards: cards);

    expect(find.text('Nada para revisar hoje'), findsOneWidget);
    expect(find.text('FLIP CARD'), findsNothing);
  });

  testWidgets('Não lembro reapresenta o card na mesma sessão (RN-U03)', (
    tester,
  ) async {
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

    await pumpStudy(tester, cards: cards);
    await tester.tap(find.text('FLIP CARD'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Não lembro'));
    await tester.pumpAndSettle();

    expect(find.text('Hallo'), findsOneWidget);
    expect(find.text('Sessão concluída'), findsNothing);
    expect(find.text('FLIP CARD'), findsOneWidget);
  });

  testWidgets('Lembrei com dificuldade encerra o card (q=4)', (tester) async {
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

    await pumpStudy(tester, cards: cards);
    await tester.tap(find.text('FLIP CARD'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lembrei com dificuldade'));
    await tester.pumpAndSettle();

    expect(find.text('Sessão concluída'), findsOneWidget);
  });
}
