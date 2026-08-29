import 'package:flutter/foundation.dart';

import '../../domain/deck/deck_exception.dart';
import '../../domain/entities/deck.dart';
import '../../domain/repositories/study_stats_repository.dart';
import '../../domain/study/deck_mastery.dart';
import '../../domain/study/study_stats.dart';
import '../../domain/usecases/delete_deck.dart';
import '../../domain/usecases/list_cards.dart';
import '../../domain/usecases/list_decks.dart';

enum DeckListStatus { loading, data, empty, error }

class DeckListViewState {
  const DeckListViewState({
    this.status = DeckListStatus.loading,
    this.decks = const [],
    this.dueCountByDeckId = const {},
    this.masteryByDeckId = const {},
    this.studyStats,
    this.error,
  });

  final DeckListStatus status;
  final List<Deck> decks;
  final Map<String, int> dueCountByDeckId;
  final Map<String, DeckMastery> masteryByDeckId;
  final StudyStats? studyStats;
  final DeckException? error;
}

class DeckListNotifier extends ValueNotifier<DeckListViewState> {
  DeckListNotifier({
    required ListDecks listDecks,
    required DeleteDeck deleteDeck,
    required ListCards listCards,
    required StudyStatsRepository studyStats,
    required String userId,
    DateTime Function()? clock,
  }) : _listDecks = listDecks,
       _deleteDeck = deleteDeck,
       _listCards = listCards,
       _studyStats = studyStats,
       _userId = userId,
       _clock = clock ?? DateTime.now,
       super(const DeckListViewState());

  final ListDecks _listDecks;
  final DeleteDeck _deleteDeck;
  final ListCards _listCards;
  final StudyStatsRepository _studyStats;
  final String _userId;
  final DateTime Function() _clock;

  Future<void> load() async {
    value = const DeckListViewState();
    try {
      final decks = await _listDecks(userId: _userId);
      final stats = await _studyStats.get(_userId);
      if (decks.isEmpty) {
        value = DeckListViewState(
          status: DeckListStatus.empty,
          studyStats: stats,
        );
        return;
      }
      final now = _clock();
      final dueCountByDeckId = <String, int>{};
      final masteryByDeckId = <String, DeckMastery>{};
      for (final deck in decks) {
        try {
          final cards = await _listCards(userId: _userId, deckId: deck.id);
          final mastery = DeckMastery.fromCards(cards, now);
          masteryByDeckId[deck.id] = mastery;
          dueCountByDeckId[deck.id] = mastery.dueCount;
        } catch (_) {
          dueCountByDeckId[deck.id] = 0;
          masteryByDeckId[deck.id] = const DeckMastery(
            total: 0,
            dueCount: 0,
            percent: 0,
          );
        }
      }
      value = DeckListViewState(
        status: DeckListStatus.data,
        decks: decks,
        dueCountByDeckId: dueCountByDeckId,
        masteryByDeckId: masteryByDeckId,
        studyStats: stats,
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
