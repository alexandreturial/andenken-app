import '../entities/deck.dart';

/// RN-N01: deck com mais due; empate por `createdAt`.
Deck? pickStudyDeck(List<Deck> decks, Map<String, int> dueCountByDeckId) {
  if (decks.isEmpty) {
    return null;
  }
  final sorted = [...decks]..sort((a, b) {
    final dueCmp = (dueCountByDeckId[b.id] ?? 0).compareTo(
      dueCountByDeckId[a.id] ?? 0,
    );
    if (dueCmp != 0) {
      return dueCmp;
    }
    return a.createdAt.compareTo(b.createdAt);
  });
  return sorted.first;
}
