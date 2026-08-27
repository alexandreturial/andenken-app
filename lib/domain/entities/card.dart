/// Flashcard. Nomes de domínio (`frontText`, `intervalDays`, `repetitions`), não os do SM-2.
class Card {
  const Card({
    required this.id,
    required this.deckId,
    required this.frontText,
    required this.backText,
    required this.nextReviewAt,
    required this.createdAt,
    required this.updatedAt,
    this.repetitions = 0,
    this.intervalDays = 0,
    this.easeFactor = 2.5,
    this.lastReviewedAt,
  });

  /// Card novo due imediatamente (RN-C02).
  factory Card.newCard({
    required String id,
    required String deckId,
    required String frontText,
    required String backText,
    required DateTime createdAt,
  }) {
    return Card(
      id: id,
      deckId: deckId,
      frontText: frontText,
      backText: backText,
      repetitions: 0,
      intervalDays: 0,
      easeFactor: 2.5,
      nextReviewAt: createdAt,
      lastReviewedAt: null,
      createdAt: createdAt,
      updatedAt: createdAt,
    );
  }

  final String id;
  final String deckId;
  final String frontText;
  final String backText;
  final int repetitions;
  final int intervalDays;
  final double easeFactor;
  final DateTime nextReviewAt;
  final DateTime? lastReviewedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Card copyWith({
    String? id,
    String? deckId,
    String? frontText,
    String? backText,
    int? repetitions,
    int? intervalDays,
    double? easeFactor,
    DateTime? nextReviewAt,
    DateTime? lastReviewedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearLastReviewedAt = false,
  }) {
    return Card(
      id: id ?? this.id,
      deckId: deckId ?? this.deckId,
      frontText: frontText ?? this.frontText,
      backText: backText ?? this.backText,
      repetitions: repetitions ?? this.repetitions,
      intervalDays: intervalDays ?? this.intervalDays,
      easeFactor: easeFactor ?? this.easeFactor,
      nextReviewAt: nextReviewAt ?? this.nextReviewAt,
      lastReviewedAt: clearLastReviewedAt
          ? null
          : (lastReviewedAt ?? this.lastReviewedAt),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
