import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:andenken_app/data/dto/deck_dto.dart';
import 'package:andenken_app/domain/entities/deck.dart';

void main() {
  final createdAt = DateTime.utc(2026, 8, 1, 12);
  final updatedAt = DateTime.utc(2026, 8, 2, 15);

  test('toMap grava name e createdAt, sem userId, deckId ou cards', () {
    final map = DeckDto(name: 'Alemão A1', createdAt: createdAt).toMap();

    expect(map['name'], 'Alemão A1');
    expect(map['createdAt'], isA<Timestamp>());
    expect(map.containsKey('updatedAt'), isFalse);
    expect(map.containsKey('userId'), isFalse);
    expect(map.containsKey('id'), isFalse);
    expect(map.containsKey('deckId'), isFalse);
    expect(map.containsKey('cards'), isFalse);
  });

  test('toMap inclui updatedAt só quando existe', () {
    final map = DeckDto(
      name: 'Alemão A1',
      createdAt: createdAt,
      updatedAt: updatedAt,
    ).toMap();

    expect(map['updatedAt'], isA<Timestamp>());
  });

  test('toDomain preenche id e userId a partir do path', () {
    final deck = DeckDto(
      name: 'Alemão A1',
      createdAt: createdAt,
    ).toDomain(id: 'd1', userId: 'u1');

    expect(deck.id, 'd1');
    expect(deck.userId, 'u1');
    expect(deck.name, 'Alemão A1');
    expect(deck.createdAt, createdAt);
    expect(deck.updatedAt, isNull);
    expect(deck.cards, isEmpty);
  });

  test('fromMap hidrata timestamps em UTC', () {
    final original = DeckDto(
      name: 'Alemão A1',
      createdAt: createdAt,
      updatedAt: updatedAt,
    );

    final restored = DeckDto.fromMap(original.toMap());

    expect(restored.name, original.name);
    expect(restored.createdAt, createdAt);
    expect(restored.updatedAt, updatedAt);
  });

  test('fromDeck copia name e datas, não o path', () {
    final dto = DeckDto.fromDeck(
      Deck(
        id: 'd1',
        userId: 'u1',
        name: 'Alemão A1',
        createdAt: createdAt,
        updatedAt: updatedAt,
      ),
    );

    expect(dto.name, 'Alemão A1');
    expect(dto.createdAt, createdAt);
    expect(dto.updatedAt, updatedAt);
    expect(dto.toMap().containsKey('userId'), isFalse);
  });
}
