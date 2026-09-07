import 'package:andenken_app/domain/card/card_exception.dart';
import 'package:andenken_app/domain/deck/deck_exception.dart';
import 'package:andenken_app/domain/entities/card.dart';
import 'package:andenken_app/domain/entities/deck.dart';
import 'package:andenken_app/domain/usecases/create_card.dart';
import 'package:andenken_app/domain/usecases/create_deck.dart';
import 'package:andenken_app/domain/usecases/list_cards.dart';
import 'package:andenken_app/domain/usecases/rename_deck.dart';
import 'package:andenken_app/domain/usecases/update_card.dart';
import 'package:andenken_app/presentation/decks/deck_form_notifier.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_card_repository.dart';
import '../fakes/fake_deck_repository.dart';

void main() {
  late FakeDeckRepository decks;
  late FakeCardRepository cards;
  late DeckFormNotifier notifier;
  final now = DateTime.utc(2026, 8, 2);

  DeckFormNotifier createNotifier({String? deckId}) {
    var nextCardId = 0;
    return DeckFormNotifier(
      createDeck: CreateDeck(decks, generateId: () => 'd-new'),
      renameDeck: RenameDeck(decks),
      createCard: CreateCard(cards, generateId: () => 'c-${nextCardId++}'),
      updateCard: UpdateCard(cards),
      listCards: ListCards(cards),
      decks: decks,
      userId: 'u1',
      deckId: deckId,
      clock: () => now,
    );
  }

  setUp(() {
    decks = FakeDeckRepository();
    cards = FakeCardRepository();
  });

  tearDown(() => notifier.dispose());

  test('create com nome válido vai para success', () async {
    notifier = createNotifier();

    await notifier.submit('  Alemão A1  ');

    expect(notifier.value.status, DeckFormStatus.success);
    expect(
      (await decks.getById(userId: 'u1', deckId: 'd-new')).name,
      'Alemão A1',
    );
  });

  test('create só com nome não grava cards (RN-F01)', () async {
    notifier = createNotifier();

    await notifier.submit(
      'Alemão A1',
      drafts: const [
        CardDraftInput(frontText: '  ', backText: ''),
        CardDraftInput(frontText: '', backText: '   '),
      ],
    );

    expect(notifier.value.status, DeckFormStatus.success);
    expect(await cards.listByDeck(userId: 'u1', deckId: 'd-new'), isEmpty);
  });

  test('create com 1 card válido grava deck e card (US-12)', () async {
    notifier = createNotifier();

    await notifier.submit(
      'Alemão A1',
      drafts: const [
        CardDraftInput(frontText: '  Hallo  ', backText: '  Olá  '),
      ],
    );

    expect(notifier.value.status, DeckFormStatus.success);
    final listed = await cards.listByDeck(userId: 'u1', deckId: 'd-new');
    expect(listed, hasLength(1));
    expect(listed.single.frontText, 'Hallo');
    expect(listed.single.backText, 'Olá');
  });

  test('create com rascunho parcial vai para error e não grava (RN-F01)', () async {
    notifier = createNotifier();

    await notifier.submit(
      'Alemão A1',
      drafts: const [CardDraftInput(frontText: 'Hallo', backText: '  ')],
    );

    expect(notifier.value.status, DeckFormStatus.error);
    expect(notifier.value.error, isA<InvalidCardTextException>());
    expect(await decks.listByUser('u1'), isEmpty);
    expect(await cards.listByDeck(userId: 'u1', deckId: 'd-new'), isEmpty);
  });

  test('create ignora linha em branco e grava só o card válido (RN-F01)', () async {
    notifier = createNotifier();

    await notifier.submit(
      'Alemão A1',
      drafts: const [
        CardDraftInput(frontText: 'Hallo', backText: 'Olá'),
        CardDraftInput(frontText: '  ', backText: ''),
      ],
    );

    expect(notifier.value.status, DeckFormStatus.success);
    expect(await cards.listByDeck(userId: 'u1', deckId: 'd-new'), hasLength(1));
  });

  test('create com nome vazio vai para error e não grava', () async {
    notifier = createNotifier();

    await notifier.submit(
      '   ',
      drafts: const [CardDraftInput(frontText: 'Hallo', backText: 'Olá')],
    );

    expect(notifier.value.status, DeckFormStatus.error);
    expect(notifier.value.error, isA<InvalidDeckNameException>());
    expect(await decks.listByUser('u1'), isEmpty);
    expect(await cards.listByDeck(userId: 'u1', deckId: 'd-new'), isEmpty);
  });

  test('rename carrega o nome e atualiza', () async {
    await decks.create(
      Deck(
        id: 'd1',
        userId: 'u1',
        name: 'Antigo',
        createdAt: DateTime.utc(2026, 8, 1),
      ),
    );
    notifier = createNotifier(deckId: 'd1');

    await notifier.load();

    expect(notifier.value.initialName, 'Antigo');
    expect(notifier.value.status, DeckFormStatus.idle);

    await notifier.submit('Novo nome');

    expect(notifier.value.status, DeckFormStatus.success);
    expect((await decks.getById(userId: 'u1', deckId: 'd1')).name, 'Novo nome');
  });

  test('edit atualiza nome, card existente e adiciona novo (US-13, RN-C03)', () async {
    final createdAt = DateTime.utc(2026, 8, 1);
    await decks.create(
      Deck(
        id: 'd1',
        userId: 'u1',
        name: 'Antigo',
        createdAt: createdAt,
      ),
    );
    await cards.create(
      Card(
        id: 'c1',
        deckId: 'd1',
        frontText: 'Antigo',
        backText: 'Old',
        repetitions: 3,
        intervalDays: 6,
        easeFactor: 2.6,
        nextReviewAt: DateTime.utc(2026, 8, 10),
        lastReviewedAt: DateTime.utc(2026, 8, 4),
        createdAt: createdAt,
        updatedAt: createdAt,
      ),
      userId: 'u1',
    );
    notifier = createNotifier(deckId: 'd1');

    await notifier.load();

    expect(notifier.value.initialName, 'Antigo');
    expect(notifier.value.initialCards, hasLength(1));
    expect(notifier.value.initialCards.single.cardId, 'c1');
    expect(notifier.value.initialCards.single.frontText, 'Antigo');

    await notifier.submit(
      'Novo nome',
      drafts: const [
        CardDraftInput(cardId: 'c1', frontText: 'Hallo', backText: 'Olá'),
        CardDraftInput(frontText: 'Danke', backText: 'Obrigado'),
      ],
    );

    expect(notifier.value.status, DeckFormStatus.success);
    expect((await decks.getById(userId: 'u1', deckId: 'd1')).name, 'Novo nome');
    final updated = await cards.getById(
      userId: 'u1',
      deckId: 'd1',
      cardId: 'c1',
    );
    expect(updated.frontText, 'Hallo');
    expect(updated.backText, 'Olá');
    expect(updated.repetitions, 3);
    expect(updated.easeFactor, 2.6);
    expect(
      (await cards.listByDeck(userId: 'u1', deckId: 'd1')).map(
        (card) => card.frontText,
      ),
      ['Hallo', 'Danke'],
    );
  });

  test('edit com rascunho parcial não grava (RN-F01)', () async {
    await decks.create(
      Deck(
        id: 'd1',
        userId: 'u1',
        name: 'Antigo',
        createdAt: DateTime.utc(2026, 8, 1),
      ),
    );
    notifier = createNotifier(deckId: 'd1');
    await notifier.load();

    await notifier.submit(
      'Novo nome',
      drafts: const [CardDraftInput(frontText: 'Hallo', backText: '')],
    );

    expect(notifier.value.status, DeckFormStatus.error);
    expect(notifier.value.error, isA<InvalidCardTextException>());
    expect((await decks.getById(userId: 'u1', deckId: 'd1')).name, 'Antigo');
    expect(await cards.listByDeck(userId: 'u1', deckId: 'd1'), isEmpty);
  });

  test('rename de deck inexistente vai para error', () async {
    notifier = createNotifier(deckId: 'missing');

    await notifier.load();

    expect(notifier.value.status, DeckFormStatus.error);
    expect(notifier.value.error, isA<DeckNotFoundException>());
  });
}
