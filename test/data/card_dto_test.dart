import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:andenken_app/data/dto/card_dto.dart';
import 'package:andenken_app/domain/entities/card.dart';

void main() {
  final createdAt = DateTime.utc(2026, 8, 1, 12);
  final nextReviewAt = DateTime.utc(2026, 8, 10, 12);
  final lastReviewedAt = DateTime.utc(2026, 8, 4, 12);
  final updatedAt = DateTime.utc(2026, 8, 5, 12);

  test('toMap grava campos SM-2, sem userId, deckId ou id', () {
    final map = CardDto(
      frontText: 'Hallo',
      backText: 'Olá',
      repetitions: 0,
      intervalDays: 0,
      easeFactor: 2.5,
      nextReviewAt: createdAt,
      createdAt: createdAt,
      updatedAt: createdAt,
    ).toMap();

    expect(map['frontText'], 'Hallo');
    expect(map['backText'], 'Olá');
    expect(map['repetitions'], 0);
    expect(map['intervalDays'], 0);
    expect(map['easeFactor'], 2.5);
    expect(map['nextReviewAt'], isA<Timestamp>());
    expect(map['lastReviewedAt'], isNull);
    expect(map['createdAt'], isA<Timestamp>());
    expect(map['updatedAt'], isA<Timestamp>());
    expect(map.containsKey('userId'), isFalse);
    expect(map.containsKey('deckId'), isFalse);
    expect(map.containsKey('id'), isFalse);
  });

  test('toDomain preenche id e deckId a partir do path', () {
    final card = CardDto(
      frontText: 'Hallo',
      backText: 'Olá',
      repetitions: 2,
      intervalDays: 6,
      easeFactor: 2.6,
      nextReviewAt: nextReviewAt,
      lastReviewedAt: lastReviewedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    ).toDomain(id: 'c1', deckId: 'd1');

    expect(card.id, 'c1');
    expect(card.deckId, 'd1');
    expect(card.frontText, 'Hallo');
    expect(card.backText, 'Olá');
    expect(card.repetitions, 2);
    expect(card.intervalDays, 6);
    expect(card.easeFactor, 2.6);
    expect(card.nextReviewAt, nextReviewAt);
    expect(card.lastReviewedAt, lastReviewedAt);
  });

  test('fromMap hidrata timestamps em UTC e números int/double', () {
    final original = CardDto(
      frontText: 'Hallo',
      backText: 'Olá',
      repetitions: 1,
      intervalDays: 1,
      easeFactor: 2.5,
      nextReviewAt: nextReviewAt,
      lastReviewedAt: lastReviewedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );

    final restored = CardDto.fromMap(original.toMap());

    expect(restored.frontText, original.frontText);
    expect(restored.backText, original.backText);
    expect(restored.repetitions, 1);
    expect(restored.intervalDays, 1);
    expect(restored.easeFactor, 2.5);
    expect(restored.nextReviewAt, nextReviewAt);
    expect(restored.lastReviewedAt, lastReviewedAt);
    expect(restored.createdAt, createdAt);
    expect(restored.updatedAt, updatedAt);
  });

  test('fromCard copia textos e SM-2, não o path', () {
    final dto = CardDto.fromCard(
      Card(
        id: 'c1',
        deckId: 'd1',
        frontText: 'Hallo',
        backText: 'Olá',
        repetitions: 3,
        intervalDays: 6,
        easeFactor: 2.36,
        nextReviewAt: nextReviewAt,
        lastReviewedAt: lastReviewedAt,
        createdAt: createdAt,
        updatedAt: updatedAt,
      ),
    );

    expect(dto.frontText, 'Hallo');
    expect(dto.easeFactor, 2.36);
    expect(dto.toMap().containsKey('deckId'), isFalse);
    expect(dto.toMap().containsKey('id'), isFalse);
  });
}
