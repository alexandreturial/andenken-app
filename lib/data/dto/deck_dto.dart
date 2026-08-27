import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/deck.dart';

/// Documento em `users/{uid}/decks/{deckId}`. Sem `userId`/`deckId`/`cards` (plan §6.2).
class DeckDto {
  const DeckDto({required this.name, required this.createdAt, this.updatedAt});

  final String name;
  final DateTime createdAt;
  final DateTime? updatedAt;

  factory DeckDto.fromDeck(Deck deck) {
    return DeckDto(
      name: deck.name,
      createdAt: deck.createdAt,
      updatedAt: deck.updatedAt,
    );
  }

  factory DeckDto.fromMap(Map<String, dynamic> map) {
    return DeckDto(
      name: map['name'] as String,
      createdAt: _asUtc(map['createdAt']),
      updatedAt: map['updatedAt'] == null ? null : _asUtc(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'createdAt': Timestamp.fromDate(createdAt),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    };
  }

  Deck toDomain({required String id, required String userId}) {
    return Deck(
      id: id,
      userId: userId,
      name: name,
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
}
