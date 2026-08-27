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

    expect(find.text('Estudo'), findsOneWidget);
    expect(find.text('Hallo'), findsOneWidget);
    expect(find.text('Olá'), findsNothing);
    expect(find.text('Mostrar resposta'), findsOneWidget);

    await tester.tap(find.text('Mostrar resposta'));
    await tester.pumpAndSettle();

    expect(find.text('Olá'), findsOneWidget);
    expect(find.text('Perfeita'), findsOneWidget);

    await tester.tap(find.byKey(const Key('grade-5')));
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
    expect(find.text('Mostrar resposta'), findsNothing);
  });

  testWidgets('grade < 4 reapresenta o card na mesma sessão (RN-S08)', (
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
    await tester.tap(find.text('Mostrar resposta'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('grade-2')));
    await tester.pumpAndSettle();

    expect(find.text('Hallo'), findsOneWidget);
    expect(find.text('Sessão concluída'), findsNothing);
    expect(find.text('Mostrar resposta'), findsOneWidget);
  });
}
