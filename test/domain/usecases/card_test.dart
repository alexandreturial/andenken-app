import 'package:andenken_app/domain/card/card_exception.dart';
import 'package:andenken_app/domain/entities/card.dart';
import 'package:andenken_app/domain/usecases/create_card.dart';
import 'package:andenken_app/domain/usecases/delete_card.dart';
import 'package:andenken_app/domain/usecases/list_cards.dart';
import 'package:andenken_app/domain/usecases/update_card.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/fake_card_repository.dart';

void main() {
  late FakeCardRepository cards;
  final now = DateTime.utc(2026, 8, 1);

  setUp(() {
    cards = FakeCardRepository();
  });

  group('ListCards (US-04, RN-C05)', () {
    test('lista vazia devolve lista vazia', () async {
      expect(await ListCards(cards)(userId: 'u1', deckId: 'd1'), isEmpty);
    });

    test('lista só os cards do user e do deck, por createdAt', () async {
      await cards.create(
        Card.newCard(
          id: 'later',
          deckId: 'd1',
          frontText: 'depois',
          backText: 'b',
          createdAt: DateTime.utc(2026, 8, 3),
        ),
        userId: 'u1',
      );
      await cards.create(
        Card.newCard(
          id: 'earlier',
          deckId: 'd1',
          frontText: 'antes',
          backText: 'b',
          createdAt: DateTime.utc(2026, 8, 1),
        ),
        userId: 'u1',
      );
      await cards.create(
        Card.newCard(
          id: 'other-deck',
          deckId: 'd2',
          frontText: 'outro deck',
          backText: 'b',
          createdAt: DateTime.utc(2026, 8, 2),
        ),
        userId: 'u1',
      );
      await cards.create(
        Card.newCard(
          id: 'other-user',
          deckId: 'd1',
          frontText: 'alheio',
          backText: 'b',
          createdAt: DateTime.utc(2026, 8, 2),
        ),
        userId: 'u2',
      );

      final listed = await ListCards(cards)(userId: 'u1', deckId: 'd1');

      expect(listed.map((card) => card.id), ['earlier', 'later']);
    });
  });

  group('CreateCard (US-04, RN-C01, RN-C02)', () {
    test('frente e verso válidos nascem due com defaults SM-2', () async {
      final createCard = CreateCard(cards, generateId: () => 'c1');

      final card = await createCard(
        userId: 'u1',
        deckId: 'd1',
        frontText: '  Hallo  ',
        backText: '  Olá  ',
        now: now,
      );

      expect(card.id, 'c1');
      expect(card.deckId, 'd1');
      expect(card.frontText, 'Hallo');
      expect(card.backText, 'Olá');
      expect(card.easeFactor, 2.5);
      expect(card.repetitions, 0);
      expect(card.intervalDays, 0);
      expect(card.nextReviewAt, now);
      expect(card.lastReviewedAt, isNull);
      expect(card.createdAt, now);
      expect(await ListCards(cards)(userId: 'u1', deckId: 'd1'), [card]);
    });

    test('frente ou verso vazios não salvam', () async {
      final createCard = CreateCard(cards, generateId: () => 'c1');

      await expectLater(
        () => createCard(
          userId: 'u1',
          deckId: 'd1',
          frontText: '   ',
          backText: 'Olá',
          now: now,
        ),
        throwsA(isA<InvalidCardTextException>()),
      );
      await expectLater(
        () => createCard(
          userId: 'u1',
          deckId: 'd1',
          frontText: 'Hallo',
          backText: '',
          now: now,
        ),
        throwsA(isA<InvalidCardTextException>()),
      );
      expect(await cards.listByDeck(userId: 'u1', deckId: 'd1'), isEmpty);
    });

    test('frente > 500 ou verso > 2000 não salvam', () async {
      final createCard = CreateCard(cards, generateId: () => 'c1');

      await expectLater(
        () => createCard(
          userId: 'u1',
          deckId: 'd1',
          frontText: 'a' * 501,
          backText: 'Olá',
          now: now,
        ),
        throwsA(isA<InvalidCardTextException>()),
      );
      await expectLater(
        () => createCard(
          userId: 'u1',
          deckId: 'd1',
          frontText: 'Hallo',
          backText: 'b' * 2001,
          now: now,
        ),
        throwsA(isA<InvalidCardTextException>()),
      );
      expect(await cards.listByDeck(userId: 'u1', deckId: 'd1'), isEmpty);
    });
  });

  group('UpdateCard (US-04, RN-C03)', () {
    test('edita frente/verso sem resetar SM-2', () async {
      final createdAt = DateTime.utc(2026, 8, 1);
      await cards.create(
        Card(
          id: 'c1',
          deckId: 'd1',
          frontText: 'Antigo',
          backText: 'Old',
          repetitions: 4,
          intervalDays: 6,
          easeFactor: 2.6,
          nextReviewAt: DateTime.utc(2026, 8, 10),
          lastReviewedAt: DateTime.utc(2026, 8, 4),
          createdAt: createdAt,
          updatedAt: createdAt,
        ),
        userId: 'u1',
      );
      final updatedAt = DateTime.utc(2026, 8, 5);
      final updateCard = UpdateCard(cards);

      final updated = await updateCard(
        userId: 'u1',
        deckId: 'd1',
        cardId: 'c1',
        frontText: '  Hallo  ',
        backText: '  Olá  ',
        now: updatedAt,
      );

      expect(updated.frontText, 'Hallo');
      expect(updated.backText, 'Olá');
      expect(updated.repetitions, 4);
      expect(updated.intervalDays, 6);
      expect(updated.easeFactor, 2.6);
      expect(updated.nextReviewAt, DateTime.utc(2026, 8, 10));
      expect(updated.lastReviewedAt, DateTime.utc(2026, 8, 4));
      expect(updated.createdAt, createdAt);
      expect(updated.updatedAt, updatedAt);
    });

    test('texto inválido não altera o card', () async {
      await cards.create(
        Card.newCard(
          id: 'c1',
          deckId: 'd1',
          frontText: 'Hallo',
          backText: 'Olá',
          createdAt: now,
        ),
        userId: 'u1',
      );

      await expectLater(
        () => UpdateCard(cards)(
          userId: 'u1',
          deckId: 'd1',
          cardId: 'c1',
          frontText: '   ',
          backText: 'Olá',
          now: DateTime.utc(2026, 8, 2),
        ),
        throwsA(isA<InvalidCardTextException>()),
      );
      expect(
        (await cards.getById(
          userId: 'u1',
          deckId: 'd1',
          cardId: 'c1',
        )).frontText,
        'Hallo',
      );
    });

    test('card inexistente lança CardNotFoundException', () async {
      await expectLater(
        () => UpdateCard(cards)(
          userId: 'u1',
          deckId: 'd1',
          cardId: 'missing',
          frontText: 'Hallo',
          backText: 'Olá',
          now: now,
        ),
        throwsA(isA<CardNotFoundException>()),
      );
    });
  });

  group('DeleteCard (US-04, RN-C04)', () {
    test('remove só aquele card', () async {
      await cards.create(
        Card.newCard(
          id: 'c1',
          deckId: 'd1',
          frontText: 'a',
          backText: 'b',
          createdAt: now,
        ),
        userId: 'u1',
      );
      await cards.create(
        Card.newCard(
          id: 'keep',
          deckId: 'd1',
          frontText: 'c',
          backText: 'd',
          createdAt: now,
        ),
        userId: 'u1',
      );

      await DeleteCard(cards)(userId: 'u1', deckId: 'd1', cardId: 'c1');

      expect(
        (await ListCards(cards)(
          userId: 'u1',
          deckId: 'd1',
        )).map((card) => card.id),
        ['keep'],
      );
    });
  });
}
