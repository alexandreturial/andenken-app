import 'package:andenken_app/domain/entities/card.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final createdAt = DateTime.utc(2026, 8, 23, 12);

  group('Card.newCard (RN-C02)', () {
    late Card card;

    setUp(() {
      card = Card.newCard(
        id: 'card-1',
        deckId: 'deck-1',
        frontText: 'Hund',
        backText: 'cachorro',
        createdAt: createdAt,
      );
    });

    test('nasce due: nextReviewAt = createdAt e lastReviewedAt nulo', () {
      expect(card.nextReviewAt, createdAt);
      expect(card.lastReviewedAt, isNull);
      expect(card.createdAt, createdAt);
      expect(card.updatedAt, createdAt);
    });

    test('defaults SM-2 de card novo', () {
      expect(card.easeFactor, 2.5);
      expect(card.repetitions, 0);
      expect(card.intervalDays, 0);
    });

    test('guarda frente, verso e ids', () {
      expect(card.id, 'card-1');
      expect(card.deckId, 'deck-1');
      expect(card.frontText, 'Hund');
      expect(card.backText, 'cachorro');
    });
  });

  test('copyWith altera só os campos passados', () {
    final card = Card.newCard(
      id: 'card-1',
      deckId: 'deck-1',
      frontText: 'Hund',
      backText: 'cachorro',
      createdAt: createdAt,
    );

    final updated = card.copyWith(frontText: 'der Hund');

    expect(updated.backText, card.backText);
    expect(updated.easeFactor, card.easeFactor);
    expect(updated.frontText, 'der Hund');
  });
}
