import 'package:flutter/foundation.dart';

import '../../domain/deck/deck_exception.dart';
import '../../domain/entities/deck.dart';
import '../../domain/usecases/delete_deck.dart';
import '../../domain/usecases/list_decks.dart';
import '../../domain/usecases/list_due_cards.dart';

enum DeckListStatus { loading, data, empty, error }

class DeckListViewState {
  const DeckListViewState({
    this.status = DeckListStatus.loading,
    this.decks = const [],
    this.dueCountByDeckId = const {},
    this.error,
  });

  final DeckListStatus status;
  final List<Deck> decks;
  final Map<String, int> dueCountByDeckId;
  final DeckException? error;
}

class DeckListNotifier extends ValueNotifier<DeckListViewState> {
  DeckListNotifier({
    required ListDecks listDecks,
    required DeleteDeck deleteDeck,
    required ListDueCards listDueCards,
    required String userId,
    DateTime Function()? clock,
  }) : _listDecks = listDecks,
       _deleteDeck = deleteDeck,
       _listDueCards = listDueCards,
       _userId = userId,
       _clock = clock ?? DateTime.now,
       super(const DeckListViewState());

  final ListDecks _listDecks;
  final DeleteDeck _deleteDeck;
  final ListDueCards _listDueCards;
  final String _userId;
  final DateTime Function() _clock;

  Future<void> load() async {
    value = const DeckListViewState();
    try {
      final decks = await _listDecks(userId: _userId);
      if (decks.isEmpty) {
        value = const DeckListViewState(status: DeckListStatus.empty);
        return;
      }
      final now = _clock();
      final dueCountByDeckId = <String, int>{};
      for (final deck in decks) {
        try {
          final due = await _listDueCards(
            userId: _userId,
            deckId: deck.id,
            now: now,
          );
          dueCountByDeckId[deck.id] = due.length;
        } catch (_) {
          dueCountByDeckId[deck.id] = 0;
        }
      }
      value = DeckListViewState(
        status: DeckListStatus.data,
        decks: decks,
        dueCountByDeckId: dueCountByDeckId,
      );
    } on DeckException catch (error) {
      value = DeckListViewState(status: DeckListStatus.error, error: error);
    } catch (_) {
      value = const DeckListViewState(
        status: DeckListStatus.error,
        error: DeckNetworkException(),
      );
    }
  }

  Future<void> deleteDeck(String deckId) async {
    try {
      await _deleteDeck(userId: _userId, deckId: deckId);
    } on DeckException catch (error) {
      value = DeckListViewState(status: DeckListStatus.error, error: error);
      return;
    } catch (_) {
      value = const DeckListViewState(
        status: DeckListStatus.error,
        error: DeckNetworkException(),
      );
      return;
    }
    await load();
  }
}
