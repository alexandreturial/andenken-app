import 'package:andenken_app/domain/datetime/end_of_local_day.dart';
import 'package:andenken_app/domain/entities/card.dart';
import 'package:andenken_app/domain/usecases/list_due_cards.dart';
import 'package:andenken_app/domain/usecases/review_card.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/fake_card_repository.dart';

void main() {
  late FakeCardRepository cards;
  final now = DateTime(2026, 8, 27, 10);

  Card scheduled({
    required String id,
    required DateTime nextReviewAt,
    DateTime? createdAt,
    String deckId = 'd1',
    String userId = 'u1',
  }) {
    final created = createdAt ?? nextReviewAt;
    return Card(
      id: id,
      deckId: deckId,
      frontText: id,
      backText: 'b',
      nextReviewAt: nextReviewAt,
      createdAt: created,
      updatedAt: created,
    );
  }

  Future<void> seed(Card card, {String userId = 'u1'}) {
    return cards.create(card, userId: userId);
  }

  setUp(() {
    cards = FakeCardRepository();
  });

  group('ListDueCards (RN-S01, RN-S02)', () {
    test('lista vazia devolve lista vazia', () async {
      expect(
        await ListDueCards(cards)(userId: 'u1', deckId: 'd1', now: now),
        isEmpty,
      );
    });

    test('inclui cards com nextReviewAt até o fim do dia local', () async {
      await seed(scheduled(id: 'past', nextReviewAt: DateTime(2026, 8, 20, 8)));
      await seed(
        scheduled(id: 'later-today', nextReviewAt: DateTime(2026, 8, 27, 22)),
      );
      await seed(scheduled(id: 'end-of-day', nextReviewAt: endOfLocalDay(now)));
      await seed(
        scheduled(id: 'tomorrow', nextReviewAt: DateTime(2026, 8, 28)),
      );

      final due = await ListDueCards(cards)(
        userId: 'u1',
        deckId: 'd1',
        now: now,
      );

      expect(due.map((card) => card.id), ['past', 'later-today', 'end-of-day']);
    });

    test('ordena por nextReviewAt e desempata por createdAt', () async {
      await seed(
        scheduled(
          id: 'later-due',
          nextReviewAt: DateTime(2026, 8, 27, 18),
          createdAt: DateTime(2026, 8, 1),
        ),
      );
      await seed(
        scheduled(
          id: 'same-due-later',
          nextReviewAt: DateTime(2026, 8, 27, 9),
          createdAt: DateTime(2026, 8, 10),
        ),
      );
      await seed(
        scheduled(
          id: 'same-due-earlier',
          nextReviewAt: DateTime(2026, 8, 27, 9),
          createdAt: DateTime(2026, 8, 2),
        ),
      );

      final due = await ListDueCards(cards)(
        userId: 'u1',
        deckId: 'd1',
        now: now,
      );

      expect(due.map((card) => card.id), [
        'same-due-earlier',
        'same-due-later',
        'later-due',
      ]);
    });

    test('lista só os cards due do user e do deck', () async {
      await seed(scheduled(id: 'mine', nextReviewAt: DateTime(2026, 8, 1)));
      await seed(
        scheduled(
          id: 'other-deck',
          nextReviewAt: DateTime(2026, 8, 1),
          deckId: 'd2',
        ),
      );
      await seed(
        scheduled(id: 'other-user', nextReviewAt: DateTime(2026, 8, 1)),
        userId: 'u2',
      );

      final due = await ListDueCards(cards)(
        userId: 'u1',
        deckId: 'd1',
        now: now,
      );

      expect(due.map((card) => card.id), ['mine']);
    });
  });

  group('ReviewCard (RN-S04)', () {
    test('aplica CardReview e persiste o card', () async {
      final createdAt = DateTime.utc(2026, 1, 1);
      await seed(
        Card.newCard(
          id: 'c1',
          deckId: 'd1',
          frontText: 'Hund',
          backText: 'cachorro',
          createdAt: createdAt,
        ),
      );
      final nowReview = DateTime.utc(2026, 1, 1);

      final reviewed = await ReviewCard(cards)(
        userId: 'u1',
        card: await cards.getById(userId: 'u1', deckId: 'd1', cardId: 'c1'),
        grade: 4,
        now: nowReview,
      );

      expect(reviewed.easeFactor, 2.5);
      expect(reviewed.intervalDays, 1);
      expect(reviewed.repetitions, 1);
      expect(reviewed.nextReviewAt, DateTime.utc(2026, 1, 2));
      expect(reviewed.lastReviewedAt, nowReview);

      final stored = await cards.getById(
        userId: 'u1',
        deckId: 'd1',
        cardId: 'c1',
      );
      expect(stored.intervalDays, 1);
      expect(stored.repetitions, 1);
      expect(stored.nextReviewAt, DateTime.utc(2026, 1, 2));
    });

    test('grade inválido rejeita antes de persistir', () async {
      final createdAt = DateTime.utc(2026, 1, 1);
      final card = Card.newCard(
        id: 'c1',
        deckId: 'd1',
        frontText: 'Hund',
        backText: 'cachorro',
        createdAt: createdAt,
      );
      await seed(card);

      expect(
        () => ReviewCard(cards)(
          userId: 'u1',
          card: card,
          grade: 6,
          now: createdAt,
        ),
        throwsArgumentError,
      );

      final stored = await cards.getById(
        userId: 'u1',
        deckId: 'd1',
        cardId: 'c1',
      );
      expect(stored.repetitions, 0);
      expect(stored.lastReviewedAt, isNull);
    });
  });
}
