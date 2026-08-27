import 'package:flutter/foundation.dart';

import '../../domain/deck/deck_exception.dart';
import '../../domain/repositories/deck_repository.dart';
import '../../domain/usecases/create_deck.dart';
import '../../domain/usecases/rename_deck.dart';

enum DeckFormStatus { idle, loading, success, error }

class DeckFormViewState {
  const DeckFormViewState({
    this.status = DeckFormStatus.idle,
    this.initialName,
    this.error,
  });

  final DeckFormStatus status;
  final String? initialName;
  final DeckException? error;
}

class DeckFormNotifier extends ValueNotifier<DeckFormViewState> {
  DeckFormNotifier({
    required CreateDeck createDeck,
    required RenameDeck renameDeck,
    required DeckRepository decks,
    required String userId,
    String? deckId,
    DateTime Function()? clock,
  }) : _createDeck = createDeck,
       _renameDeck = renameDeck,
       _decks = decks,
       _userId = userId,
       _deckId = deckId,
       _clock = clock ?? DateTime.now,
       super(
         DeckFormViewState(
           status: deckId == null
               ? DeckFormStatus.idle
               : DeckFormStatus.loading,
         ),
       );

  final CreateDeck _createDeck;
  final RenameDeck _renameDeck;
  final DeckRepository _decks;
  final String _userId;
  final String? _deckId;
  final DateTime Function() _clock;

  bool get isRename => _deckId != null;

  Future<void> load() async {
    final deckId = _deckId;
    if (deckId == null) {
      return;
    }
    value = const DeckFormViewState(status: DeckFormStatus.loading);
    try {
      final deck = await _decks.getById(userId: _userId, deckId: deckId);
      value = DeckFormViewState(initialName: deck.name);
    } on DeckException catch (error) {
      value = DeckFormViewState(status: DeckFormStatus.error, error: error);
    } on StateError {
      value = const DeckFormViewState(
        status: DeckFormStatus.error,
        error: DeckNotFoundException(),
      );
    } catch (_) {
      value = const DeckFormViewState(
        status: DeckFormStatus.error,
        error: DeckNetworkException(),
      );
    }
  }

  Future<void> submit(String name) async {
    value = DeckFormViewState(
      status: DeckFormStatus.loading,
      initialName: value.initialName,
    );
    try {
      final now = _clock();
      final deckId = _deckId;
      if (deckId == null) {
        await _createDeck(userId: _userId, name: name, now: now);
      } else {
        await _renameDeck(
          userId: _userId,
          deckId: deckId,
          name: name,
          now: now,
        );
      }
      value = DeckFormViewState(
        status: DeckFormStatus.success,
        initialName: value.initialName,
      );
    } on DeckException catch (error) {
      value = DeckFormViewState(
        status: DeckFormStatus.error,
        initialName: value.initialName,
        error: error,
      );
    } catch (_) {
      value = DeckFormViewState(
        status: DeckFormStatus.error,
        initialName: value.initialName,
        error: const DeckNetworkException(),
      );
    }
  }
}
