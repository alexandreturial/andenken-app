import 'package:andenken_app/domain/card/card_exception.dart';
import 'package:andenken_app/domain/deck/deck_exception.dart';
import 'package:andenken_app/domain/entities/card.dart';
import 'package:andenken_app/domain/entities/deck.dart';
import 'package:andenken_app/domain/usecases/delete_card.dart';
import 'package:andenken_app/domain/usecases/delete_deck.dart';
import 'package:andenken_app/domain/usecases/list_cards.dart';
import 'package:andenken_app/presentation/decks/deck_detail_notifier.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_card_repository.dart';
import '../fakes/fake_deck_repository.dart';

void main() {
  late FakeDeckRepository decks;
  late FakeCardRepository cards;
  late DeckDetailNotifier notifier;
  final createdAt = DateTime.utc(2026, 8, 1);

  setUp(() {
    decks = FakeDeckRepository();
    cards = FakeCardRepository();
    notifier = DeckDetailNotifier(
      decks: decks,
      listCards: ListCards(cards),
      deleteCard: DeleteCard(cards),
      deleteDeck: DeleteDeck(decks, cards),
      userId: 'u1',
      deckId: 'd1',
    );
  });

  tearDown(() => notifier.dispose());

  Future<void> seedDeck() {
    return decks.create(
      Deck(id: 'd1', userId: 'u1', name: 'Alemão A1', createdAt: createdAt),
    );
  }

  test('começa em loading', () {
    expect(notifier.value.status, DeckDetailStatus.loading);
    expect(notifier.value.cards, isEmpty);
    expect(notifier.value.canStudy, isFalse);
  });

  test('deck sem cards vai para empty e canStudy é false', () async {
    await seedDeck();

    await notifier.load();

    expect(notifier.value.status, DeckDetailStatus.empty);
    expect(notifier.value.deck?.name, 'Alemão A1');
    expect(notifier.value.cards, isEmpty);
    expect(notifier.value.canStudy, isFalse);
  });

  test('deck com cards vai para data e canStudy é true', () async {
    await seedDeck();
    await cards.create(
      Card.newCard(
        id: 'c1',
        deckId: 'd1',
        frontText: 'Hallo',
        backText: 'Olá',
        createdAt: createdAt,
      ),
      userId: 'u1',
    );

    await notifier.load();

    expect(notifier.value.status, DeckDetailStatus.data);
    expect(notifier.value.cards.map((card) => card.frontText), ['Hallo']);
    expect(notifier.value.canStudy, isTrue);
  });

  test('deck inexistente vai para error', () async {
    await notifier.load();

    expect(notifier.value.status, DeckDetailStatus.error);
    expect(notifier.value.error, isA<DeckNotFoundException>());
  });

  test('falha de rede nos cards vai para error', () async {
    await seedDeck();
    cards.forcedListError = const CardNetworkException();

    await notifier.load();

    expect(notifier.value.status, DeckDetailStatus.error);
    expect(notifier.value.error, isA<CardNetworkException>());
  });

  test('deleteCard remove só aquele card e recarrega', () async {
    await seedDeck();
    await cards.create(
      Card.newCard(
        id: 'c1',
        deckId: 'd1',
        frontText: 'Hallo',
        backText: 'Olá',
        createdAt: createdAt,
      ),
      userId: 'u1',
    );
    await cards.create(
      Card.newCard(
        id: 'keep',
        deckId: 'd1',
        frontText: 'Danke',
        backText: 'Obrigado',
        createdAt: createdAt,
      ),
      userId: 'u1',
    );
    await notifier.load();

    await notifier.deleteCard('c1');

    expect(notifier.value.status, DeckDetailStatus.data);
    expect(notifier.value.cards.map((card) => card.id), ['keep']);
  });

  test('deleteCard do último card vai para empty', () async {
    await seedDeck();
    await cards.create(
      Card.newCard(
        id: 'c1',
        deckId: 'd1',
        frontText: 'Hallo',
        backText: 'Olá',
        createdAt: createdAt,
      ),
      userId: 'u1',
    );
    await notifier.load();

    await notifier.deleteCard('c1');

    expect(notifier.value.status, DeckDetailStatus.empty);
    expect(notifier.value.canStudy, isFalse);
  });

  test('deleteDeck vai para deleted', () async {
    await seedDeck();
    await cards.create(
      Card.newCard(
        id: 'c1',
        deckId: 'd1',
        frontText: 'Hallo',
        backText: 'Olá',
        createdAt: createdAt,
      ),
      userId: 'u1',
    );
    await notifier.load();

    await notifier.deleteDeck();

    expect(notifier.value.status, DeckDetailStatus.deleted);
    expect(await decks.listByUser('u1'), isEmpty);
    expect(await cards.listByDeck(userId: 'u1', deckId: 'd1'), isEmpty);
  });
}
