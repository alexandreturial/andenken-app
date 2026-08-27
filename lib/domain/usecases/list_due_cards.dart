import '../datetime/end_of_local_day.dart';
import '../entities/card.dart';
import '../repositories/card_repository.dart';

class ListDueCards {
  const ListDueCards(this._cards);

  final CardRepository _cards;

  Future<List<Card>> call({
    required String userId,
    required String deckId,
    required DateTime now,
  }) async {
    final listed = [
      ...await _cards.listDueByDeck(
        userId: userId,
        deckId: deckId,
        until: endOfLocalDay(now),
      ),
    ];
    listed.sort((a, b) {
      final byDue = a.nextReviewAt.compareTo(b.nextReviewAt);
      if (byDue != 0) {
        return byDue;
      }
      return a.createdAt.compareTo(b.createdAt);
    });
    return listed;
  }
}
