import 'package:andenken_app/domain/deck/deck_exception.dart';
import 'package:andenken_app/domain/entities/card.dart';
import 'package:andenken_app/domain/entities/deck.dart';
import 'package:andenken_app/domain/usecases/create_deck.dart';
import 'package:andenken_app/domain/usecases/delete_deck.dart';
import 'package:andenken_app/domain/usecases/list_decks.dart';
import 'package:andenken_app/domain/usecases/rename_deck.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/fake_card_repository.dart';
import '../../fakes/fake_deck_repository.dart';

void main() {
  late FakeDeckRepository decks;
  late FakeCardRepository cards;
  final now = DateTime.utc(2026, 8, 1);

  setUp(() {
    cards = FakeCardRepository();
    decks = FakeDeckRepository();
  });

  group('ListDecks (US-03, RN-D02)', () {
    test('lista vazia devolve lista vazia', () async {
      final listDecks = ListDecks(decks);

      expect(await listDecks(userId: 'u1'), isEmpty);
    });

    test('lista só os decks do user, por createdAt', () async {
      await decks.create(
        Deck(
          id: 'later',
          userId: 'u1',
          name: 'Depois',
          createdAt: DateTime.utc(2026, 8, 3),
        ),
      );
      await decks.create(
        Deck(
          id: 'earlier',
          userId: 'u1',
          name: 'Antes',
          createdAt: DateTime.utc(2026, 8, 1),
        ),
      );
      await decks.create(
        Deck(
          id: 'other',
          userId: 'u2',
          name: 'Alheio',
          createdAt: DateTime.utc(2026, 8, 2),
        ),
      );
      final listDecks = ListDecks(decks);

      final listed = await listDecks(userId: 'u1');

      expect(listed.map((deck) => deck.id), ['earlier', 'later']);
    });
  });

  group('CreateDeck (US-03, RN-D01)', () {
    test('nome válido aparece na lista, trimmed, com createdAt', () async {
      final createDeck = CreateDeck(decks, generateId: () => 'd1');

      final deck = await createDeck(
        userId: 'u1',
        name: '  Alemão A1  ',
        now: now,
      );

      expect(deck.id, 'd1');
      expect(deck.userId, 'u1');
      expect(deck.name, 'Alemão A1');
      expect(deck.createdAt, now);
      expect(deck.updatedAt, isNull);
      expect(await ListDecks(decks)(userId: 'u1'), [deck]);
    });

    test('nome vazio ou só espaço não salva', () async {
      final createDeck = CreateDeck(decks, generateId: () => 'd1');

      await expectLater(
        () => createDeck(userId: 'u1', name: '', now: now),
        throwsA(isA<InvalidDeckNameException>()),
      );
      await expectLater(
        () => createDeck(userId: 'u1', name: '   ', now: now),
        throwsA(isA<InvalidDeckNameException>()),
      );
      expect(await decks.listByUser('u1'), isEmpty);
    });

    test('nome com mais de 80 caracteres não salva', () async {
      final createDeck = CreateDeck(decks, generateId: () => 'd1');

      await expectLater(
        () => createDeck(userId: 'u1', name: 'a' * 81, now: now),
        throwsA(isA<InvalidDeckNameException>()),
      );
      expect(await decks.listByUser('u1'), isEmpty);
    });

    test('nome com 80 caracteres após trim é aceito', () async {
      final createDeck = CreateDeck(decks, generateId: () => 'd1');
      final name = 'a' * 80;

      final deck = await createDeck(userId: 'u1', name: '  $name  ', now: now);

      expect(deck.name, name);
    });
  });

  group('RenameDeck (US-03, RN-D01, RN-D04)', () {
    test('renomeia só aquele deck, trim, atualiza updatedAt', () async {
      await decks.create(
        Deck(id: 'd1', userId: 'u1', name: 'Antigo', createdAt: now),
      );
      await decks.create(
        Deck(id: 'd2', userId: 'u1', name: 'Outro', createdAt: now),
      );
      final renamedAt = DateTime.utc(2026, 8, 2);
      final renameDeck = RenameDeck(decks);

      final renamed = await renameDeck(
        userId: 'u1',
        deckId: 'd1',
        name: '  Novo nome  ',
        now: renamedAt,
      );

      expect(renamed.name, 'Novo nome');
      expect(renamed.updatedAt, renamedAt);
      expect(renamed.createdAt, now);
      expect((await decks.getById(userId: 'u1', deckId: 'd2')).name, 'Outro');
    });

    test('nome inválido não altera o deck', () async {
      await decks.create(
        Deck(id: 'd1', userId: 'u1', name: 'Antigo', createdAt: now),
      );
      final renameDeck = RenameDeck(decks);

      await expectLater(
        () => renameDeck(
          userId: 'u1',
          deckId: 'd1',
          name: '   ',
          now: DateTime.utc(2026, 8, 2),
        ),
        throwsA(isA<InvalidDeckNameException>()),
      );
      await expectLater(
        () => renameDeck(
          userId: 'u1',
          deckId: 'd1',
          name: 'b' * 81,
          now: DateTime.utc(2026, 8, 2),
        ),
        throwsA(isA<InvalidDeckNameException>()),
      );
      expect((await decks.getById(userId: 'u1', deckId: 'd1')).name, 'Antigo');
    });
  });

  group('DeleteDeck (US-03, RN-D03, plan §6.2)', () {
    test(
      'apaga o deck e os cards da subcoleção, sem tocar nos outros',
      () async {
        await decks.create(
          Deck(id: 'd1', userId: 'u1', name: 'Alvo', createdAt: now),
        );
        await decks.create(
          Deck(id: 'keep', userId: 'u1', name: 'Fica', createdAt: now),
        );
        await cards.create(
          Card.newCard(
            id: 'c1',
            deckId: 'd1',
            frontText: 'a',
            backText: 'b',
            createdAt: now,
          ),
          userId: 'u1',
        );
        await cards.create(
          Card.newCard(
            id: 'c2',
            deckId: 'd1',
            frontText: 'c',
            backText: 'd',
            createdAt: now,
          ),
          userId: 'u1',
        );
        await cards.create(
          Card.newCard(
            id: 'keep-card',
            deckId: 'keep',
            frontText: 'x',
            backText: 'y',
            createdAt: now,
          ),
          userId: 'u1',
        );
        final deleteDeck = DeleteDeck(decks, cards);

        await deleteDeck(userId: 'u1', deckId: 'd1');

        expect((await ListDecks(decks)(userId: 'u1')).map((deck) => deck.id), [
          'keep',
        ]);
        expect(await cards.listByDeck(userId: 'u1', deckId: 'd1'), isEmpty);
        expect(
          await cards.listByDeck(userId: 'u1', deckId: 'keep'),
          hasLength(1),
        );
      },
    );
  });
}
