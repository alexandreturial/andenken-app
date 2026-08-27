import 'card.dart';

/// Deck do User. `cards` é agregado em memória; no Firestore é subcoleção (spec §3.2).
class Deck {
  const Deck({
    required this.id,
    required this.userId,
    required this.name,
    required this.createdAt,
    this.cards = const [],
    this.updatedAt,
  });

  final String id;
  final String userId;
  final String name;
  final List<Card> cards;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Deck copyWith({
    String? id,
    String? userId,
    String? name,
    List<Card>? cards,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Deck(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      cards: cards ?? this.cards,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
