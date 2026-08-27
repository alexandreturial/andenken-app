import '../entities/deck.dart';

abstract class DeckRepository {
  Future<List<Deck>> listByUser(String userId);

  Future<Deck> getById({required String userId, required String deckId});

  Future<Deck> create(Deck deck);

  Future<Deck> rename({
    required String userId,
    required String deckId,
    required String name,
    required DateTime updatedAt,
  });

  Future<void> delete({required String userId, required String deckId});
}
