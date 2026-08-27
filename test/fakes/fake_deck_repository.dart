import 'package:andenken_app/domain/deck/deck_exception.dart';
import 'package:andenken_app/domain/entities/deck.dart';
import 'package:andenken_app/domain/repositories/deck_repository.dart';

class FakeDeckRepository implements DeckRepository {
  FakeDeckRepository();

  final Map<String, Deck> _byId = {};

  DeckException? forcedListError;
  DeckException? forcedDeleteError;

  @override
  Future<List<Deck>> listByUser(String userId) async {
    final forced = forcedListError;
    if (forced != null) {
      throw forced;
    }
    final listed = _byId.values.where((deck) => deck.userId == userId).toList();
    listed.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return listed;
  }

  @override
  Future<Deck> getById({required String userId, required String deckId}) async {
    final deck = _byId[deckId];
    if (deck == null || deck.userId != userId) {
      throw StateError('deck not found');
    }
    return deck;
  }

  @override
  Future<Deck> create(Deck deck) async {
    _byId[deck.id] = deck;
    return deck;
  }

  @override
  Future<Deck> rename({
    required String userId,
    required String deckId,
    required String name,
    required DateTime updatedAt,
  }) async {
    final deck = await getById(userId: userId, deckId: deckId);
    final updated = deck.copyWith(name: name, updatedAt: updatedAt);
    _byId[deckId] = updated;
    return updated;
  }

  @override
  Future<void> delete({required String userId, required String deckId}) async {
    final forced = forcedDeleteError;
    if (forced != null) {
      throw forced;
    }
    await getById(userId: userId, deckId: deckId);
    _byId.remove(deckId);
  }
}
