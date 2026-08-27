import 'package:andenken_app/domain/entities/deck.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final createdAt = DateTime.utc(2026, 8, 1);

  test('guarda id, userId, name, createdAt e updatedAt opcional', () {
    final deck = Deck(
      id: 'deck-1',
      userId: 'uid-abc',
      name: 'Alemão A1',
      createdAt: createdAt,
    );

    expect(deck.id, 'deck-1');
    expect(deck.userId, 'uid-abc');
    expect(deck.name, 'Alemão A1');
    expect(deck.createdAt, createdAt);
    expect(deck.updatedAt, isNull);
    expect(deck.cards, isEmpty);
  });

  test('cards default é lista vazia e copyWith atualiza name e updatedAt', () {
    final deck = Deck(
      id: 'deck-1',
      userId: 'uid-abc',
      name: 'Alemão A1',
      createdAt: createdAt,
    );
    final updatedAt = DateTime.utc(2026, 8, 2);

    final renamed = deck.copyWith(name: 'Alemão A2', updatedAt: updatedAt);

    expect(renamed.id, deck.id);
    expect(renamed.userId, deck.userId);
    expect(renamed.createdAt, deck.createdAt);
    expect(renamed.name, 'Alemão A2');
    expect(renamed.updatedAt, updatedAt);
    expect(renamed.cards, isEmpty);
  });
}
