import 'package:andenken_app/domain/entities/card.dart';
import 'package:andenken_app/domain/usecases/card_review.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const review = CardReview();
  final createdAt = DateTime.utc(2026, 1, 1);

  Card newCard() => Card.newCard(
    id: 'card-1',
    deckId: 'deck-1',
    frontText: 'Hund',
    backText: 'cachorro',
    createdAt: createdAt,
  );

  DateTime day(int n) => DateTime.utc(2026, 1, n);

  group('tabela §8 — seis revisões', () {
    test('percorre as 6 revisões do algoritmo', () {
      var card = newCard();

      card = review(card, 4, day(1));
      expect(card.easeFactor, 2.50);
      expect(card.intervalDays, 1);
      expect(card.repetitions, 1);
      expect(card.lastReviewedAt, day(1));
      expect(card.nextReviewAt, day(2));
      expect(card.updatedAt, day(1));

      card = review(card, 4, day(2));
      expect(card.easeFactor, 2.50);
      expect(card.intervalDays, 6);
      expect(card.repetitions, 2);
      expect(card.nextReviewAt, day(8));

      card = review(card, 3, day(8));
      expect(card.easeFactor, 2.36);
      expect(card.intervalDays, 15);
      expect(card.repetitions, 3);
      expect(card.nextReviewAt, day(23));

      card = review(card, 2, day(23));
      expect(card.easeFactor, 2.04);
      expect(card.intervalDays, 1);
      expect(card.repetitions, 0);
      expect(card.nextReviewAt, day(24));

      card = review(card, 4, day(24));
      expect(card.easeFactor, 2.04);
      expect(card.intervalDays, 1);
      expect(card.repetitions, 1);
      expect(card.nextReviewAt, day(25));

      card = review(card, 5, day(25));
      expect(card.easeFactor, 2.14);
      expect(card.intervalDays, 6);
      expect(card.repetitions, 2);
      expect(card.nextReviewAt, day(31));
    });
  });

  group('RN-S03 grade', () {
    test('rejeita grade fora de [0, 5]', () {
      final card = newCard();
      expect(() => review(card, -1, day(1)), throwsArgumentError);
      expect(() => review(card, 6, day(1)), throwsArgumentError);
    });
  });

  group('casos de borda §9', () {
    test('grade 4 não altera o EF', () {
      final card = newCard().copyWith(easeFactor: 2.36, repetitions: 0);
      final reviewed = review(card, 4, day(1));
      expect(reviewed.easeFactor, 2.36);
    });

    test('grade 5 aumenta o EF em 0.10', () {
      final card = newCard().copyWith(easeFactor: 2.04, repetitions: 1);
      final reviewed = review(card, 5, day(1));
      expect(reviewed.easeFactor, 2.14);
    });

    test('EF nunca fica abaixo de 1.3', () {
      final card = newCard().copyWith(easeFactor: 1.3, repetitions: 0);
      final reviewed = review(card, 0, day(1));
      expect(reviewed.easeFactor, 1.3);
    });

    test('card nunca revisado está due em createdAt', () {
      final card = newCard();
      expect(card.repetitions, 0);
      expect(card.nextReviewAt, card.createdAt);
    });

    test('revisão atrasada não penaliza: nextReviewAt = now + interval', () {
      final scheduled = day(2);
      final late = day(10);
      final card = newCard().copyWith(
        repetitions: 1,
        intervalDays: 6,
        easeFactor: 2.5,
        nextReviewAt: scheduled,
        lastReviewedAt: day(1),
      );

      final reviewed = review(card, 4, late);

      expect(reviewed.intervalDays, 6);
      expect(reviewed.nextReviewAt, late.add(const Duration(days: 6)));
      expect(reviewed.lastReviewedAt, late);
    });
  });

  group('T027 falha', () {
    test('grade < 3 zera repetitions, intervalDays = 1 e ainda aplica EF', () {
      final card = newCard().copyWith(
        repetitions: 3,
        intervalDays: 15,
        easeFactor: 2.36,
      );

      final reviewed = review(card, 2, day(23));

      expect(reviewed.repetitions, 0);
      expect(reviewed.intervalDays, 1);
      expect(reviewed.easeFactor, 2.04);
      expect(reviewed.nextReviewAt, day(24));
    });
  });
}
