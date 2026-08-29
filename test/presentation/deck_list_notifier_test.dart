import 'package:andenken_app/domain/deck/deck_exception.dart';
import 'package:andenken_app/domain/entities/card.dart';
import 'package:andenken_app/domain/entities/deck.dart';
import 'package:andenken_app/domain/usecases/delete_deck.dart';
import 'package:andenken_app/domain/usecases/list_cards.dart';
import 'package:andenken_app/domain/usecases/list_decks.dart';
import 'package:andenken_app/presentation/decks/deck_list_notifier.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_card_repository.dart';
import '../fakes/fake_deck_repository.dart';
import '../fakes/fake_study_stats_repository.dart';

void main() {
  late FakeDeckRepository decks;
  late FakeCardRepository cards;
  late DeckListNotifier notifier;
  final createdAt = DateTime.utc(2026, 8, 1);

  setUp(() {
    decks = FakeDeckRepository();
    cards = FakeCardRepository();
    notifier = DeckListNotifier(
      listDecks: ListDecks(decks),
      deleteDeck: DeleteDeck(decks, cards),
      listCards: ListCards(cards),
      studyStats: FakeStudyStatsRepository(),
      userId: 'u1',
      clock: () => createdAt,
    );
  });

  tearDown(() => notifier.dispose());

  List<DeckListStatus> captureStatuses() {
    final statuses = <DeckListStatus>[];
    notifier.addListener(() => statuses.add(notifier.value.status));
    return statuses;
  }

  test('começa em loading', () {
    expect(notifier.value.status, DeckListStatus.loading);
    expect(notifier.value.decks, isEmpty);
    expect(notifier.value.error, isNull);
  });

  test('lista vazia vai para empty', () async {
    await notifier.load();

    expect(notifier.value.status, DeckListStatus.empty);
    expect(notifier.value.decks, isEmpty);
    expect(notifier.value.error, isNull);
  });

  test('lista com decks vai para data', () async {
    await decks.create(
      Deck(id: 'd1', userId: 'u1', name: 'Alemão A1', createdAt: createdAt),
    );
    await decks.create(
      Deck(id: 'other', userId: 'u2', name: 'Alheio', createdAt: createdAt),
    );

    await notifier.load();

    expect(notifier.value.status, DeckListStatus.data);
    expect(notifier.value.decks.map((deck) => deck.id), ['d1']);
    expect(notifier.value.dueCountByDeckId, {'d1': 0});
    expect(notifier.value.error, isNull);
  });

  test('conta cards due por deck (US-06, T067)', () async {
    await decks.create(
      Deck(id: 'd1', userId: 'u1', name: 'Alemão A1', createdAt: createdAt),
    );
    await cards.create(
      Card.newCard(
        id: 'due',
        deckId: 'd1',
        frontText: 'Hallo',
        backText: 'Olá',
        createdAt: createdAt,
      ),
      userId: 'u1',
    );
    await cards.create(
      Card(
        id: 'later',
        deckId: 'd1',
        frontText: 'Morgen',
        backText: 'Amanhã',
        nextReviewAt: createdAt.add(const Duration(days: 10)),
        createdAt: createdAt,
        updatedAt: createdAt,
      ),
      userId: 'u1',
    );

    await notifier.load();

    expect(notifier.value.dueCountByDeckId, {'d1': 1});
    expect(notifier.value.masteryByDeckId['d1']?.percent, 50);
    expect(notifier.value.masteryByDeckId['d1']?.total, 2);
  });

  test('falha de rede vai para error', () async {
    decks.forcedListError = const DeckNetworkException();

    await notifier.load();

    expect(notifier.value.status, DeckListStatus.error);
    expect(notifier.value.error, isA<DeckNetworkException>());
    expect(notifier.value.decks, isEmpty);
  });

  test('reload passa por loading e volta a data', () async {
    await decks.create(
      Deck(id: 'd1', userId: 'u1', name: 'Alemão A1', createdAt: createdAt),
    );
    await notifier.load();
    final statuses = captureStatuses();

    await notifier.load();

    expect(statuses, [DeckListStatus.loading, DeckListStatus.data]);
    expect(notifier.value.decks.map((deck) => deck.id), ['d1']);
  });

  test('deleteDeck remove o deck e os cards e recarrega a lista', () async {
    await decks.create(
      Deck(id: 'd1', userId: 'u1', name: 'Alvo', createdAt: createdAt),
    );
    await decks.create(
      Deck(id: 'keep', userId: 'u1', name: 'Fica', createdAt: createdAt),
    );
    await cards.create(
      Card.newCard(
        id: 'c1',
        deckId: 'd1',
        frontText: 'a',
        backText: 'b',
        createdAt: createdAt,
      ),
      userId: 'u1',
    );
    await notifier.load();

    await notifier.deleteDeck('d1');

    expect(notifier.value.status, DeckListStatus.data);
    expect(notifier.value.decks.map((deck) => deck.id), ['keep']);
    expect(await cards.listByDeck(userId: 'u1', deckId: 'd1'), isEmpty);
  });

  test('deleteDeck do último deck vai para empty', () async {
    await decks.create(
      Deck(id: 'd1', userId: 'u1', name: 'Alvo', createdAt: createdAt),
    );
    await notifier.load();

    await notifier.deleteDeck('d1');

    expect(notifier.value.status, DeckListStatus.empty);
    expect(notifier.value.decks, isEmpty);
  });

  test('deleteDeck em falha de rede vai para error', () async {
    await decks.create(
      Deck(id: 'd1', userId: 'u1', name: 'Alvo', createdAt: createdAt),
    );
    await notifier.load();
    decks.forcedDeleteError = const DeckNetworkException();

    await notifier.deleteDeck('d1');

    expect(notifier.value.status, DeckListStatus.error);
    expect(notifier.value.error, isA<DeckNetworkException>());
  });
}
