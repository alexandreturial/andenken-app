import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/card.dart';

/// Documento em `users/{uid}/decks/{deckId}/cards/{cardId}`.
/// Sem `userId`/`deckId`/`id` (plan §6.2).
class CardDto {
  const CardDto({
    required this.frontText,
    required this.backText,
    required this.repetitions,
    required this.intervalDays,
    required this.easeFactor,
    required this.nextReviewAt,
    required this.createdAt,
    required this.updatedAt,
    this.lastReviewedAt,
  });

  final String frontText;
  final String backText;
  final int repetitions;
  final int intervalDays;
  final double easeFactor;
  final DateTime nextReviewAt;
  final DateTime? lastReviewedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory CardDto.fromCard(Card card) {
    return CardDto(
      frontText: card.frontText,
      backText: card.backText,
      repetitions: card.repetitions,
      intervalDays: card.intervalDays,
      easeFactor: card.easeFactor,
      nextReviewAt: card.nextReviewAt,
      lastReviewedAt: card.lastReviewedAt,
      createdAt: card.createdAt,
      updatedAt: card.updatedAt,
    );
  }

  factory CardDto.fromMap(Map<String, dynamic> map) {
    return CardDto(
      frontText: map['frontText'] as String,
      backText: map['backText'] as String,
      repetitions: _asInt(map['repetitions']),
      intervalDays: _asInt(map['intervalDays']),
      easeFactor: _asDouble(map['easeFactor']),
      nextReviewAt: _asUtc(map['nextReviewAt']),
      lastReviewedAt: map['lastReviewedAt'] == null
          ? null
          : _asUtc(map['lastReviewedAt']),
      createdAt: _asUtc(map['createdAt']),
      updatedAt: _asUtc(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'frontText': frontText,
      'backText': backText,
      'repetitions': repetitions,
      'intervalDays': intervalDays,
      'easeFactor': easeFactor,
      'nextReviewAt': Timestamp.fromDate(nextReviewAt),
      'lastReviewedAt': lastReviewedAt == null
          ? null
          : Timestamp.fromDate(lastReviewedAt!),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Card toDomain({required String id, required String deckId}) {
    return Card(
      id: id,
      deckId: deckId,
      frontText: frontText,
      backText: backText,
      repetitions: repetitions,
      intervalDays: intervalDays,
      easeFactor: easeFactor,
      nextReviewAt: nextReviewAt,
      lastReviewedAt: lastReviewedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static DateTime _asUtc(Object? value) {
    if (value is Timestamp) {
      return value.toDate().toUtc();
    }
    if (value is DateTime) {
      return value.toUtc();
    }
    throw ArgumentError.value(value, 'value', 'expected Timestamp or DateTime');
  }

  static int _asInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is double) {
      return value.toInt();
    }
    throw ArgumentError.value(value, 'value', 'expected number');
  }

  static double _asDouble(Object? value) {
    if (value is double) {
      return value;
    }
    if (value is int) {
      return value.toDouble();
    }
    throw ArgumentError.value(value, 'value', 'expected number');
  }
}
